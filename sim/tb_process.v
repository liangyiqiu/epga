	`timescale 1ns / 1ps
    module tb_process;

    reg clk;
	reg rst_n;

    reg tx_ready;
	wire start_tx;
	wire [128-1:0] send_data;
	wire [5:0] send_data_bytes;

	reg [128-1:0] receive_data;
	reg RX_interrupt;
	wire [3:0] receive_data_bytes;
	wire RX_interrupt_clear;

    reg [1:0] spi_ready;
    wire spi_dir;
    wire [1:0] spi_start;
    wire [23:0] spi_data_tx;
    wire [7:0] spi_data_depth;

    wire amp_en;

    process uut(
        .clk(clk),             								
        .rst_n(rst_n), 
        .tx_ready(tx_ready),
        .start_tx(start_tx),
        .send_data(send_data),
        .send_data_bytes(send_data_bytes),
        .RX_interrupt(RX_interrupt),               			
        .RX_interrupt_clear(RX_interrupt_clear), 
        .receive_data(receive_data), 
        .receive_data_bytes(receive_data_bytes),
        .spi_ready(spi_ready),
        .spi_dir(spi_dir),
        .spi_start(spi_start),
        .spi_data_tx(spi_data_tx),
        .spi_data_depth(spi_data_depth),
        .amp_en(amp_en)
    );

    initial begin
        // Initialize Inputs
		clk = 0;
		rst_n = 0;
		tx_ready = 0;
		receive_data = 0;
		RX_interrupt = 0;
		spi_ready = 2'b11;

        #100;
        // Add stimulus here
		rst_n=1;
        #100
        spi_ready=2'b11;
        #100
        spi_ready=2'b11;
        #100
        spi_ready=2'b11;
        #100
        spi_ready=2'b11;
        #100
        spi_ready=2'b11;
        #100
        spi_ready=2'b11;
        #100
        spi_ready=2'b11;
        #100
        spi_ready=2'b11;
        #100
        spi_ready=2'b11;
    end

    always#5 clk=~clk;
	always @(posedge clk)
	begin
		if(RX_interrupt_clear)
			RX_interrupt<=0;
		if(spi_start[0])
			spi_ready[0]<=0;
        if(spi_start[1])
			spi_ready[1]<=0;
	end

    endmodule