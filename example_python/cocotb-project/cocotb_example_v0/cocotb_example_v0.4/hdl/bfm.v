`timescale 1ns/1ps

module bfm(
input   clk,
input   reset,
output  reg [7:0] res_o
);

reg [7:0] A_s;
reg [7:0] B_s;

parameter TOTAL_WIDTH=256;

//bit clk;
//always #5 clk = ~clk;

initial begin
    //clk = 0;
    A_s = 0;
    B_s = 0;
end

MyTopLevel inst_add(
    .io_A(A_s),
    .io_B(B_s),
    .io_X(res_o),
    .clk(clk),
    .reset(reset)
);


initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule