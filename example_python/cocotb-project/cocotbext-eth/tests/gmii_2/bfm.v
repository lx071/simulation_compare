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
 * GMII test
 */
module bfm #
(
    parameter DATA_WIDTH = 8
)
(
    //input  wire                   clk,
    input  wire                   rst,

    inout  wire [DATA_WIDTH-1:0]  gmii_d,
    inout  wire                   gmii_er,
    inout  wire                   gmii_en,
    inout  wire                   gmii_clk_en,
    inout  wire                   gmii_mii_sel
);

bit clk;
always #1 clk = ~clk;

test_gmii test_gmii(
    .clk(clk),
    .rst(rst),
    .gmii_d(gmii_d),
    .gmii_er(gmii_er),
    .gmii_en(gmii_en),
    .gmii_clk_en(gmii_clk_en),
    .gmii_mii_sel(gmii_mii_sel)
);

endmodule
