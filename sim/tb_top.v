`timescale 1ns / 1ps
`define ISIM
module tb_top;

    reg r_Rst_L     = 1'b0;
    reg r_debug_mode =0;

    // CPOL=0, clock idles 0.  CPOL=1, clock idles 1
    //  reg r_SPI_Clk   = w_CPOL ? 1'b1 : 1'b0;
    wire w_SPI_Clk;
    wire w_fpga_spi_clk_p;
    wire w_fpga_spi_clk_n;
    reg r_Clk       = 1'b0;
    wire w_SPI_CS_n;
    wire w_SPI_MOSI;
    wire w_fpga_spi_mosi_p;
    wire w_fpga_spi_mosi_n;
    wire w_SPI_MISO;

    wire w_amp_en;
    wire w_spi_clk_2594;
    

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
    top top(
        .clk(r_Clk),
        .debug_mode(r_debug_mode),
        .fpga_spi_clk_p(w_fpga_spi_clk_p),
        .fpga_spi_clk_n(w_fpga_spi_clk_n),
        .fpga_spi_mosi_p(w_fpga_spi_mosi_p),
        .fpga_spi_mosi_n(w_fpga_spi_mosi_n),
        .fpga_spi_cs(w_SPI_CS_n),
        .amp_en(w_amp_en),
        .spi_clk_2594(w_spi_clk_2594)
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

    OBUFDS #(
        .IOSTANDARD("LVDS_33")
    )
    tb_spi_clk_obufds
    (    
        .I(w_SPI_Clk),
        .O(w_fpga_spi_clk_p),
        .OB(w_fpga_spi_clk_n)
    );

    OBUFDS #(
        .IOSTANDARD("LVDS_33")
    )
    tb_spi_mosi_obufds
    (    
        .I(w_SPI_MOSI),
        .O(w_fpga_spi_mosi_p),
        .OB(w_fpga_spi_mosi_n)
    );

    initial
    begin
        r_Rst_L=0;
        r_spi_start=0;
        #10
        r_Rst_L=1;
        #300000
        r_spi_dir=0;
        r_spi_data_depth=24;
        r_spi_data_tx=24'h200000;
        r_spi_start=1;
        #100
        r_spi_start=0;
    end

endmodule
