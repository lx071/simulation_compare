`timescale 1ns/1ps

module bfm(
input   clk_i,
input   reset_i,
output  reg [7:0] res_o
);

reg [7:0] A_s;
reg [7:0] B_s;

parameter TOTAL_WIDTH=256;

MyTopLevel inst_add(
    .io_A(A_s),
    .io_B(B_s),
    .io_X(res_o),
    .clk(clk_i),
    .reset(reset_i)
);

reg xmit_en;
reg[15:0]    num = 0;

import "DPI-C" function void recv (input int data);
//import "DPI-C" function void c_py_gen_packet(output bit[2047:0] pkt);
import "DPI-C" function void c_py_gen_packet(output bit[4095:0] pkt);

//bit [15:0][127:0] data;
//bit[2047:0] data;
bit[4095:0] data;


int flag=0;
int message_num = 0;
always @(posedge clk_i or posedge reset_i) begin
    if(reset_i) begin
        A_s = 8'h0;
        B_s = 8'h0;
    end else begin
        //if(message_num>3907) begin
        //    flag = flag + 1;
        //end
        if(flag == 0) begin
            c_py_gen_packet(data);
            xmit_en = xmit_en + 1;
            flag = flag + 1;
            message_num = message_num + 1;
        end
        if(xmit_en) begin
            //$display("get data[0] ='h%h",data[7:0]);
            //$display("get data[1] ='h%h",data[15:8]);
            //$display("get data[255] ='h%h",data[2047:2040]);
            A_s = data[7:0];
            B_s = data[7:0];
            data = (data >> 8);
            num = num + 1;
        end
        if(num >= 512) begin
            num = 0;
            xmit_en = xmit_en - 1;
            //recv(666);
            flag = flag - 1;
        end
    end
end

endmodule