# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module

import cocotb
from cocotb.triggers import FallingEdge, RisingEdge
import random
# from utils import join
import numpy as np

@cocotb.test()
async def adder_basic_test(dut):
    """Test for 5 + 10"""
    # 2000000times = 20000 * 100(1600bit) = 100000 * 20(320bit) = 40000 * 50(800bit) = 10000 * 200(3200bit)

    await FallingEdge(dut.reset_i)
    li = np.array([[i, i] for i in range(100)]).flatten().tolist()

    for k in range(20000):
        # 2bytes * 100 = 200bytes = 1600bit 
        dut.data.value = li
        
        dut.xmit_en.value = 1
        await FallingEdge(dut.xmit_en)
