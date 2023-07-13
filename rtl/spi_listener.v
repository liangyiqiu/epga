module spi_listener #(
    parameter first_byte=8'h20
)
(
    input clk,
    input spi_slave_data_valid,
    input [7:0] spi_slave_byte,
    output reg [23:0] spi_data,
    output reg spi_listener_interrupt=0
);

reg spi_byte_cnt=0;
reg [7:0] spi_slave_bytes [0:2];

always @(posedge clk)
begin
    if(spi_slave_data_valid)
    case(spi_byte_cnt)
    0:
    begin
        spi_listener_interrupt<=0;
        if(spi_slave_byte[7:5]==first_byte[7:5])
        begin
            spi_slave_bytes[0]<=spi_slave_byte;
            spi_byte_cnt=1;
        end
    end
    1:
    begin
        spi_slave_bytes[1]<=spi_slave_byte;
        spi_byte_cnt=2;
    end
    2:
    begin
        spi_slave_bytes[2]<=spi_slave_byte;
        spi_data<={spi_slave_bytes[0],spi_slave_bytes[1],spi_slave_bytes[2]};
        spi_listener_interrupt<=1;
        spi_byte_cnt=0;
    end
    endcase
end

endmodule