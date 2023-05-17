`timescale 1ns/1ps


module wrapper#
(
    parameter CYCLE_NUM=5,
    parameter NUM=100,
    parameter ITEM_WIDTH = 16
)
(
output  wire [7:0] res_o
);

import "DPI-C" function void gen_tlm_data(output bit[NUM-1:0][ITEM_WIDTH-1:0] pkt, input int num);

bit clk_i, reset_i;

reg [7:0] A_s;
reg [7:0] B_s;


bit[NUM-1:0][ITEM_WIDTH-1:0]    payload_data;
int num = 0;
int item_num = NUM;

reg xmit_en;

bfm inst_bfm(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .A_s(A_s),
    .B_s(B_s),
    .res_o(res_o)
);

always #1 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    reset_i = 0;
end

always @(posedge clk_i) begin
    if(reset_i) begin
        A_s <= 0;
        B_s <= 0;
    end 
    else if(xmit_en) begin
        A_s <= payload_data[num][7:0];
        B_s <= payload_data[num][15:8];
        num = num + 1;
        //$display("res_o:", res_o);
    end
    if(num >= NUM) begin
        num = 0;
        xmit_en = ~xmit_en;
        //$display("xmit_en:", xmit_en);
        //$finish;
    end
end

initial begin
    xmit_en = 0;
    repeat(CYCLE_NUM) begin
        gen_tlm_data(payload_data, item_num);
        xmit_en = 1;
        wait(xmit_en==0);
    end
    $finish;
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end


endmodule