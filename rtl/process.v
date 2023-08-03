module process
#(
    parameter uart_data_depth = 12
)
(
	input clk,
	input rst_n,
    input debug_mode,

    input tx_ready,
	output reg start_tx,
	output reg [uart_data_depth*8-1:0] send_data,
	output reg [5:0] send_data_bytes,

	input [uart_data_depth*8-1:0] receive_data,
	input RX_interrupt,
	output reg [3:0] receive_data_bytes,
	output reg RX_interrupt_clear,

    input spi_listener_interrupt,
    input [23:0] fpga_spi_data,

    input [1:0] spi_ready,
    output reg spi_dir,
    output reg [1:0] spi_start,
    output reg [23:0] spi_data_tx,
    output reg [7:0] spi_data_depth,

    output reg amp_en
);


reg [23:0] adf4002_reg [0:3];

reg [23:0] lmx2594_reg [0:112];

localparam              PROCESS_RESET    = 0, 
                        ADF4002_INIT     = 1, 
                        LMX2594_INIT     = 2,
                        UART_DEBUG       = 3,
                        NORMAL_OPERATION = 4;

wire [7:0] rx_byte [uart_data_depth-1:0];

genvar i;
generate 
    for(i=1;i<=uart_data_depth;i=i+1) 
    begin: rx_byte_gen
        assign rx_byte[i-1][7:0]=receive_data[i*8-1-:8];
    end
endgenerate

reg [7:0] process_state=PROCESS_RESET;
reg [7:0] init_reg_addr;
reg spi_wait;

initial begin
    $readmemh("../mem/adf4002_reg.list", adf4002_reg);
    // adf4002_reg[0]=24'h1f8093;
    // adf4002_reg[1]=24'h1f8092;
    // adf4002_reg[2]=24'h000004;
    // adf4002_reg[3]=24'h000a01;
    $readmemh("../mem/lmx2594_reg.list", lmx2594_reg);
end

always @(posedge clk)
case(process_state)
PROCESS_RESET:
begin
    RX_interrupt_clear<=0;
    spi_start<=0;
    receive_data_bytes<=2;
    spi_wait<=0;
    amp_en<=0;
    init_reg_addr<=0;
    if(rst_n)
        process_state<=ADF4002_INIT;   
end
ADF4002_INIT:
begin
    if(spi_ready[0])
    begin
        spi_dir<=0;
        spi_data_depth<=24;
        spi_data_tx<=adf4002_reg[init_reg_addr];
        spi_start[0]<=1;
        init_reg_addr<=init_reg_addr+1;
        if(init_reg_addr==4)
        begin
            init_reg_addr<=0;
            spi_start[0]<=0;
            process_state<=LMX2594_INIT;
        end
    end
end
LMX2594_INIT:
begin
    if(spi_ready[1])
    begin
        spi_dir<=0;
        spi_data_depth<=24;
        spi_data_tx<=lmx2594_reg[init_reg_addr];
        spi_start[1]<=1;
        init_reg_addr<=init_reg_addr+1;
        if(init_reg_addr==113)
        begin
            spi_start[1]<=0;
            amp_en<=1;
            if(debug_mode)
                process_state<=UART_DEBUG;
            else
                process_state<=NORMAL_OPERATION;
        end
    end
end
UART_DEBUG:
begin
    if(RX_interrupt)
    begin
        if((rx_byte[10] == 8'h55) && (rx_byte[9] == 8'h5D) 
        && (rx_byte[1] == 8'h0D) && (rx_byte[0] == 8'h0A)) //'head' and 'end' check 
        begin
            case(rx_byte[8])
            8'h01: // write adf4002
            begin
                spi_dir<=0;
                spi_data_depth<=24;
                spi_data_tx<={rx_byte[7],rx_byte[6],rx_byte[5]};
                spi_start[0]<=1;   
            end
            8'h02: // write lmx2594
            begin
                spi_dir<=0;
                spi_data_depth<=24;
                spi_data_tx<={rx_byte[7],rx_byte[6],rx_byte[5]};
                spi_start[1]<=1;   
            end
            8'h0a: //open amplifier power switch
            begin
                amp_en<=1;
            end
            8'h0b: //close amplifier power switch
            begin
                amp_en<=0;
            end
            8'hAA:// uart connection test
            begin
                send_data<= 80'h45504741204F4B210D0A;// FPGA OK!
                send_data_bytes<=10;
                start_tx<=1;
            end
            endcase
        end
        else
        begin
            send_data<= 64'h6572726F72210D0A; //'error!'
            send_data_bytes<=8;
            start_tx<=1;
        end
        RX_interrupt_clear<=1;
    end
    else
    begin
        spi_start<=0;
        RX_interrupt_clear<=0;
        start_tx<=0;
    end 

    if(spi_wait&&spi_ready) //a spi transmition is waiting to start
    begin
        spi_wait<=0;
        spi_start<=1;
    end   
end
NORMAL_OPERATION:
begin
    if(spi_listener_interrupt)
    case(fpga_spi_data[23:16])
    8'h00:
    begin
        amp_en<=fpga_spi_data[1];
    end
    endcase
end
endcase

endmodule
