`timescale 1ns/1ps

module wrapper#
(
    parameter NUM=100,
    parameter ITEM_WIDTH = 8

)(
input bit [ITEM_WIDTH-1:0] payload_data[NUM*2-1:0],
input reg tvalid,
output reg xmit_en,
output  wire [7:0] res_o
);


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
//reg tvalid;
reg tready;
//reg xmit_en;

always @(posedge clk_i) begin
    if(reset_i) begin
        A_s <= 0;
        B_s <= 0;
    end else begin
        //$display("tvalid:", tvalid);
        //$display("tready:", tready);
        //$display("xmit_en:", xmit_en);
        if(tvalid==1 && tready==1) begin
            //$display("num:", num);
            A_s <= payload_data[num*2+0];
            B_s <= payload_data[num*2+1];
            num = num + 1;
        end
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
    
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end

endmodule