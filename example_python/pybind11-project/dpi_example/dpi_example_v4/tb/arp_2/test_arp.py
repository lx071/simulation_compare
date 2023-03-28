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

    # tb = TB(dut)

    # await tb.reset()
    dut.rst.setimmediatevalue(0)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # tb.set_idle_generator(idle_inserter)
    # tb.set_backpressure_generator(backpressure_inserter)

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

    for i in range(10000):
        # print("==============start=================")

        # tb.log.info("test ARP request")

        tx_eth = Ether(src='5A:51:52:53:54:55', dst='FF:FF:FF:FF:FF:FF')
        arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=1,
            hwsrc='5A:51:52:53:54:55', psrc='192.168.1.100',
            hwdst='00:00:00:00:00:00', pdst='192.168.1.101')
        tx_pkt = tx_eth / arp

        # FF FF FF FF FF FF            目的MAC
        # 5A 51 52 53 54 55            源MAC
        # 08 06                        帧类型,0806代表ARP协议帧
        # 注：后面是arp请求包
        # 00 01                        硬件类型，指链路层的网络类型，1为以太网
        # 08 00                        协议类型指要转换的地址类型，0x0800为IP地址 
        # 06                           硬件地址长度对于以太网地址为6字节，因为MAC地址是48位的
        # 04                           协议地址长度对于IP地址为4字节，因为IP地址是32位的
        # 00 01                        操作类型字段，op字段为1表示ARP请求，op字段为2表示ARP应答；值为3，表示进行RARP请求；值为4，表示进行RARP应答。InARP请求报文的操作码0x08，InARP回复报文的操作码0x09
        # 5A 51 52 53 54 55            源MAC
        # C0 A8 01 64                  源ip
        # 00 00 00 00 00 00            目的MAC
        # C0 A8 01 65                  目的ip

        # data = hexdump(tx_pkt)
        # print(data)
        # tx_pkt = raw(tx_pkt)   # 42Byte = 336bit   (14Byte for head)
        # print("tx_pkt:", tx_pkt)
        # print("len:", len(tx_pkt))
        res = int.from_bytes(tx_pkt, byteorder='big', signed=False)

        # print("tx_pkt[Ether].dst:", tx_pkt[Ether].dst)
        # print("mac2str(tx_pkt[Ether].dst):", mac2str(tx_pkt[Ether].dst))
        
        dut.tx_payload_data.value = res
        dut.tx_en.value = 1

        await FallingEdge(dut.tx_en)
        dut.rx_en.value = 1

        await FallingEdge(dut.rx_en)
        
        rx_eth = Ether()
        rx_eth.dst = dut.m_eth_dest_mac.value.integer.to_bytes(6, 'big')
        rx_eth.src = dut.m_eth_src_mac.value.integer.to_bytes(6, 'big')
        rx_eth.type = dut.m_eth_type.value.integer
        rx_pkt = rx_eth / bytes(dut.rx_arp_payload_data.value.integer.to_bytes(28, 'big'))
        rx_pkt = Ether(bytes(rx_pkt))

        # data = hexdump(rx_pkt)
        # print(data)

        # casefold可以将字符串中的大写字符转换为小写字符

        assert rx_pkt[Ether].dst.casefold() == tx_pkt[Ether].src.casefold()
        assert rx_pkt[Ether].src.casefold() == local_mac.casefold()
        assert rx_pkt[Ether].type == tx_pkt[Ether].type
        assert rx_pkt[ARP].hwtype == tx_pkt[Ether].hwtype
        assert rx_pkt[ARP].ptype == tx_pkt[Ether].ptype
        assert rx_pkt[ARP].hwlen == tx_pkt[Ether].hwlen
        assert rx_pkt[ARP].plen == tx_pkt[Ether].plen
        assert rx_pkt[ARP].op == 2
        assert rx_pkt[ARP].hwsrc.casefold() == local_mac.casefold()
        assert rx_pkt[ARP].psrc == local_ip
        assert rx_pkt[ARP].hwdst.casefold() == tx_pkt[ARP].hwsrc.casefold()
        assert rx_pkt[ARP].pdst == tx_pkt[ARP].psrc

        # return Ether(bytes(rx_pkt))
        # print("===============================")

        # print("===============end================")

        for j in range(3):
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
