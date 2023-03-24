import "DPI-C" function void gen_rand_arr(output bit [7:0] nums []);
import "DPI-C" function void recv (input int data);
import "DPI-C" function void recv_res (input bit[254:0] data);
import "DPI-C" function void c_py_gen_packet(output bit[9:0][2:0][254:0] pkt);
//import "DPI-C" function void c_py_gen_packet(output bit[764:0] pkt);


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
//bit[764:0] data;  //255*3 = 765
bit[9:0][2:0][254:0] data;

parameter TOTAL_WIDTH = 336;
bit[TOTAL_WIDTH-1:0]    tx_payload_data;
import "DPI-C" function void c_py_gen_data(output bit[TOTAL_WIDTH-1:0] pkt);
import "DPI-C" function void recv_data (input bit[TOTAL_WIDTH-1:0] data);

initial begin
    //gen_rand_arr(data);
    c_py_gen_packet(data);
    
    $display("get data ='h%h",data[0][0]);
    $display("get data ='h%h",data[0][1]);
    //$display("get data ='h%h",data[0][2]);
    //$display("get data ='h%h",data[1][0]);
    
    recv_res(data[0][0]);
    recv_res(data[0][1]);

    c_py_gen_data(tx_payload_data);   
    $display("get data ='h%h", tx_payload_data); 
    
    recv_data(tx_payload_data);
    
end

reg [7:0] A_s;
reg [7:0] B_s;

always #1 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    reset_i = 0;
    recv(321);
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