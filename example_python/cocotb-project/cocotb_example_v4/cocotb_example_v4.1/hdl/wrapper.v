`timescale 1ns/1ps

module wrapper#(
    parameter integer ITEM_WIDTH=16,
    parameter integer NUM=100,
    parameter integer RESET_DELAY=5
)
(
//input   clk_i,
//input   reset_i,
output  reg [7:0] res_o
);

bit clk_i, reset_i;
int clk_num = 0;
reg [NUM-1:0][ITEM_WIDTH-1:0] data;

reg [ITEM_WIDTH-1:0] data_item;

int num = 0;
reg xmit_en = 0;

reg [7:0] A_s;
reg [7:0] B_s;

always #5 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    reset_i = 1;
    repeat(RESET_DELAY) @(posedge clk_i);
    reset_i = 0;
    
end

bfm inst_bfm(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .A_s(A_s),
    .B_s(B_s),
    .res_o(res_o)
);

always @(posedge clk_i) begin

    if(reset_i) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
    end else begin   
        if(xmit_en) begin
            
            data_item = data[num];

            A_s <= data_item[7:0];
            B_s <= data_item[15:8];
            
            num = num + 1;
        end
        if(num >= NUM) begin
            num = 0;
            xmit_en = xmit_en - 1;
        end 
    end
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule