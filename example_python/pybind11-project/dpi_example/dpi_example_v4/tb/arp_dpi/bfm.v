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

`timescale 1ns / 1ps

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

parameter TOTAL_WIDTH = 336;
parameter TX_NUM = 28;
bit[TOTAL_WIDTH-1:0]    tx_payload_data;
bit[TOTAL_WIDTH-1-112:0]    tx_arp_payload_data;
bit[TOTAL_WIDTH-1:0]    rx_payload_data;
bit[TOTAL_WIDTH-1:TOTAL_WIDTH-112]  rx_hdr_data;
bit[TOTAL_WIDTH-113:0]    rx_arp_payload_data;

import "DPI-C" function void c_py_gen_data(output bit[TOTAL_WIDTH-1:0] pkt);
import "DPI-C" function void recv_data (input bit[TOTAL_WIDTH-1:0] data, int num);

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



reg tx_en;
reg rx_en;

wire tck;
wire rck;

assign tck = (tx_en)?clk:1'b0;
assign rck = (rx_en)?clk:1'b0;

initial begin   
    tx_en = 0;
    rx_en = 0;

    subnet_mask = 0;
    s_eth_hdr_valid = 0;
    s_eth_dest_mac = 0;
    s_eth_src_mac = 0;
    s_eth_type = 0;
    s_eth_payload_axis_tdata = 0;
    s_eth_payload_axis_tkeep = 0;
    s_eth_payload_axis_tvalid = 0;
    s_eth_payload_axis_tlast = 0;
    s_eth_payload_axis_tuser = 0;

    m_eth_hdr_ready = 1;
    m_eth_payload_axis_tready = 1;

    arp_request_valid = 0;
    arp_request_ip = 0;
    arp_response_ready = 0;

    local_mac = 0;
    local_ip = 0;
    gateway_ip = 0;
    subnet_mask = 0;
    clear_cache = 0;

    //$dumpfile("dump.vcd");
    //$dumpvars;
    
    local_mac = 48'hdad1d2d3d4d5;
    local_ip = 32'hc0a80165;
    gateway_ip = 32'hc0a80101;
    subnet_mask = 32'hffffff00;
     
    rst = 0;
    repeat(2) @(posedge clk);
    rst = 1;
    repeat(2) @(posedge clk);
    rst = 0;
    repeat(2) @(posedge clk);
    repeat(10) @(posedge clk);

    repeat(10000) begin
        tx_en = 1;
        @(negedge tx_en);
        rx_en = 1;
        @(negedge rx_en);
    end

    $finish;
end

reg[2:0] xmit_state = 0;
int tx_num = 0;
always @(posedge tck) begin
    case (xmit_state)
        0: begin

            c_py_gen_data(tx_payload_data);   
            //$display("get tx_payload_data ='h%h", tx_payload_data); 
    
            //$display("s_eth_dest_mac ='h%h", tx_payload_data[TOTAL_WIDTH-1:TOTAL_WIDTH-48]);
            //$display("s_eth_src_mac ='h%h", tx_payload_data[TOTAL_WIDTH-49:TOTAL_WIDTH-96]);
            //$display("s_eth_type ='h%h", tx_payload_data[TOTAL_WIDTH-97:TOTAL_WIDTH-112]);
            //$display("s_arp_htype ='h%h", tx_payload_data[TOTAL_WIDTH-113:TOTAL_WIDTH-128]);
            //$display("s_arp_ptype ='h%h", tx_payload_data[TOTAL_WIDTH-129:TOTAL_WIDTH-144]);

            //$display("s_arp_oper ='h%h", tx_payload_data[TOTAL_WIDTH-161:TOTAL_WIDTH-176]);
            //$display("s_arp_sha ='h%h", tx_payload_data[TOTAL_WIDTH-177:TOTAL_WIDTH-224]);
            //$display("s_arp_spa ='h%h", tx_payload_data[TOTAL_WIDTH-225:TOTAL_WIDTH-256]);
            //$display("s_arp_tha ='h%h", tx_payload_data[TOTAL_WIDTH-257:TOTAL_WIDTH-304]);
            //$display("s_arp_tpa ='h%h", tx_payload_data[TOTAL_WIDTH-305:TOTAL_WIDTH-336]);

            //$display("tx_arp_payload_data ='h%h", tx_payload_data[TOTAL_WIDTH-113:0]);

            s_eth_hdr_valid = 1;
            s_eth_dest_mac = tx_payload_data[TOTAL_WIDTH-1:TOTAL_WIDTH-48];
            s_eth_src_mac = tx_payload_data[TOTAL_WIDTH-49:TOTAL_WIDTH-96];
            s_eth_type = tx_payload_data[TOTAL_WIDTH-97:TOTAL_WIDTH-112];
            tx_arp_payload_data = tx_payload_data[TOTAL_WIDTH-113:0];

            s_eth_payload_axis_tkeep = 1;
            s_eth_payload_axis_tvalid = 1;
            s_eth_payload_axis_tdata = 0;

            xmit_state <= 1;

        end
        1: begin
            if(tx_num == 0) begin
                s_eth_hdr_valid = 0;
            end
            
            if(tx_num < TX_NUM) begin
                s_eth_payload_axis_tdata = tx_arp_payload_data[TOTAL_WIDTH-113:TOTAL_WIDTH-113-7];
                tx_arp_payload_data <<= 8;
                tx_num = tx_num + 1;
            end

            if(tx_num == TX_NUM) begin
                s_eth_payload_axis_tlast = 1;
                tx_num = tx_num + 1;
            end else if(tx_num == TX_NUM + 1) begin
                s_eth_payload_axis_tlast = 0;
                s_eth_payload_axis_tvalid = 0;
                tx_num = 0;
                xmit_state <= 0;
                tx_en <= 0;
                
            end

        end
    endcase
end

reg[2:0] recv_state = 0;
int rx_num = 0;
always @(posedge rck) begin
    case (recv_state)
        0: begin
            if(m_eth_hdr_valid == 1) begin
                //$display("m_eth_dest_mac ='h%h", m_eth_dest_mac);
                //$display("m_eth_src_mac ='h%h", m_eth_src_mac);
                //$display("m_eth_type ='h%h", m_eth_type);
                rx_hdr_data = {m_eth_dest_mac, m_eth_src_mac, m_eth_type};
                //$display("rx_hdr_data ='h%h", rx_hdr_data);
                recv_state <= 1;
            end

        end
        1: begin
            if(m_eth_payload_axis_tvalid == 1) begin
                //$display("m_eth_payload_axis_tdata ='h%h", m_eth_payload_axis_tdata);
                //recv_state <= 1;
                rx_arp_payload_data = {rx_arp_payload_data, m_eth_payload_axis_tdata};
                //$display("rx_arp_payload_data ='h%h", rx_arp_payload_data);

                if(m_eth_payload_axis_tlast == 1) begin
            
                    recv_state <= 0;                    
                    rx_en <= 0;
                    rx_payload_data = {rx_hdr_data, rx_arp_payload_data};
                    //$display("rx_payload_data ='h%h", rx_payload_data);
                    recv_data(rx_payload_data, 42);
                    
                    //$finish;
                end
            end
           
        end
    endcase

end


endmodule
