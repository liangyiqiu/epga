module tb_spi_listener();

reg clk;
reg spi_slave_data_valid;
reg [7:0] spi_slave_byte;
wire [23:0] spi_data;
wire spi_listener_interrupt;
wire [15:0] timeout_cnt;

spi_listener uut(
    .clk(clk),
    .spi_slave_data_valid(spi_slave_data_valid),
    .spi_slave_byte(spi_slave_byte),
    .spi_data(spi_data),
    .spi_listener_interrupt(spi_listener_interrupt)
    //.timeout_cnt(timeout_cnt)
);

initial begin
clk = 0;
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h02;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h02;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h02;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h02;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h02;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;

#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h00;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;
#100
spi_slave_byte=8'h02;
spi_slave_data_valid=1;
#10
spi_slave_data_valid=0;



end


always #5 clk=~clk;

endmodule
