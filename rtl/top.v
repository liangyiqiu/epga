module top
(
    input clk,

    input debug_mode,

    input  FPGA_RX,
	output FPGA_TX,

    input fpga_spi_clk_p,
    input fpga_spi_clk_n,
    input fpga_spi_mosi_p,
    input fpga_spi_mosi_n,
    input fpga_spi_cs_p,
    input fpga_spi_cs_n,
    input fpga_tx,
    input fpga_rx,

    output trx1_spi_clk_p,
    output trx1_spi_clk_n,
    output trx1_spi_mosi_p,
    output trx1_spi_mosi_n,
    output trx1_spi_cs,
    output trx1_en_n,
    output trx1_tx,
    output trx1_rx,

    output trx2_spi_clk_p,
    output trx2_spi_clk_n,
    output trx2_spi_mosi_p,
    output trx2_spi_mosi_n,
    output trx2_spi_cs,
    output trx2_en_n,
    output trx2_tx,
    output trx2_rx,

    output aux1_spi_clk,
    output aux1_spi_mosi,
    output aux1_spi_cs,
    output aux1_sw,

    output aux2_spi_clk,
    output aux2_spi_mosi,
    output aux2_spi_cs,
    output aux2_sw,
    
    output spi_clk_4002,
    output spi_sdo_4002,
    output spi_le_4002,

    output spi_clk_2594,
    output spi_sdo_2594,
    output spi_le_2594,

    input mout_4002,
    input mout_2594,

    output ce_4002,
    output ce_2594,

    output amp_en,

    output [1:0] led
);

wire fpga_spi_clk;
wire fpga_spi_mosi;
wire fpga_spi_cs;

wire trx1_spi_clk;
wire trx1_spi_mosi;

wire trx2_spi_clk;
wire trx2_spi_mosi;

wire internal_spi_clk;
wire internal_spi_mosi;
wire internal_spi_cs;
wire internal_rx;
wire internal_tx;

assign trx1_spi_clk=internal_spi_clk;
assign trx1_spi_mosi=internal_spi_mosi;
assign trx1_spi_cs=internal_spi_cs;
assign trx1_en_n=1'b1;

assign trx2_spi_clk=internal_spi_clk;
assign trx2_spi_mosi=internal_spi_mosi;
assign trx2_spi_cs=internal_spi_cs;
assign trx2_en_n=1'b1;

assign aux1_spi_clk=internal_spi_clk;
assign aux1_spi_mosi=internal_spi_mosi;
assign aux1_spi_cs=internal_spi_cs;
assign aux1_sw=1'b1;

assign aux2_spi_clk=internal_spi_clk;
assign aux2_spi_mosi=internal_spi_mosi;
assign aux2_spi_cs=internal_spi_cs;
assign aux2_sw=1'b1;

assign trx1_tx=internal_tx;
assign trx1_rx=internal_rx;
assign trx2_tx=internal_tx;
assign trx2_rx=internal_rx;

assign led[0]=~mout_4002;
assign led[1]=~mout_2594;

wire rst_n;

rst rst(
    .clk(clk),
    .rst_n(rst_n),
    .ce_4002(ce_4002),
    .ce_2594(ce_2594)
);

parameter spi_data_depth_max = 54; //54 bits max spi transmition
parameter spi_clk_div = 5;  //spi clock=100M/5=20MHz

wire [2:0] spi_start;
wire [2:0] spi_ready;
wire spi_dir;
wire [7:0] spi_data_depth;
wire [spi_data_depth_max-1:0] spi_data_tx;


spi_master #(
    .clk_div(spi_clk_div),
    .data_depth(spi_data_depth_max)
)
adf4002_spi(
    .clk(clk),
    .rst_n(rst_n),
    .spi_start(spi_start[0]),
    .spi_dir(spi_dir),
    .spi_data_depth(spi_data_depth),
    .spi_data_tx(spi_data_tx),
    .spi_ready(spi_ready[0]),
    .spi_sclk(spi_clk_4002),
    .spi_mosi(spi_sdo_4002),
    .spi_le(spi_le_4002)
);

spi_master #(
    .clk_div(spi_clk_div),
    .data_depth(spi_data_depth_max)
)
lmx2594_spi(
    .clk(clk),
    .rst_n(rst_n),
    .spi_start(spi_start[1]),
    .spi_dir(spi_dir),
    .spi_data_depth(spi_data_depth),
    .spi_data_tx(spi_data_tx),
    .spi_ready(spi_ready[1]),
    .spi_sclk(spi_clk_2594),
    .spi_mosi(spi_sdo_2594),
    .spi_le(spi_le_2594)
);

parameter spi_clk_div_internal = 10;

spi_master #(
    .clk_div(spi_clk_div_internal),
    .data_depth(spi_data_depth_max)
)
internal_spi(
    .clk(clk),
    .rst_n(rst_n),
    .spi_start(spi_start[2]),
    .spi_dir(spi_dir),
    .spi_data_depth(spi_data_depth),
    .spi_data_tx(spi_data_tx),
    .spi_ready(spi_ready[2]),
    .spi_sclk(internal_spi_clk),
    .spi_mosi(internal_spi_mosi),
    .spi_le(internal_spi_cs)
);

parameter  Baud_rate = 115200; 	
parameter  clk_frq = 100000000; //tx & rx frequency
parameter  data_depth = 12;  //tx & rx data buffer depth		

parameter  data_bits = 8;  		
parameter  stop_bits = 2'b00;  	
parameter  parity = 2'b00; 

wire [data_depth*8-1:0] send_data;
wire [5:0] send_data_bytes;
wire TX_ready;
wire start_TX;
wire TX_busy;

UART_TX #(
    .Baud_rate(Baud_rate),  
    .clk_frq(clk_frq), 	
    .data_depth(data_depth) 
) 
TX (  
    .clk(clk),             
    .rst(rst_n),             
    .data_bits(data_bits), 
    .stop_bits(stop_bits), 
    .parity(parity_bit),   
    .send_data(send_data), 
    .send_data_bytes(send_data_bytes),
    .TX_ready(TX_ready),                   
    .start_TX(start_TX),                  
    .TX(FPGA_TX)                         
); 
    

wire [data_depth*8-1:0] receive_data;
wire [data_depth*8-1:0] receive_data_;
wire [5:0] receive_data_bytes;
wire [data_depth-1:0] receive_data_check;
wire receive_data_check_all;
wire RX_interrupt;
wire RX_interrupt_clear;
    
UART_RX #(
    .Baud_rate(Baud_rate),	 
    .clk_frq(clk_frq),  	 
    .data_depth(data_depth)
)
RX(
    .clk(clk),             								
    .rst(rst_n),             									
    .data_bits(data_bits), 									
    .stop_bits(stop_bits), 									
    .parity(parity),    										
    .receive_data(receive_data), 							
    .receive_data_(receive_data_), 							
    .receive_data_bytes(receive_data_bytes),        	 
    .receive_data_check(receive_data_check), 			
    .receive_data_check_all(receive_data_check_all),	
    .RX_interrupt(RX_interrupt),               			
    .RX_interrupt_clear(RX_interrupt_clear),          
    .RX(FPGA_RX)                         					
);

parameter SPI_MODE=0; // CPOL = 0, CPHA = 0

wire spi_slave_data_valid;
wire [7:0] spi_slave_byte;

SPI_Slave #(
    .SPI_MODE(SPI_MODE)
)
spi_slave
(
   .i_Rst_L(rst_n),
   .i_Clk(clk),
   .o_RX_DV(spi_slave_data_valid), 
   .o_RX_Byte(spi_slave_byte),
   .i_SPI_Clk(fpga_spi_clk),
   .i_SPI_MOSI(fpga_spi_mosi),
   .i_SPI_CS_n(fpga_spi_cs)
);

parameter first_byte=8'h00;
wire [23:0] fpga_spi_data;
wire spi_listener_interrupt;

spi_listener #(
    .first_byte(first_byte)
)
spi_listener
(
    .clk(clk),
    .spi_slave_data_valid(spi_slave_data_valid),
    .spi_slave_byte(spi_slave_byte),
    .spi_data(fpga_spi_data),
    .spi_listener_interrupt(spi_listener_interrupt)
);

process process(
    .clk(clk),             								
    .rst_n(rst_n),
    .debug_mode(debug_mode),
    .tx_ready(TX_ready),
    .start_tx(start_TX),
    .send_data(send_data),
    .send_data_bytes(send_data_bytes),
    .RX_interrupt(RX_interrupt),               			
    .RX_interrupt_clear(RX_interrupt_clear), 
    .receive_data(receive_data), 
    .receive_data_bytes(receive_data_bytes),
    .spi_listener_interrupt(spi_listener_interrupt),
    .fpga_spi_data(fpga_spi_data),
    .spi_ready(spi_ready),
    .spi_dir(spi_dir),
    .spi_start(spi_start),
    .spi_data_tx(spi_data_tx),
    .spi_data_depth(spi_data_depth),
    .amp_en(amp_en),
    .internal_rx(internal_rx),
    .internal_tx(internal_tx)
);

IBUFDS #(
    .IOSTANDARD("LVDS_33"),
    .DIFF_TERM("FALSE")
)
fpga_spi_clk_ibufds
(    
    .O(fpga_spi_clk),
    .I(fpga_spi_clk_p),
    .IB(fpga_spi_clk_n)
);

IBUFDS #(
    .IOSTANDARD("LVDS_33"),
    .DIFF_TERM("FALSE")
)
fpga_spi_mosi_ibufds
(    
    .O(fpga_spi_mosi),
    .I(fpga_spi_mosi_p),
    .IB(fpga_spi_mosi_n)
);

IBUFDS #(
    .IOSTANDARD("LVDS_33"),
    .DIFF_TERM("FALSE")
)
fpga_spi_cs_ibufds
(    
    .O(fpga_spi_cs),
    .I(fpga_spi_cs_p),
    .IB(fpga_spi_cs_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS_33")
)
trx1_clk_obufds
(    
    .I(trx1_spi_clk),
    .O(trx1_spi_clk_p),
    .OB(trx1_spi_clk_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS_33")
)
trx1_mosi_obufds
(    
    .I(trx1_spi_mosi),
    .O(trx1_spi_mosi_p),
    .OB(trx1_spi_mosi_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS_33")
)
trx2_clk_obufds
(    
    .I(trx2_spi_clk),
    .O(trx2_spi_clk_p),
    .OB(trx2_spi_clk_n)
);

OBUFDS #(
    .IOSTANDARD("LVDS_33")
)
trx2_mosi_obufds
(    
    .I(trx2_spi_mosi),
    .O(trx2_spi_mosi_p),
    .OB(trx2_spi_mosi_n)
);

endmodule