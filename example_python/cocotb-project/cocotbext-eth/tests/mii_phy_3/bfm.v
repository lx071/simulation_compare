/*

Copyright (c) 2020 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ns

/*
 * MII PHY test
 */
module bfm
(

);

reg        phy_rst;
reg [3:0]  phy_txd;         //发送数据
reg        phy_tx_er;       //发送错误
reg        phy_tx_en;       //发送使能
bit        phy_tx_clk;      //发送时钟

reg [3:0]  phy_rxd;         //接收数据
reg        phy_rx_er;       //接收错误
reg        phy_rx_dv;       //接收数据有效
bit        phy_rx_clk;       //接收时钟

// 74Byte = 592bit
parameter TOTAL_WIDTH = 592;
parameter TX_NUM = 148;
bit[TOTAL_WIDTH-1:0]    payload_data;
reg[7:0]    item;
reg[3:0]    low_item;
reg[3:0]    high_item;
reg xmit_en = 0;

//bit phy_tx_clk;
//bit phy_rx_clk;
always #20 phy_tx_clk = ~phy_tx_clk;
always #20 phy_rx_clk = ~phy_rx_clk;

test_mii_phy test_mii_phy(
    .phy_rst(phy_rst),
    .phy_txd(phy_txd),
    .phy_tx_er(phy_tx_er),
    .phy_tx_en(phy_tx_en),
    .phy_tx_clk(phy_tx_clk),

    .phy_rxd(phy_rxd),
    .phy_rx_er(phy_rx_er),
    .phy_rx_dv(phy_rx_dv),
    .phy_rx_clk(phy_rx_clk)
);

initial begin   
    item = 0;
    high_item = 0;
    low_item = 0;
    phy_txd = 0;
    $dumpfile("dump.vcd");
    $dumpvars;
end

always @(posedge xmit_en) begin
    $display("payload_data:",payload_data);
    $display("get data ='h%h",payload_data[TOTAL_WIDTH-1:0]);
end

assign sck = (xmit_en)?phy_tx_clk:1'b0;
reg xmit_state = 0;
int num = 0;
always @(posedge sck) begin
    item = payload_data[TOTAL_WIDTH-1:TOTAL_WIDTH-8];
    
    //$display("get item ='h%h", item); 
    
    case (xmit_state)
        0: begin
            low_item = payload_data[TOTAL_WIDTH-5:TOTAL_WIDTH-8];
            phy_txd = low_item;
            //$display("get low_item ='h%h", low_item);
            xmit_state <= 1;
        end
        1: begin
            high_item = payload_data[TOTAL_WIDTH-1:TOTAL_WIDTH-4];
            phy_txd = high_item;
            //$display("get high_item ='h%h", high_item);
            payload_data <= (payload_data<<8);
            xmit_state <= 0;
        end
    endcase

    num = num + 1;
    if(num>=TX_NUM) begin
        xmit_en = xmit_en - 1;
    end

end

endmodule
