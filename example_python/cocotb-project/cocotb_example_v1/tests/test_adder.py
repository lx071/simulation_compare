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
        await Timer(5, units="ps")
        dut.clk_i.value = 1
        await Timer(5, units="ps")


async def generate_rst(dut):
    dut.reset_i.value = 1
    for cycle in range(10):
        await RisingEdge(dut.clk_i)
    dut.reset_i.value = 0

import random

@cocotb.test()
async def adder_basic_test(dut):
    """Test for 5 + 10"""
    # await cocotb.start(generate_clock(dut))  # run the clock "in the background"
    # await cocotb.start(generate_rst(dut))  # run the clock "in the background"
    
    await FallingEdge(dut.reset_i)

    # 2000packages = 2000 * 100 data
    for k in range(2000):
        data_package = 0
        # 2bytes * 100 = 200bytes = 1600bit 
        for j in range(100):
            data_item = j % 200
            data_package = (data_package << 16) + (data_item << 8) + data_item
            pass
        dut.data = data_package
        dut.xmit_en.value = 1
        await FallingEdge(dut.xmit_en)
        # await RisingEdge(dut.clk_i)

    # for i in range(110):
    #     await RisingEdge(dut.clk_i)
        # dut.data_all.value = 1
        # dut.A_s.value = i % 200
        # dut.B_s.value = i % 200

   