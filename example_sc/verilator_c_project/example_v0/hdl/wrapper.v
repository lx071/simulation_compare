`timescale 1ns/1ps


module wrapper(
output  wire [7:0] res_o
);

parameter NUM=100;
parameter ITEM_WIDTH = 8;

bit clk_i, reset_i;

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
reg tvalid;
reg tready;
reg xmit_en;

bit[NUM*2-1:0][ITEM_WIDTH-1:0]    payload_data;

always @(posedge clk_i) begin
    if(reset_i) begin
        A_s <= 0;
        B_s <= 0;
    end else begin
        //$display("tvalid:", tvalid);
        //$display("tready:", tready);
        if(tvalid==1 && tready==1) begin
            //$display("num:", num);
            A_s <= payload_data[num*2+0];
            B_s <= payload_data[num*2+1];
            num = num + 1;
        end
        //$display("num:", num);
        if(num >= NUM) begin
            num = 0;
            xmit_en = ~xmit_en;
            //$display("xmit_en:", xmit_en);
            //$finish;
        end
    end
end

initial begin
    //tvalid = 0;
    tready = 1;
    xmit_en = 0;
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

//import "DPI-C" context function void testbench();
import "DPI-C" context function void recv (input int data);
export "DPI-C" function set_data;
export "DPI-C" function get_xmit_en;


function void set_data(bit[NUM*2-1:0][ITEM_WIDTH-1:0] data);
begin
    //$display("set_data");
    payload_data = data;
    tvalid = 1;
    //$display("%h", payload_data);
    //$display("payload_data[0]:", payload_data[0]);
    //$display("payload_data[1]:", payload_data[1]);
end
endfunction

function bit get_xmit_en();
begin
    //$display("get_xmit_en");
    return xmit_en;
end
endfunction

endmodule