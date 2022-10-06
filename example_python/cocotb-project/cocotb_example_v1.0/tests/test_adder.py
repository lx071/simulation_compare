# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module

import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge, RisingEdge
import random
from cocotb.clock import Clock


async def generate_clock(dut):
    """Generate clock pulses."""
    dut.clk_i.value = 0
    # for cycle in range(100):
    while True:
        dut.clk_i.value = 0
        await Timer(5, units="ns")
        dut.clk_i.value = 1
        await Timer(5, units="ns")

@cocotb.test()
async def adder_basic_test(dut):
    """Test for 5 + 10"""
    # await cocotb.start(generate_clock(dut))  # run the clock "in the background"
    
    # c = Clock(dut.clk_i, 10, 'ns')
    # await cocotb.start(c.start())
    
    # 200000times = 2000 * 100(1600bit) = 10000 * 20(320bit) = 1000 * 200(3200bit)

    await FallingEdge(dut.reset_i)

    # 2000packages = 2000 * 100 data
    for k in range(2000):
        data_package = 0
        # 2bytes * 100 = 200bytes = 1600bit 
        for j in range(100):
            data_item = j % 200
            data_package = (data_package << 16) + (data_item << 8) + data_item
            pass
        dut.data.value = data_package
        dut.xmit_en.value = 1
        await FallingEdge(dut.xmit_en)
