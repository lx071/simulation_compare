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

reg [7:0] fifo_A[NUM-1:0];
reg [7:0] fifo_B[NUM-1:0];

reg [7:0] A_s;
reg [7:0] B_s;

always #5 clk_i = ~clk_i;
bit clk_r;
always #1 clk_r = ~clk_r;

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

int wr_ptr = 0;
int rd_ptr = 0;
reg wr_en = 1;
reg rd_en = 0;
always @(posedge clk_r) begin
    
    if(reset_i) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
    end else begin   
        if(xmit_en && wr_en) begin
            
            data_item = data[wr_ptr];

            fifo_A[wr_ptr] <= data_item[7:0];
            fifo_B[wr_ptr] <= data_item[15:8];
            
            wr_ptr = wr_ptr + 1;
            if(wr_ptr>rd_ptr) begin
                rd_en <= 1;
            end else begin
                rd_en <= 0;
            end
        end
        if(wr_ptr >= NUM) begin
            wr_ptr = 0;
            wr_en = 0;
        end 
    end

end

always @(posedge clk_i) begin

    if(reset_i) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
    end else begin   
        if(rd_en) begin
            
            A_s <= fifo_A[rd_ptr];
            B_s <= fifo_B[rd_ptr];
            
            rd_ptr = rd_ptr + 1;
        end
        if(rd_ptr >= NUM) begin
            rd_ptr = 0;
            rd_en = 0;
            xmit_en = ~xmit_en;
            wr_en = 1;
        end 
    end
end

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule