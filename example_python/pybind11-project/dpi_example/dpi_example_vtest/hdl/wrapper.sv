import "DPI-C" function void gen_rand_arr(output bit [7:0] nums []);
import "DPI-C" function void recv (input int data);
import "DPI-C" function void c_py_gen_packet(output bit[254:0] pkt);
//import "DPI-C" function void c_py_gen_packet(output bit[4095:0] pkt);

`timescale 1ns/1ps


module wrapper(
//input   clk_i,
//input   reset_i,
output  reg [7:0] res_o
);

// 最高不能超过十亿bit
parameter int LENGTH = 2000; // byte

bit clk_i, reset_i;
//bit [7:0] data[LENGTH*2-1:0]; 
bit[254:0] data;

initial begin
    //gen_rand_arr(data);
    c_py_gen_packet(data);
    
    $display("get data[1] ='h%h",data[7:0]);
    $display("get data[1] ='h%h",data[15:8]);
    $display("get data[1] ='h%h",data[23:16]);
    $display("get data[1] ='h%h",data[31:24]);
    $display("get data[1] ='h%h",data[39:32]);
    $display("get data[31] ='h%h",data[247:240]);
    $display("get data[31] ='h%h",data[254:248]);
end

reg [7:0] A_s;
reg [7:0] B_s;

always #1 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    reset_i = 0;
    $display("XXX");
    recv(321);
    $display("YYY");
end

bfm inst_bfm(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .A_s(A_s),
    .B_s(B_s),
    .res_o(res_o)
);

int pointer = 0;

always @(posedge clk_i) begin
    if(reset_i)begin
        A_s <= 0;
        B_s <= 0;
    end
    else if(pointer < LENGTH) begin 
        A_s <= 1;
        B_s <= 2;
        pointer <= pointer + 1;
    end
end

always @(posedge clk_i) begin
    if(pointer==LENGTH) begin
        #2 $finish;
    end
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end

endmodule