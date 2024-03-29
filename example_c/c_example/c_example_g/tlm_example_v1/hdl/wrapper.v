`timescale 1ns/1ps

module wrapper#(
    parameter integer RESET_DELAY=5,
    parameter NUM = 100,
    parameter ITEM_WIDTH = 24
)(
output  reg [15:0] res_o
);

import "DPI-C" context task testbench(input int item_num);
export "DPI-C" task set_data;

bit clk_i, reset_i;

reg start;
//reg [15:0] result;

reg [7:0] A_s;
reg [7:0] B_s;
reg [2:0] op_s;
reg done;

int num = 0;
int item_num = NUM;
reg tvalid;
reg tready;

reg xmit_en;

bit[NUM-1:0][ITEM_WIDTH-1:0]    payload_data;

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

always #5 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    //reset_i = 0;
    A_s = 0;
    B_s = 0;
    op_s = 0;
    start = 0;
    //data = 0;
    //repeat(RESET_DELAY) @(posedge clk_i);
    reset_i = 1;
end

always @(posedge clk_i) begin

    if(!reset_i) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
        op_s <= 3'h0;
    end else begin   

        if(tvalid==1 && tready==1) begin
            op_s <= payload_data[num][2:0];
            A_s <= payload_data[num][15:8];
            B_s <= payload_data[num][23:16];
            start <= 1;
            num = num + 1;
            //$display("res_o:", res_o);
        end
        if(num >= NUM) begin
            num = 0;
            xmit_en = ~xmit_en;
        end
    end
end

initial begin
    tready = 1;
    xmit_en = 0;
    testbench(item_num);
    $finish;
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

task set_data(bit[NUM-1:0][ITEM_WIDTH-1:0] data);
begin
    //$display("set_data");
    tvalid = 1;
    payload_data = data;
    xmit_en = 1;
    wait(xmit_en == 0);
end
endtask

endmodule