`timescale 1ns/1ps

module bfm(
//input   clk_i,
//input   reset_i,
output  reg [15:0] res_o
);

reg [7:0] A_s;
reg [7:0] B_s;
reg [2:0] op_s;

parameter PACKAGE_WIDTH=2400;
parameter NUM=100;
parameter RESET_DELAY=10;

bit clk_i, reset_i;

always #5 clk_i = ~clk_i;

reg xmit_en = 0;
reg [PACKAGE_WIDTH-1:0] data;
int num = 0;
int clk_num = 0;
reg start;
//reg [15:0] result;

initial begin
    clk_i = 0;
    reset_i = 0;
    A_s = 0;
    B_s = 0;
    op_s = 0;
    start = 0;
    data = 0;
    repeat(RESET_DELAY) @(posedge clk_i);
    reset_i = 1;
end

tinyalu inst_tinyalu(
    .clk(clk_i),
    .A(A_s),
    .B(B_s),
    .op(op_s),
    .reset_n(reset_i),
    .start(start),
    .done(done),
    .result(res_o)
);

always @(posedge clk_i) begin

    if(!reset_i) begin
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