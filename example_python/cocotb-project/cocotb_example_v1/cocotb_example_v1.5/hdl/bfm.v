`timescale 1ns/1ps

module bfm(
input   clk,
//input   reset_n,
output  reg [15:0] res_o
);

reg [7:0] A_s;
reg [7:0] B_s;
reg [2:0] op_s;

parameter PACKAGE_WIDTH=2400;
parameter NUM=100;
parameter RESET_DELAY=10;

bit reset_n;

//always #5 clk = ~clk;

reg xmit_en = 0;
reg [PACKAGE_WIDTH-1:0] data;
int num = 0;
int clk_num = 0;
reg start;
//reg [15:0] result;
reg done;

initial begin
    //clk = 0;
    reset_n = 0;
    A_s = 0;
    B_s = 0;
    op_s = 0;
    start = 0;
    data = 0;
    repeat(RESET_DELAY) @(posedge clk);
    reset_n = 1;
end

tinyalu inst_tinyalu(
    .clk(clk),
    .A(A_s),
    .B(B_s),
    .op(op_s),
    .reset_n(reset_n),
    .start(start),
    .done(done),
    .result(res_o)
);

always @(posedge clk) begin

    if(!reset_n) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
        op_s <= 3'h0;
        start <= 0;
    end else begin   
        if(xmit_en) begin
            op_s <= data[2:0];
            A_s <= data[15:8];
            B_s <= data[23:16];
            start <= 1;
            data = (data >> 24);
            num = num + 1;
        end    
        if(num >= NUM) begin
            num = 0;
            xmit_en = xmit_en - 1;
        end 

    end
end


initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule