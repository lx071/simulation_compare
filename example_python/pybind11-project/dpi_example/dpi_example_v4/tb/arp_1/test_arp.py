#!/usr/bin/env python
"""

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

"""

import itertools
import logging
import os

from scapy.layers.l2 import Ether, ARP
from scapy.utils import mac2str, atol

import pytest
import cocotb_test.simulator

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink
from cocotbext.axi.stream import define_stream

from scapy.all import *

EthHdrBus, EthHdrTransaction, EthHdrSource, EthHdrSink, EthHdrMonitor = define_stream("EthHdr",
    signals=["hdr_valid", "hdr_ready", "dest_mac", "src_mac", "type"]
)

ArpReqBus, ArpReqTransaction, ArpReqSource, ArpReqSink, ArpReqMonitor = define_stream("ArpReq",
    signals=["valid", "ready", "ip"]
)

ArpRespBus, ArpRespTransaction, ArpRespSource, ArpRespSink, ArpRespMonitor = define_stream("ArpResp",
    signals=["valid", "ready", "error", "mac"]
)


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        # cocotb.start_soon(Clock(dut.clk, 8, units="ns").start())

        self.header_source = EthHdrSource(EthHdrBus.from_prefix(dut, "s_eth"), dut.clk, dut.rst)
        self.payload_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_eth_payload_axis"), dut.clk, dut.rst)

        self.header_sink = EthHdrSink(EthHdrBus.from_prefix(dut, "m_eth"), dut.clk, dut.rst)
        self.payload_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_eth_payload_axis"), dut.clk, dut.rst)

        self.arp_req_source = ArpReqSource(ArpReqBus.from_prefix(dut, "arp_request"), dut.clk, dut.rst)
        self.arp_resp_sink = ArpRespSink(ArpRespBus.from_prefix(dut, "arp_response"), dut.clk, dut.rst)

        dut.local_mac.setimmediatevalue(0)
        dut.local_ip.setimmediatevalue(0)
        dut.gateway_ip.setimmediatevalue(0)
        dut.subnet_mask.setimmediatevalue(0)
        dut.clear_cache.setimmediatevalue(0)

    def set_idle_generator(self, generator=None):
        if generator:
            self.header_source.set_pause_generator(generator())
            self.payload_source.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            self.header_sink.set_pause_generator(generator())
            self.payload_sink.set_pause_generator(generator())

    async def reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)

    async def send(self, pkt):
        hdr = EthHdrTransaction()
        hdr.dest_mac = int.from_bytes(mac2str(pkt[Ether].dst), 'big')
        hdr.src_mac = int.from_bytes(mac2str(pkt[Ether].src), 'big')
        hdr.type = pkt[Ether].type

        await self.header_source.send(hdr)
        await self.payload_source.send(bytes(pkt[Ether].payload))

    async def recv(self):
        rx_header = await self.header_sink.recv()
        rx_payload = await self.payload_sink.recv()

        assert not rx_payload.tuser

        eth = Ether()
        eth.dst = rx_header.dest_mac.integer.to_bytes(6, 'big')
        eth.src = rx_header.src_mac.integer.to_bytes(6, 'big')
        eth.type = rx_header.type.integer
        rx_pkt = eth / bytes(rx_payload.tdata)

        return Ether(bytes(rx_pkt))


async def run_test(dut, idle_inserter=None, backpressure_inserter=None):

    tb = TB(dut)

    await tb.reset()

    tb.set_idle_generator(idle_inserter)
    tb.set_backpressure_generator(backpressure_inserter)

    local_mac = 'DA:D1:D2:D3:D4:D5'
    local_ip = '192.168.1.101'
    gateway_ip = '192.168.1.1'
    subnet_mask = '255.255.255.0'

    dut.local_mac.value = int.from_bytes(mac2str(local_mac), 'big')
    dut.local_ip.value = atol(local_ip)
    dut.gateway_ip.value = atol(gateway_ip)
    dut.subnet_mask.value = atol(subnet_mask)

    for k in range(10):
        await RisingEdge(dut.clk)

    # print("==============start=================")
    
    for i in range(10000):

        # tb.log.info("test ARP request")

        eth = Ether(src='5A:51:52:53:54:55', dst='FF:FF:FF:FF:FF:FF')
        arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=1,
            hwsrc='5A:51:52:53:54:55', psrc='192.168.1.100',
            hwdst='00:00:00:00:00:00', pdst='192.168.1.101')
        test_pkt = eth / arp

        await tb.send(test_pkt)

        # print("test_pkt:", test_pkt)

        # print("send:\n", hexdump(test_pkt))

        rx_pkt = await tb.recv()

        # print("receive:\n", hexdump(rx_pkt))

        # tb.log.info("RX packet: %s", repr(rx_pkt))

        assert rx_pkt[Ether].dst.casefold() == test_pkt[Ether].src.casefold()
        assert rx_pkt[Ether].src.casefold() == local_mac.casefold()
        assert rx_pkt[Ether].type == test_pkt[Ether].type
        assert rx_pkt[ARP].hwtype == test_pkt[Ether].hwtype
        assert rx_pkt[ARP].ptype == test_pkt[Ether].ptype
        assert rx_pkt[ARP].hwlen == test_pkt[Ether].hwlen
        assert rx_pkt[ARP].plen == test_pkt[Ether].plen
        assert rx_pkt[ARP].op == 2
        assert rx_pkt[ARP].hwsrc.casefold() == local_mac.casefold()
        assert rx_pkt[ARP].psrc == local_ip
        assert rx_pkt[ARP].hwdst.casefold() == test_pkt[ARP].hwsrc.casefold()
        assert rx_pkt[ARP].pdst == test_pkt[ARP].psrc

        for j in range(2):
            await RisingEdge(dut.clk)

    # print("===============================")

    # print("===============end================")



def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])


if cocotb.SIM_NAME:

    factory = TestFactory(run_test)
    # factory.add_option("idle_inserter", [None, cycle_pause])
    # factory.add_option("backpressure_inserter", [None, cycle_pause])
    factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


@pytest.mark.parametrize("data_width", [8, 16, 32, 64, 128, 256, 512])
def test_arp(request, data_width):
    dut = "arp"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "arp_eth_rx.v"),
        os.path.join(rtl_dir, "arp_eth_tx.v"),
        os.path.join(rtl_dir, "arp_cache.v"),
        os.path.join(rtl_dir, "lfsr.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = data_width
    parameters['KEEP_ENABLE'] = int(parameters['DATA_WIDTH'] > 8)
    parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8
    parameters['CACHE_ADDR_WIDTH'] = 2
    parameters['REQUEST_RETRY_COUNT'] = 4
    parameters['REQUEST_RETRY_INTERVAL'] = 300
    parameters['REQUEST_TIMEOUT'] = 800

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
