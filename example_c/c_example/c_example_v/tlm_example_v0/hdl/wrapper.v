`timescale 1ns/1ps


module wrapper#
(
    parameter NUM=100,
    parameter ITEM_WIDTH = 8
)
(
output reg xmit_en,
output  wire [7:0] res_o
);


export "DPI-C" function set_data;

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

bit[NUM*2-1:0][ITEM_WIDTH-1:0]    payload_data;

always @(posedge clk_i) begin
    if(reset_i) begin
        A_s <= 0;
        B_s <= 0;
    end else begin
        if(tvalid==1 && tready==1) begin
            A_s <= payload_data[num*2+0];
            B_s <= payload_data[num*2+1];
            num = num + 1;
        end
        if(num >= NUM) begin
            num = 0;
            xmit_en = ~xmit_en;
        end
    end
end

initial begin
    tready = 1;
    xmit_en = 1;
    $dumpfile("dump.vcd");
    $dumpvars;
end

function void set_data(bit[NUM*2-1:0][ITEM_WIDTH-1:0] data);
begin
    payload_data = data;
    tvalid = 1;
    xmit_en = 0;
end
endfunction

endmodule