`timescale 1ns/1ps


module wrapper(
//input   clk_i,
//input   reset_i,
output  wire [7:0] res_o
);

// 最高不能超过十亿bit
parameter int LENGTH = 2000000; // byte
parameter NUM=100;

bit clk_i, reset_i;
//bit [7:0] data[LENGTH*2-1:0]; 

reg [7:0] A_s;
reg [7:0] B_s;

always #1 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    reset_i = 0;
end

bfm inst_bfm(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .A_s(A_s),
    .B_s(B_s),
    .res_o(res_o)
);

int num = 0;

parameter TOTAL_WIDTH = 1600;
reg xmit_en = 0;
bit[199:0][7:0]    payload_data;

always @(posedge clk_i) begin
    if(reset_i) begin
        A_s <= 0;
        B_s <= 0;
    end else begin   
        if(xmit_en) begin
            A_s <= payload_data[num*2+0];
            B_s <= payload_data[num*2+1];
            num = num + 1;
        end
        if(num >= NUM) begin
            num = 0;
            xmit_en = xmit_en - 1;
            #2 $finish;
        end
    end
end


initial begin
    $display("Hello Add!");
    recv(6);
    testbench();  
    //$display("payload_data ='h%h", payload_data[TOTAL_WIDTH-1:0]);
    $dumpfile("dump.vcd");
    $dumpvars;
end

import "DPI-C" function void testbench();
import "DPI-C" context function void recv (input int data);
export "DPI-C" function send_long;
export "DPI-C" function send_bit;
export "DPI-C" function send_bit_vec;

function void send_long(longint data);
begin
    $display("send_long side");
    $display(data);
end
endfunction

function void send_bit(bit data);
begin
    $display("send_bit side");
    $display(data);
end
endfunction


function void send_bit_vec(bit[1599:0] data);
begin
    $display("send_bit_vec side");
    payload_data = data;
    xmit_en = xmit_en + 1;

    $display("%h", payload_data);
    //$display("payload_data[0]:", payload_data[0]);
    //$display("payload_data[1]:", payload_data[1]);
    //$display("payload_data[2]:", payload_data[2]);
    //$display("payload_data[3]:", payload_data[3]);
    //$display("payload_data[4]:", payload_data[4]);
    //$display(data[7:0]);
    //$display(data[15:8]);
end
endfunction

endmodule