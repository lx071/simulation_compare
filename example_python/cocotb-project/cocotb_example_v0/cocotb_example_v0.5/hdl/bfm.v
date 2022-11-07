`timescale 1ns/1ps

module bfm(
input   clk_i,
//input   reset_i,
output  reg [7:0] res_o
);

reg [7:0] A_s;
reg [7:0] B_s;

parameter PACKAGE_WIDTH=1600;
parameter NUM=100;

bit reset_i;

//always #5 clk_i = ~clk_i;

reg xmit_en = 0;
reg [PACKAGE_WIDTH-1:0] data;
int num = 0;
int clk_num = 0;

initial begin
    //clk_i = 0;
    reset_i = 1;
    A_s = 0;
    B_s = 0;
    data = 0;
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
            A_s <= data[7:0];
            B_s <= data[15:8];
            data = (data >> 16);
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