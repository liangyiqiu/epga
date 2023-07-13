module rst
#(
    parameter delay_cnt_1 = 10,
    parameter delay_cnt_2 = 24'hffffff //wait lmx2594 power on
)
(
    input clk,
    output reg rst_n=0,
    output reg ce_4002=0,
    output reg ce_2594=0
);

reg [31:0] clk_cnt=0;

always @(posedge clk) 
begin
    if(clk_cnt<=delay_cnt_1-1)
    begin
        rst_n<=0;
        ce_4002<=0;
        ce_2594<=0;
        clk_cnt<=clk_cnt+1;
    end
    else if(clk_cnt<=delay_cnt_2-1)
    begin
        ce_4002<=1;
        ce_2594<=1;
        clk_cnt<=clk_cnt+1;
    end
    else
    begin
        rst_n<=1;
    end
end

endmodule