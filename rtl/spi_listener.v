module spi_listener #(
    parameter first_byte=8'h00,
    parameter listener_timeout=200
)
(
    input clk,
    input spi_slave_data_valid,
    input [7:0] spi_slave_byte,
    output reg [23:0] spi_data,
    output reg spi_listener_interrupt=0
);

reg timeout;
reg [15:0] timeout_cnt=0;
reg [1:0] spi_byte_cnt=0;
reg [7:0] spi_slave_bytes [0:1];

always @(posedge clk)
begin
    if(spi_slave_data_valid)
    begin
        case(spi_byte_cnt)
        0:
        begin
            if(spi_slave_byte[7:5]==first_byte[7:5] )
            begin
                spi_slave_bytes[0]<=spi_slave_byte;
                spi_byte_cnt<=1;
            end
            else
                spi_byte_cnt<=0;
        end
        1:
        begin
            if(timeout)
                spi_byte_cnt<=0;
            else
            begin
                spi_slave_bytes[1]<=spi_slave_byte;
                spi_byte_cnt<=2;
            end
        end
        2:
        begin
            if(timeout)
                spi_byte_cnt<=0;
            else
            begin
                spi_data<={spi_slave_bytes[0],spi_slave_bytes[1],spi_slave_byte};
                spi_listener_interrupt<=1;
                spi_byte_cnt<=0;
            end
        end
        endcase
    end
    else
        spi_listener_interrupt<=0;
end

always @(posedge clk)
begin
    if(spi_slave_data_valid)
    begin
        timeout<=0;
        timeout_cnt<=0;
    end
    else if(timeout_cnt==listener_timeout)
        timeout<=1;
    else
        timeout_cnt<=timeout_cnt+1;
end

endmodule