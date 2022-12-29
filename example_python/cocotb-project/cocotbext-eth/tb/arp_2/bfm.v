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

/*
 * ARP block for IPv4, ethernet frame interface
 */
module bfm #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Log2 of ARP cache size
    parameter CACHE_ADDR_WIDTH = 9,
    // ARP request retry count
    parameter REQUEST_RETRY_COUNT = 4,
    // ARP request retry interval (in cycles)
    parameter REQUEST_RETRY_INTERVAL = 125000000*2,
    // ARP request timeout (in cycles)
    parameter REQUEST_TIMEOUT = 125000000*30
)
(
    
);

reg                   rst;

/*
    * Ethernet frame input
    */
reg                   s_eth_hdr_valid;
reg                   s_eth_hdr_ready;
reg [47:0]            s_eth_dest_mac;
reg [47:0]            s_eth_src_mac;
reg [15:0]            s_eth_type;
reg [DATA_WIDTH-1:0]  s_eth_payload_axis_tdata;
reg [KEEP_WIDTH-1:0]  s_eth_payload_axis_tkeep;
reg                   s_eth_payload_axis_tvalid;
reg                   s_eth_payload_axis_tready;
reg                   s_eth_payload_axis_tlast;
reg                   s_eth_payload_axis_tuser;

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
    * ARP requests
    */
reg                   arp_request_valid;
reg                   arp_request_ready;
reg [31:0]            arp_request_ip;
reg                   arp_response_valid;
reg                   arp_response_ready;
reg                   arp_response_error;
reg [47:0]            arp_response_mac;

/*
    * Configuration
    */
reg [47:0]            local_mac;
reg [31:0]            local_ip;
reg [31:0]            gateway_ip;
reg [31:0]            subnet_mask;
reg                   clear_cache;

bit clk;
always #4 clk = ~clk;

arp #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .CACHE_ADDR_WIDTH(CACHE_ADDR_WIDTH),
    .REQUEST_RETRY_COUNT(REQUEST_RETRY_COUNT),
    .REQUEST_RETRY_INTERVAL(REQUEST_RETRY_INTERVAL),
    .REQUEST_TIMEOUT(REQUEST_TIMEOUT)
)
arp_inst 
(
    .clk(clk),
    .rst(rst),

    /*
        * Ethernet frame input
        */
    .s_eth_hdr_valid(s_eth_hdr_valid),
    .s_eth_hdr_ready(s_eth_hdr_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_eth_payload_axis_tdata(s_eth_payload_axis_tdata),
    .s_eth_payload_axis_tkeep(s_eth_payload_axis_tkeep),
    .s_eth_payload_axis_tvalid(s_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(s_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast(s_eth_payload_axis_tlast),
    .s_eth_payload_axis_tuser(s_eth_payload_axis_tuser),

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
        * ARP requests
        */
    .arp_request_valid(arp_request_valid),
    .arp_request_ready(arp_request_ready),
    .arp_request_ip(arp_request_ip),
    .arp_response_valid(arp_response_valid),
    .arp_response_ready(arp_response_ready),
    .arp_response_error(arp_response_error),
    .arp_response_mac(arp_response_mac),

    /*
        * Configuration
        */
    .local_mac(local_mac),
    .local_ip(local_ip),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask),
    .clear_cache(clear_cache)
);

initial begin   
    //$dumpfile("dump.vcd");
    //$dumpvars;
end

endmodule
