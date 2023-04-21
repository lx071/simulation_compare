`timescale 1ns/1ps


module wrapper(
output  wire [7:0] res_o
);

parameter NUM=100;
parameter ITEM_WIDTH = 8;

bit clk_i, reset_i;

reg [7:0] A_s;
reg [7:0] B_s;

always #1 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    reset_i = 0;
end

bfm inst_bfm(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .A_s(A_s),
    .B_s(B_s),
    .res_o(res_o)
);

import "DPI-C" function void gen_tlm_data(output bit[NUM*2-1:0][ITEM_WIDTH-1:0] pkt);

bit[NUM*2-1:0][ITEM_WIDTH-1:0]    payload_data;
int num = 0;

always @(posedge clk_i) begin
    if(reset_i) begin
        A_s <= 0;
        B_s <= 0;
    end 
    else if(num < NUM) begin 

        //$display("num:", num);
        A_s <= payload_data[num*2+0];
        B_s <= payload_data[num*2+1];
        num = num + 1;

    end
end

always @(posedge clk_i) begin
    if(num == NUM) begin
        #2 $finish;
    end
end

initial begin
    gen_tlm_data(payload_data);
    //$dumpfile("dump.vcd");
    //$dumpvars;
end


endmodule