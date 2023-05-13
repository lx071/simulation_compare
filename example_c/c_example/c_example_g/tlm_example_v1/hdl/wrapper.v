`timescale 1ns/1ps

module wrapper#(
    parameter integer RESET_DELAY=5,
    parameter NUM = 100,
    parameter ITEM_WIDTH = 8
)(
output  reg [15:0] res_o
);

bit clk_i, reset_i;

always #5 clk_i = ~clk_i;

reg start;
//reg [15:0] result;

reg [7:0] A_s;
reg [7:0] B_s;
reg [2:0] op_s;
reg done;


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

int num = 0;
reg tvalid;
reg tready;

bit[NUM*3-1:0][ITEM_WIDTH-1:0]    payload_data;

always @(posedge clk_i) begin

    if(!reset_i) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
        op_s <= 3'h0;
    end else begin   

        if(tvalid==1 && tready==1) begin
            op_s <= payload_data[num*3+0][2:0];
            A_s <= payload_data[num*3+1];
            B_s <= payload_data[num*3+2];
            start <= 1;
            num = num + 1;
        end
        if(num >= NUM) begin
            num = 0;
            xmit_en = ~xmit_en;
        end
    end
end

import "DPI-C" context task testbench();
export "DPI-C" task set_data;

initial begin
    tready = 1;
    xmit_en = 0;
    testbench();
    $finish;
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

task set_data(bit[NUM*3-1:0][ITEM_WIDTH-1:0] data);
begin
    //$display("set_data");
    tvalid = 1;
    payload_data = data;
    xmit_en = 1;
    wait(xmit_en == 0);
end
endtask

endmodule