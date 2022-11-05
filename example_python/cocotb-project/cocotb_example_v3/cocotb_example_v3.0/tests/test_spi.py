# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module

import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge, RisingEdge


async def generate_clock(dut):
    """Generate clock pulses."""
    dut.clk_i.value = 0
    # for cycle in range(100):
    while True:
        dut.clk_i.value = 0
        await Timer(5, units="ns")
        dut.clk_i.value = 1
        await Timer(5, units="ns")


async def generate_rst(dut):
    dut.reset_i.value = 1
    for cycle in range(10):
        await RisingEdge(dut.clk_i)
    dut.reset_i.value = 0


def send_msg():
    data_all = 0
    # 01 02 03 ... 20
    for i in range(32):
        # data = random.randint(1, 100)
        # print(data)
        data = (i + 1) % 100
        data_all = (data_all << 8) + data
    # print('data_all:', data_all)
    # bytes_val = data_all.to_bytes(32, 'big')
    return data_all
    pass


@cocotb.test()
async def spi_test(dut):
    """Test for 5 + 10"""
    await cocotb.start(generate_clock(dut))  # run the clock "in the background"
    await cocotb.start(generate_rst(dut))  # run the clock "in the background"

    await FallingEdge(dut.reset_i)

    for k in range(2000):
        await RisingEdge(dut.clk_i)
        dut.xmit_en.value = 1
        dut.dat_out_v.value = send_msg()
        await FallingEdge(dut.xmit_en)
