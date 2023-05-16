`timescale 1ns/1ps

module test_adder();

reg [7:0] A_s;
reg [7:0] B_s;
reg [2:0] op_s;

parameter TOTAL_WIDTH=256;

reg clk;
reg reset_i;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

reg start;
wire done;
wire [15:0] res_o;

initial begin
    //clk = 0;
    reset_i = 0;
    A_s = 0;
    B_s = 0;
    op_s = 0;
    start = 0;
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

initial begin

    #100
    reset_i = 1;

    repeat(2000000) begin
        @(posedge clk) begin
            op_s <= 1;
            start <= 1;
            A_s <= (A_s + 8'd1) % 200;
            B_s <= (B_s + 8'd1) % 200;
        end
    end

    $finish;

end

tinyalu inst_tinyalu(
    .clk(clk),
    .A(A_s),
    .B(B_s),
    .op(op_s),
    .reset_n(reset_i),
    .start(start),
    .done(done),
    .result(res_o)
);

endmodule