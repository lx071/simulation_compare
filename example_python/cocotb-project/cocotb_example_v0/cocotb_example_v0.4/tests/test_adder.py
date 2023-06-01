# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module

import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import FallingEdge, RisingEdge


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
    dut.reset.value = 1
    for cycle in range(10):
        await RisingEdge(dut.clk)
    dut.reset.value = 0


@cocotb.test()
async def adder_basic_test(dut):
    """Test for 5 + 10"""
    # await cocotb.start(generate_clock(dut))  # run the clock "in the background"
    await cocotb.start(generate_rst(dut))  # run the clock "in the background"

    await FallingEdge(dut.reset)

    # 20000 * 100 data
    for k in range(2000000):
        await RisingEdge(dut.clk)
        dut.A_s.value = k % 200
        dut.B_s.value = k % 200

    # await Timer(2, units="ns")

    # assert dut.X.value == adder_model(
    #     A, B
    # ), f"Adder result is incorrect: {dut.X.value} != 15"
