`timescale 1ns/1ps


module wrapper(
output  wire [7:0] res_o
);

parameter NUM=1000;
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

import "DPI-C" context task testbench();
export "DPI-C" task set_data;

bit[NUM*2-1:0][ITEM_WIDTH-1:0]    payload_data;
int num = 0;

reg xmit_en;

always @(posedge clk_i) begin
    if(reset_i) begin
        A_s <= 0;
        B_s <= 0;
    end 
    else if(xmit_en) begin 

        //$display("num:", num);
        A_s <= payload_data[num*2+0];
        B_s <= payload_data[num*2+1];
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
    testbench();
    $finish;
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

task set_data(bit[NUM*2-1:0][ITEM_WIDTH-1:0] data);
begin
    //$display("set_data");
    payload_data = data;
    xmit_en = 1;
    wait(xmit_en == 0);
end
endtask

endmodule