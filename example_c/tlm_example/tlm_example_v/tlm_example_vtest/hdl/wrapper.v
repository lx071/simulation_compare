`timescale 1ns/1ps


module wrapper#
(
    parameter CYCLE_NUM=5,
    parameter NUM=100,
    parameter ITEM_WIDTH = 16
)
(
output  wire [7:0] res_o
);

import "DPI-C" context function void gen_tlm_data(input int item_num);
export "DPI-C" function set_data;
export "DPI-C" function get_data_0;

bit clk_i, reset_i;

reg [7:0] A_s;
reg [7:0] B_s;

bit[NUM-1:0][ITEM_WIDTH-1:0]    payload_data;
int num = 0;
int item_num = NUM;
bit [254:0] ref_input;

reg xmit_en;

bfm inst_bfm(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .A_s(A_s),
    .B_s(B_s),
    .res_o(res_o)
);

always #1 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    reset_i = 0;
    ref_input = 255'h5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f;
end

always @(posedge clk_i) begin
    if(reset_i) begin
        A_s <= 0;
        B_s <= 0;
    end 
    else if(xmit_en) begin 
        A_s <= payload_data[num][7:0];
        B_s <= payload_data[num][15:8];
        num = num + 1;
        //$display("res_o:", res_o);
    end
    if(num >= NUM) begin
        num = 0;
        xmit_en = ~xmit_en;
        //$display("xmit_en:", xmit_en);
        //$finish;
    end
end


initial begin
    xmit_en = 0;
    repeat(CYCLE_NUM) begin
        gen_tlm_data(item_num);
        xmit_en = 1;
        wait(xmit_en==0);
    end
    $finish;
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

function void set_data(bit[NUM-1:0][ITEM_WIDTH-1:0] data);
begin
    payload_data = data;
    //tvalid = 1;
    //$display("%h", payload_data);
end
endfunction


function void get_data_0(output bit[254:0] data);
begin
    data = ref_input;
end
endfunction

endmodule