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
 * ARP ethernet frame transmitter (ARP frame in, Ethernet frame out)
 */
module bfm #
(
    parameter DATA_WIDTH = 8,
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
)
(

);

reg                   rst;

/*
    * ARP frame input
    */
reg                   s_frame_valid;
reg                   s_frame_ready;
reg [47:0]            s_eth_dest_mac;
reg [47:0]            s_eth_src_mac;
reg [15:0]            s_eth_type;
reg [15:0]            s_arp_htype;
reg [15:0]            s_arp_ptype;
reg [15:0]            s_arp_oper;
reg [47:0]            s_arp_sha;
reg [31:0]            s_arp_spa;
reg [47:0]            s_arp_tha;
reg [31:0]            s_arp_tpa;

/*
    * Ethernet frame output
    */
reg                   m_eth_hdr_valid;
reg                   m_eth_hdr_ready;
reg [47:0]            m_eth_dest_mac;
reg [47:0]            m_eth_src_mac;
reg [15:0]            m_eth_type;
reg [DATA_WIDTH-1:0]  m_eth_payload_axis_tdata;
reg [KEEP_WIDTH-1:0]  m_eth_payload_axis_tkeep;
reg                   m_eth_payload_axis_tvalid;
reg                   m_eth_payload_axis_tready;
reg                   m_eth_payload_axis_tlast;
reg                   m_eth_payload_axis_tuser;

/*
    * Status signals
    */
reg                   busy;

parameter TOTAL_WIDTH = 336;
parameter TX_NUM = 42;
bit[TOTAL_WIDTH-1:0]    payload_data;

bit clk;
always #4 clk = ~clk;


arp_eth_tx #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH)
)
arp_eth_tx_inst 
(

    .clk(clk),
    .rst(rst),

    /*
     * ARP frame input
     */
    .s_frame_valid(s_frame_valid),
    .s_frame_ready(s_frame_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_arp_htype(s_arp_htype),
    .s_arp_ptype(s_arp_ptype),
    .s_arp_oper(s_arp_oper),
    .s_arp_sha(s_arp_sha),
    .s_arp_spa(s_arp_spa),
    .s_arp_tha(s_arp_tha),
    .s_arp_tpa(s_arp_tpa),

    /*
     * Ethernet frame output
     */
    .m_eth_hdr_valid(m_eth_hdr_valid),
    .m_eth_hdr_ready(m_eth_hdr_ready),
    .m_eth_dest_mac(m_eth_dest_mac),
    .m_eth_src_mac(m_eth_src_mac),
    .m_eth_type(m_eth_type),
    .m_eth_payload_axis_tdata(m_eth_payload_axis_tdata),
    .m_eth_payload_axis_tkeep(m_eth_payload_axis_tkeep),
    .m_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid),
    .m_eth_payload_axis_tready(m_eth_payload_axis_tready),
    .m_eth_payload_axis_tlast(m_eth_payload_axis_tlast),
    .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser),

    /*
     * Status signals
     */
    .busy(busy)

);


initial begin   
    s_frame_valid = 1'b0;
    //s_frame_ready = 1'b0;
    s_eth_dest_mac = 48'd0;
    s_eth_src_mac = 48'd0;
    s_eth_type = 16'd0;
    s_arp_htype = 16'd0;
    s_arp_ptype = 16'd0;
    s_arp_oper = 16'd0;
    s_arp_sha = 48'd0;
    s_arp_spa = 32'd0;
    s_arp_tha = 48'd0;
    s_arp_tpa = 32'd0;
    $display("get s_arp_tpa ='h%h", s_arp_tpa);

    $dumpfile("dump.vcd");
    $dumpvars;
end

reg xmit_en = 0;

assign tck = (xmit_en)?clk:1'b0;
assign rck = (xmit_en)?clk:1'b0;

reg xmit_state = 0;
int tx_num = 0;
reg tx_en = 0;
always @(posedge tck) begin
    case (xmit_state)
        0: begin
            s_eth_dest_mac = payload_data[TOTAL_WIDTH-1:TOTAL_WIDTH-48];
            s_eth_src_mac = payload_data[TOTAL_WIDTH-49:TOTAL_WIDTH-96];
            s_eth_type = payload_data[TOTAL_WIDTH-97:TOTAL_WIDTH-112];
            s_arp_htype = payload_data[TOTAL_WIDTH-113:TOTAL_WIDTH-128];
            s_arp_ptype = payload_data[TOTAL_WIDTH-129:TOTAL_WIDTH-144];
            
            s_arp_oper = payload_data[TOTAL_WIDTH-161:TOTAL_WIDTH-176];
            s_arp_sha = payload_data[TOTAL_WIDTH-177:TOTAL_WIDTH-224];
            s_arp_spa = payload_data[TOTAL_WIDTH-225:TOTAL_WIDTH-256];
            s_arp_tha = payload_data[TOTAL_WIDTH-257:TOTAL_WIDTH-304];
            s_arp_tpa = payload_data[TOTAL_WIDTH-305:TOTAL_WIDTH-336];

            s_frame_valid = 1;
            
            xmit_state <= 1;
            
        end
        1: begin
            
            xmit_state <= 0;
            xmit_en <= 0;
        end
    endcase
    

    //$display("get tx_item ='h%h", tx_item); 


end

endmodule
