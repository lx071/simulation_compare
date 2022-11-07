# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module

import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
import random

@cocotb.test()
async def adder_basic_test(dut):
    """Test for 5 + 10"""
    # 2000000times = 20000 * 100(2400bit) = 100000 * 20(480bit) = 40000 * 50(1200bit) = 10000 * 200(4800bit)

    await RisingEdge(dut.reset_i)

    # 2000packages = 2000 * 100 data
    for k in range(20000):
        data_package = 0
        # 3Bytes * 100 = 300Bytes = 2400bit 
        for j in range(100):
            data_item = j % 200
            op_item = 1
            data_package = (data_package << 24) + (data_item << 16) + (data_item << 8) + op_item
            pass
        dut.data.value = data_package
        dut.xmit_en.value = 1
        await FallingEdge(dut.xmit_en)

