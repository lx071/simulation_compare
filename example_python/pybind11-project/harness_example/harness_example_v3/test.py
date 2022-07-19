import subprocess
import sys

from utils.harness_utils import simple_sim_test, sim

import time
import os


def basic_test():
    time1 = time.time()
    s = sim('./hdl/', 'MyTopLevel.v', 'harness.cpp')
    time2 = time.time()
    simple_sim_test()
    time3 = time.time()
    print('compile time:', time2-time1)
    print('simulation time:', time3-time2)


def do_test():
    time1 = time.time()
    # 传入dut所在目录、顶层模块文件名、生成 Wrapper文件名
    s = sim('./hdl/', 'MyTopLevel.v', 'harness.cpp')
    time2 = time.time()

    s.setValue("clk", 0)
    s.setValue("reset", 1)
    main_time = 0
    num = 0
    reset_value = 1
    while True:
        if num >= 1000000:
            break
        if main_time == 100:
            s.setValue("reset", 0)
        if reset_value == 1:
            reset_value = s.getValue("reset")
        if reset_value == 0 and main_time % 5 == 0:
            if s.getValue("clk") == 0:
                s.setValue("clk", 1)
                s.setValue("io_A", num % 200)
                s.setValue("io_B", num % 200)
                num = num + 1
            else:
                s.setValue("clk", 0)
        s.eval()
        main_time = main_time + 1
    s.deleteHandle()
    time3 = time.time()
    print('compile time:', time2 - time1)
    print('simulation time:', time3 - time2)


if __name__ == '__main__':
    # basic_test()
    do_test()
    pass

