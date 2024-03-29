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
from cocotb.triggers import RisingEdge, FallingEdge
from cocotb.regression import TestFactory

from cocotbext.axi import AxiStreamBus, AxiStreamSink
from cocotbext.axi.stream import define_stream

from scapy.all import *

EthHdrBus, EthHdrTransaction, EthHdrSource, EthHdrSink, EthHdrMonitor = define_stream("EthHdr",
    signals=["hdr_valid", "hdr_ready", "dest_mac", "src_mac", "type"]
)

ArpHdrBus, ArpHdrTransaction, ArpHdrSource, ArpHdrSink, ArpHdrMonitor = define_stream("ArpHdr",
    signals=["frame_valid", "frame_ready", "eth_dest_mac", "eth_src_mac", "eth_type",
    "arp_htype", "arp_ptype", "arp_oper", "arp_sha", "arp_spa", "arp_tha", "arp_tpa"]
)


class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        # cocotb.start_soon(Clock(dut.clk, 8, units="ns").start())

        self.source = ArpHdrSource(ArpHdrBus.from_prefix(dut, "s"), dut.clk, dut.rst)

        self.header_sink = EthHdrSink(EthHdrBus.from_prefix(dut, "m_eth"), dut.clk, dut.rst)
        self.payload_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_eth_payload_axis"), dut.clk, dut.rst)

    def set_idle_generator(self, generator=None):
        if generator:
            self.source.set_pause_generator(generator())

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
        tx_frame = ArpHdrTransaction()
        tx_frame.eth_dest_mac = int.from_bytes(mac2str(pkt[Ether].dst), 'big')
        tx_frame.eth_src_mac = int.from_bytes(mac2str(pkt[Ether].src), 'big')
        tx_frame.eth_type = pkt[Ether].type
        tx_frame.arp_htype = pkt[ARP].hwtype
        tx_frame.arp_ptype = pkt[ARP].ptype
        tx_frame.arp_hlen = pkt[ARP].hwlen
        tx_frame.arp_plen = pkt[ARP].plen
        tx_frame.arp_oper = pkt[ARP].op
        tx_frame.arp_sha = int.from_bytes(mac2str(pkt[ARP].hwsrc), 'big')
        tx_frame.arp_spa = atol(pkt[ARP].psrc)
        tx_frame.arp_tha = int.from_bytes(mac2str(pkt[ARP].hwdst), 'big')
        tx_frame.arp_tpa = atol(pkt[ARP].pdst)

        await self.source.send(tx_frame)

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

    # tb.set_idle_generator(idle_inserter)
    # tb.set_backpressure_generator(backpressure_inserter)

    eth = Ether(src='5A:51:52:53:54:55', dst='DA:D1:D2:D3:D4:D5')
    arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=2,
        hwsrc='5A:51:52:53:54:55', psrc='192.168.1.100',
        hwdst='DA:D1:D2:D3:D4:D5', pdst='192.168.1.101')
    pkt = eth / arp

    # 0000  DA D1 D2 D3 D4 D5 5A 51 52 53 54 55 08 06 00 01  ......ZQRSTU....
    # 0010  08 00 06 04 00 02 5A 51 52 53 54 55 C0 A8 01 64  ......ZQRSTU...d
    # 0020  DA D1 D2 D3 D4 D5 C0 A8 01 65                    .........e
    # None

    # dad1d2d3d4d55a5152535455080600010800060400025a5152535455c0a80164dad1d2d3d4d5c0a80165
    
    # DA D1 D2 D3 D4 D5            目的MAC
    # 5A 51 52 53 54 55            源MAC
    # 08 06                        帧类型,0806代表ARP协议帧
    # 注：后面是arp应答包
    # 00 01                        硬件类型，指链路层的网络类型，1为以太网
    # 08 00                        协议类型指要转换的地址类型，0x0800为IP地址 
    # 06                           硬件地址长度对于以太网地址为6字节，因为MAC地址是48位的
    # 04                           协议地址长度对于IP地址为4字节，因为IP地址是32位的
    # 00 02                        操作类型字段，op字段为1表示ARP请求，op字段为2表示ARP应答；值为3，表示进行RARP请求；值为4，表示进行RARP应答。InARP请求报文的操作码0x08，InARP回复报文的操作码0x09
    # 5A 51 52 53 54 55            源MAC
    # C0 A8 01 64                  源ip
    # DA D1 D2 D3 D4 D5            目的MAC
    # C0 A8 01 65                  目的ip

    data = hexdump(pkt)
    print(data)
    # pkt = raw(pkt)   # 42Byte = 336bit   (14Byte for head)
    print("pkt:", pkt)
    print("len:", len(pkt))
    res = int.from_bytes(pkt, byteorder='big', signed=False)

    print("pkt[Ether].dst:", pkt[Ether].dst)
    print("mac2str(pkt[Ether].dst):", mac2str(pkt[Ether].dst))
    # dut.s_eth_dest_mac.value = int.from_bytes(mac2str(pkt[Ether].dst), 'big')
    # dut.s_eth_src_mac.value = int.from_bytes(mac2str(pkt[Ether].src), 'big')
    # dut.s_eth_type.value = pkt[Ether].type
    # dut.s_arp_htype.value = pkt[ARP].hwtype
    # dut.s_arp_ptype.value = pkt[ARP].ptype
    # # dut.s_arp_hlen.value = pkt[ARP].hwlen
    # # dut.s_arp_plen.value = pkt[ARP].plen
    # dut.s_arp_oper.value = pkt[ARP].op
    # dut.s_arp_sha.value = int.from_bytes(mac2str(pkt[ARP].hwsrc), 'big')
    # dut.s_arp_spa.value = atol(pkt[ARP].psrc)
    # dut.s_arp_tha.value = int.from_bytes(mac2str(pkt[ARP].hwdst), 'big')
    # dut.s_arp_tpa.value = atol(pkt[ARP].pdst)

    dut.payload_data.value = res
    dut.xmit_en.value = 1

    # await tb.send(test_pkt)

    # rx_pkt = await tb.recv()

    # tb.log.info("RX packet: %s", repr(rx_pkt))

    # assert bytes(rx_pkt) == bytes(test_pkt)

    # assert tb.header_sink.empty()
    # assert tb.payload_sink.empty()

    await FallingEdge(dut.m_eth_payload_axis_tlast)

    for i in range(2):
        await RisingEdge(dut.clk)


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
def test_arp_eth_tx(request, data_width):
    dut = "arp_eth_tx"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
    ]

    parameters = {}

    parameters['DATA_WIDTH'] = data_width
    parameters['KEEP_ENABLE'] = int(parameters['DATA_WIDTH'] > 8)
    parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8

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
