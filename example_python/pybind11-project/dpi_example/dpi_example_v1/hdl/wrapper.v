`timescale 1ns/1ps

module wrapper(
//input   clk_i,
//input   reset_i,
output  reg [7:0] res_o
);

parameter PACKAGE_WIDTH=2400;
parameter NUM=100;


bit clk_i, reset_i;

always #5 clk_i = ~clk_i;

reg xmit_en = 0;
reg [PACKAGE_WIDTH-1:0] data;
int num = 0;
int clk_num = 0;
reg start;
//reg [15:0] result;

reg [7:0] A_s;
reg [7:0] B_s;
reg [2:0] op_s;

initial begin
    clk_i = 0;
    reset_i = 0;
    A_s = 0;
    B_s = 0;
    op_s = 0;
    start = 0;
    data = 0;
end

bfm inst_bfm(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .A_s(A_s),
    .B_s(B_s),
    .op_s(op_s),
    .res_o(res_o)
);


always @(posedge clk_i) begin

    if(clk_num<=10) begin
        clk_num = clk_num + 1;
    end 
    if(clk_num==10) begin
        reset_i = 1;
    end

    if(!reset_i) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
        op_s <= 3'h0;
        start <= 0;
    end else begin   
        if(xmit_en) begin
            op_s <= data[2:0];
            A_s <= data[15:8];
            B_s <= data[23:16];
            start <= 1;
            data = (data >> 24);
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