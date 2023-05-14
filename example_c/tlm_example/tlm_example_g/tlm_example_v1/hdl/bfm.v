`timescale 1ns/1ps

module bfm(
input   clk_i,
input   reset_i,
input   [7:0] A_s,
input   [7:0] B_s,
input   [2:0] op_s,
input   start,
output  done,
output  reg [15:0] res_o
);


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


initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule