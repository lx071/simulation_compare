`timescale 1ns/1ps

module bfm(
input   clk_i,
output  reg [15:0] res_o
);

reg [7:0] A_s;
reg [7:0] B_s;
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


import "DPI-C" function void recv (input int data);
import "DPI-C" function void c_py_gen_packet(output bit[6143:0] pkt);


bit[6143:0] data;
reg xmit_en=0;

reg[15:0]   num = 0;
int clk_num=0;
int flag=0;
int message_num = 0;

reg en=1;
assign sck = (en)?clk_i:1'b1;

always @(posedge sck) begin
    if(clk_num<=10) clk_num = clk_num + 1;
    if(clk_num==10) reset_i=1;

    if(reset_i) begin
        //num = 0;
        //$display("num = %h",num);
        //if(message_num>=10) begin
        //    flag = flag + 1;
        //end

        if(flag == 0) begin
            //recv(456);
            c_py_gen_packet(data);
            xmit_en = 1;
            flag = flag + 1;
            message_num = message_num + 1;
        end

        if(xmit_en) begin
            A_s = data[7:0];
            B_s = data[15:8];
            op = data[18:16];

            //$display("get data[0] = %d",A_s);
            //$display("get data[1] = %d",B_s);
            //$display("get data[2] = %d",op);

            data = (data >> 24);
            num = num + 1;
            //$display("num = %h",num);
            //$display("xmit_en = %h",xmit_en);
        end

        if(num>=256) begin
            num = 0;
            xmit_en = xmit_en - 1;
            flag = flag - 1;
        end
    end

end

endmodule
