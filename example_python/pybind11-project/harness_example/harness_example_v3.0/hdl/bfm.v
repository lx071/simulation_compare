`timescale 1ns/1ps

module bfm(
input   clk_i,
output  reg [15:0] res_o
);

reg [7:0] A_s=3;
reg [7:0] B_s=4;
reg [2:0] op=1;
reg reset_i=0;
reg start;
reg done;

parameter TOTAL_WIDTH=256;

tinyalu inst_alu(
    .clk(clk_i),
    .A(A_s),
	.B(B_s),
	.op(op),
	.reset_n(reset_i),
	.start(start),
	.done(done),
	.result(res_o)
);
int num=0;
import "DPI-C" function void recv (input int data);
import "DPI-C" function void c_py_gen_packet(output bit[6143:0] pkt);

bit[6143:0] data;

always @(posedge clk_i) begin
    if(num<=10) num = num + 1;
    if(num==10) begin
        reset_i=1;
        recv(456);
        c_py_gen_packet(data);
        $display("get data[0] ='h%h",data[7:0]);
        $display("get data[1] ='h%h",data[15:8]);
        $display("get data[2] ='h%h",data[23:16]);

        $display("get data[3] ='h%h",data[31:24]);
        $display("get data[4] ='h%h",data[39:32]);
        $display("get data[5] ='h%h",data[47:40]);

        $display("get data[6] ='h%h",data[55:48]);
        $display("get data[7] ='h%h",data[63:56]);
        $display("get data[8] ='h%h",data[71:64]);
    end

end

endmodule