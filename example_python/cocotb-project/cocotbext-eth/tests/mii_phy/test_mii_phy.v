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
module test_mii_phy
(
    inout  wire        phy_rst,
    inout  wire [3:0]  phy_txd,         //发送数据
    inout  wire        phy_tx_er,       //发送错误
    inout  wire        phy_tx_en,       //发送使能
    inout  wire        phy_tx_clk,      //发送时钟
    
    inout  wire [3:0]  phy_rxd,         //接收数据
    inout  wire        phy_rx_er,       //接收错误
    inout  wire        phy_rx_dv,       //接收数据有效
    inout  wire        phy_rx_clk       //接收时钟
);

initial begin
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule
