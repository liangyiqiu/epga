`timescale 1ns / 1ps
module tb_spi_slave;

    parameter SPI_MODE = 0; // CPOL = 0, CPHA = 0
    parameter SPI_CLK_DELAY = 20;  // 2.5 MHz
    parameter MAIN_CLK_DELAY = 2;  // 25 MHz

    reg r_Rst_L     = 1'b0;
  
    // CPOL=0, clock idles 0.  CPOL=1, clock idles 1
    //  reg r_SPI_Clk   = w_CPOL ? 1'b1 : 1'b0;
    wire w_SPI_Clk;
    reg r_Clk       = 1'b0;
    wire w_SPI_CS_n;
    wire w_SPI_MOSI;
    wire w_SPI_MISO;
    

    // Master Specific
    reg r_spi_start;
    reg r_spi_dir;
    reg [7:0] r_spi_data_depth;
    reg [23:0] r_spi_data_tx;
    wire w_spi_ready;

    // Slave Specific
    wire w_Slave_RX_DV;
    reg r_Slave_TX_DV;
    wire [7:0] w_Slave_RX_Byte;
    reg r_Slave_TX_Byte;

    // Clock Generators:
    always#5 r_Clk=~r_Clk;

      // Instantiate UUT
  SPI_Slave #(.SPI_MODE(SPI_MODE)) SPI_Slave_UUT
  (
   // Control/Data Signals,
   .i_Rst_L(r_Rst_L),      // FPGA Reset
   .i_Clk(r_Clk),          // FPGA Clock
   .o_RX_DV(w_Slave_RX_DV),      // Data Valid pulse (1 clock cycle)
   .o_RX_Byte(w_Slave_RX_Byte),  // Byte received on MOSI
   .i_TX_DV(w_Slave_TX_DV),      // Data Valid pulse
   .i_TX_Byte(w_Slave_RX_Byte),  // Byte to serialize to MISO (set up for loopback)

   // SPI Interface
   .i_SPI_Clk(w_SPI_Clk),
   .o_SPI_MISO(w_SPI_MISO),
   .i_SPI_MOSI(w_SPI_MOSI),
   .i_SPI_CS_n(w_SPI_CS_n)
   );

   spi_master #(
    .clk_div(4),
    .data_depth(24)
   )
   spi_master_utt
   (
    .clk(r_Clk),
    .rst_n(r_Rst_L),
    .spi_start(r_spi_start),
    .spi_dir(r_spi_dir),
    .spi_data_depth(r_spi_data_depth),
    .spi_data_tx(r_spi_data_tx),
    .spi_ready(w_spi_ready),
    .spi_sclk(w_SPI_Clk),
    .spi_mosi(w_SPI_MOSI),
    .spi_le(w_SPI_CS_n)
   );

   initial
   begin
    r_Rst_L=0;
    r_spi_start=0;
    #10;
    r_Rst_L=1;
    #100;
    r_spi_dir=0;
    r_spi_data_depth=24;
    r_spi_data_tx=16'haabbcc;
    r_spi_start=1;
    #100
    r_spi_start=0;

   end

endmodule
