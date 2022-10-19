# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module

import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge, RisingEdge
import random

async def generate_clock(dut):
    """Generate clock pulses."""
    dut.clk.value = 0
    # for cycle in range(100):
    while True:
        dut.clk.value = 0
        await Timer(5, units="ns")
        dut.clk.value = 1
        await Timer(5, units="ns")


async def generate_rst(dut):
    dut.reset_n.value = 0
    for cycle in range(10):
        await RisingEdge(dut.clk)
    dut.reset_n.value = 1

@cocotb.test()
async def adder_basic_test(dut):
    """Test for 5 + 10"""
    # 2000000times = 20000 * 100(1600bit) = 100000 * 20(320bit) = 40000 * 50(800bit) = 10000 * 200(3200bit)

    await cocotb.start(generate_clock(dut))  # run the clock "in the background"
    await cocotb.start(generate_rst(dut))  # run the clock "in the background"

    await RisingEdge(dut.reset_n)

    for k in range(2000000):
        await RisingEdge(dut.clk)
        dut.start.value = 1
        dut.A.value = k % 200
        dut.B.value = k % 200
        dut.op.value = 1
        