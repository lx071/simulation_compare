# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module

import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
import random
from utils import join

class data_package:
    def __init__(self, item_attr_name, item_bit_width):
        self.item_attr_name = item_attr_name    # ['A', 'B']
        self.item_bit_width = item_bit_width    # [8, 8]
        self.data = []  # [[1, 2],...]
        pass

@cocotb.test()
async def adder_basic_test(dut):
    """Test for 5 + 10"""
    # 2000000times = 20000 * 100(2400bit) = 100000 * 20(480bit) = 40000 * 50(1200bit) = 10000 * 200(4800bit)

    await RisingEdge(dut.reset_i)

    item_attr_name = ['A', 'B', 'op']
    item_bit_width = [8, 8, 8]
    package = data_package(item_attr_name, item_bit_width)
    # 2000packages = 2000 * 100 data
    for k in range(200):
        package.data = []
        # 2bytes * 100 = 200bytes = 1600bit 
        for j in range(100):
            package.data.append([j, j, 1])
            pass
        value = join(package)
        dut.data.value = value
        dut.xmit_en.value = 1
        await FallingEdge(dut.xmit_en)

