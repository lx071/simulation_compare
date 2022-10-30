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
 * GMII PHY test
 */
module bfm
(
    inout  wire        phy_rst,

    inout  wire [7:0]  phy_txd,
    inout  wire        phy_tx_er,
    inout  wire        phy_tx_en,
    //inout  wire        phy_tx_clk,

    inout  wire        phy_gtx_clk,
    
    inout  wire [7:0]  phy_rxd,
    inout  wire        phy_rx_er,
    inout  wire        phy_rx_dv
    //inout  wire        phy_rx_clk
);

bit phy_tx_clk;
bit phy_rx_clk;
always #20 phy_tx_clk = ~phy_tx_clk;
always #20 phy_rx_clk = ~phy_rx_clk;

test_gmii_phy test_gmii_phy(
    .phy_rst(phy_rst),
    .phy_txd(phy_txd),
    .phy_tx_er(phy_tx_er),
    .phy_tx_en(phy_tx_en),
    .phy_tx_clk(phy_tx_clk),

    .phy_gtx_clk(phy_gtx_clk),

    .phy_rxd(phy_rxd),
    .phy_rx_er(phy_rx_er),
    .phy_rx_dv(phy_rx_dv),
    .phy_rx_clk(phy_rx_clk)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end

endmodule
