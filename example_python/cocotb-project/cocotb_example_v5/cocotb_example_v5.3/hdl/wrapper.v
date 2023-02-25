`timescale 1ns/1ps

module wrapper#(
    parameter int NUMS = 100
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

reg [15:0] data[NUMS];

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
            A_s <= data[num][7:0];
            B_s <= data[num][15:8];

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