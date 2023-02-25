`timescale 1ns/1ps

module bfm(
input   clk_i,
input   reset_i,
input   [7:0] A_s,
input   [7:0] B_s,
output  reg [7:0] res_o
);

MyTopLevel inst_add(
    .io_A(A_s),
    .io_B(B_s),
    .io_X(res_o),
    .clk(clk_i),
    .reset(reset_i)
);

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule