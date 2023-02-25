`timescale 1ns/1ps

module wrapper#(
    parameter int A1_NUMS = 50,
    parameter int B1_NUMS = 50,
    parameter int A2_NUMS = 50,
    parameter int B2_NUMS = 50
)(
//input   clk_i,
//input   reset_i,
output  reg [7:0] res_o
);

parameter NUM=100;

bit clk_i, reset_i;
int clk_num = 0;

int num = 0;
reg xmit_en = 0;

reg [7:0] A1[A1_NUMS];
reg [7:0] B1[B1_NUMS];
reg [7:0] A2[A2_NUMS];
reg [7:0] B2[B2_NUMS];

reg [7:0] A_s;
reg [7:0] B_s;


always #5 clk_i = ~clk_i;

initial begin
    clk_i = 0;
    reset_i = 1;
    
end


MyTopLevel inst_add(
    .io_A(A_s),
    .io_B(B_s),
    .io_X(res_o),
    .clk(clk_i),
    .reset(reset_i)
);

always @(posedge clk_i) begin

    if(clk_num<=10) begin
        clk_num = clk_num + 1;
    end 
    if(clk_num==10) begin
        reset_i = 0;
    end

    if(reset_i) begin
        A_s <= 8'h0;
        B_s <= 8'h0;
    end else begin   
        if(xmit_en) begin
            if(num < A1_NUMS) begin
                A_s <= A1[num];
                B_s <= B1[num];
            end else begin
                A_s <= A2[num - A1_NUMS];
                B_s <= B2[num - A1_NUMS];
            end
            
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