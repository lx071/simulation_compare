`timescale 1ns/1ps


module wrapper(
//input   clk_i,
//input   reset_i,
output  wire [7:0] res_o
);

// 最高不能超过十亿bit
parameter int LENGTH = 2000000; // byte

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

int pointer = 0;

always @(posedge clk_i) begin
    if(reset_i)begin
        A_s <= 0;
        B_s <= 0;
    end
    else if(pointer < LENGTH) begin 
        //A_s <= data[pointer*2+0];
        //B_s <= data[pointer*2+1];
        pointer <= pointer + 1;
    end
end

always @(posedge clk_i) begin
    if(pointer==LENGTH) begin
        #2 $finish;
    end
end

initial begin
    $display("Hello Add!");
    recv(6);
    $dumpfile("dump.vcd");
    $dumpvars;
end

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


function void send_bit_vec(bit[256:0] data);
begin
    $display("send_bit_vec side");
    $display("%h", data);
    $display(data[7:0]);
    $display(data[15:8]);
end
endfunction

endmodule