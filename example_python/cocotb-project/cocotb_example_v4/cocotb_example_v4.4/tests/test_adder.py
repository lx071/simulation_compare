# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
# Simple tests for an adder module

import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, Edge 
import random
from utils import join
import time

class data_package:
    def __init__(self, item_attr_name, item_bit_width):
        self.item_attr_name = item_attr_name    # ['A', 'B']
        self.item_bit_width = item_bit_width    # [8, 8]
        self.data = []  # [[1, 2],...]
        pass

@cocotb.test()
async def adder_basic_test(dut):
    """Test for 5 + 10"""
    # 2000000times = 20000 * 100(1600bit) = 100000 * 20(320bit) = 40000 * 50(800bit) = 10000 * 200(3200bit)

    await FallingEdge(dut.reset_i)

    item_attr_name = ['A', 'B']
    item_bit_width = [8, 8]
    package = data_package(item_attr_name, item_bit_width)
    # 2000packages = 2000 * 100 data
    t = 0
    
    repeat_n = 1000
    fifo_n = 20
    joint_n = 100
    
    for i in range(repeat_n):
        wr_ptr = 0

        # send package to fifo
        for k in range(fifo_n):
            
            await RisingEdge(dut.clk_i)

            # read handshake signals
            tready_sample = dut.tready.value
            tvalid_sample = dut.tvalid.value

            # valid/ready=00/01/11
            if (tready_sample and tvalid_sample) or not tvalid_sample:

                t1 = time.time()
                
                package.data = []
                # 2bytes * 100 = 200bytes = 1600bit
                package.data = [[i, i] for i in range(joint_n)] 
                
                value = join(package)
                t2 = time.time()
                t += (t2 - t1)

                dut.data[wr_ptr].value = value
                dut.tvalid.value = 1
                
                wr_ptr = wr_ptr + 1
                dut.wr_ptr.value = wr_ptr
                
        await Edge(dut.xmit_en)

    await RisingEdge(dut.clk_i)

    print("join_t:", t)