`timescale 1ns/1ps

module wrapper#(
    parameter integer ITEM_WIDTH=16,
    parameter integer JOINT_N=100,
    parameter integer FIFO_N=20,
    parameter integer RESET_DELAY=5
)
(
//input   clk_i,
//input   reset_i,
output  reg [7:0] res_o
);

bit clk_i, reset_i;
int clk_num = 0;
reg [JOINT_N-1:0][ITEM_WIDTH-1:0] data[FIFO_N-1:0];

reg [ITEM_WIDTH-1:0] data_item;

int num = 0;
reg tvalid = 0;
reg tready = 1;
reg xmit_en = 0;

int wr_ptr = 0;
int rd_ptr = 0;
reg wr_en = 1;
reg rd_en = 0;

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

        if(wr_ptr > rd_ptr) begin 
            rd_en = 1;
        end else begin
            rd_en = 0;
        end

        if(rd_en && tvalid && tready) begin
            
            data_item = data[rd_ptr][num];

            A_s <= data_item[7:0];
            B_s <= data_item[15:8];
            
            num = num + 1;
        end
        if(num >= JOINT_N) begin
            num = 0;
            rd_ptr = rd_ptr + 1;

            if(rd_ptr >= FIFO_N) begin
                rd_ptr = 0; 
                xmit_en = ~xmit_en;            
            end
        end 
    end
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule