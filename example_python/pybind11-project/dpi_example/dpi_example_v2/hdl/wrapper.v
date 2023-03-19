`timescale 1ns/1ps

module wrapper#(
    parameter integer RESET_DELAY=5,
    parameter int LENGTH = 2000000
)(
//input   clk_i,
//input   reset_i,
output  reg [15:0] res_o
);

import "DPI-C" function void gen_rand_arr(output bit [7:0] nums []);

bit clk_i, reset_i;

always #5 clk_i = ~clk_i;

reg start;
//reg [15:0] result;

reg [7:0] A_s;
reg [7:0] B_s;
reg [2:0] op_s;
reg done;

bit [7:0] data[LENGTH*3-1:0]; 

initial begin
    gen_rand_arr(data);
end

initial begin
    clk_i = 0;
    reset_i = 0;
    A_s = 0;
    B_s = 0;
    op_s = 0;
    start = 0;
    //data = 0;
    repeat(RESET_DELAY) @(posedge clk_i);
    reset_i = 1;
end

bfm inst_bfm(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .A_s(A_s),
    .B_s(B_s),
    .op_s(op_s),
    .start(start),
    .done(done),
    .res_o(res_o)
);

int pointer = 0;

always @(posedge clk_i) begin

    if(!reset_i) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
        op_s <= 3'h0;
    end else begin   
        
        op_s <= data[pointer*3+0][2:0];
        A_s <= data[pointer*3+1];
        B_s <= data[pointer*3+2];
        start <= 1;
        pointer = pointer + 1;
    end    

    if(pointer >= LENGTH) begin
        pointer = 0;
        #2 $finish;
    end 
end


initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule