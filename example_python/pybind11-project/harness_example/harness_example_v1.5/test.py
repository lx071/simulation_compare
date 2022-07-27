import sys

from utils.harness_utils import simple_sim_test, sim
import time


def basic_test():
    time1 = time.time()
    s = sim('./hdl/', 'MyTopLevel.v', 'harness.cpp')
    time2 = time.time()
    simple_sim_test(s)
    time3 = time.time()
    print('compile time:', time2-time1)
    print('simulation time:', time3-time2)


def do_test():
    sys.path.append('utils')
    print(sys.path)
    time1 = time.time()
    # 传入dut所在目录、顶层模块文件名、生成 Wrapper文件名
    s = sim('./hdl/', 'MyTopLevel.v', 'harness.cpp')
    time2 = time.time()
    s.doPythonApi()
    s.setValue("clk", 0)
    s.setValue("reset", 1)
    num = 0
    main_time = 0
    reset_value = 1
    while True:
        if num >= 100:
            break
        if main_time == 20:
            s.setValue("reset", 0)
        if reset_value == 1:
            reset_value = s.getValue("reset")
        if reset_value == 0 and main_time % 5 == 0:
            if s.getValue("clk") == 0:
                s.setValue("clk", 1)
                s.setValue("io_A", num % 100)
                s.setValue("io_B", num % 100)
                num = num + 1
            else:
                s.setValue("clk", 0)
        main_time = main_time + 5
        # 执行硬件设计逻辑，得到当前状态(各端口值)
        s.eval()
        # dump记录当前状态(各个端口值), 并锁定, time+=5
        s.sleep_cycles(5)

    s.deleteHandle()
    time3 = time.time()
    print('compile time:', time2 - time1)
    print('simulation time:', time3 - time2)


def do_python_test():
    sys.path.append('utils')
    print(sys.path)
    s = sim('./hdl/', 'MyTopLevel.v', 'harness.cpp')
    time1 = time.time()
    s.doPythonApi()
    time2 = time.time()
    print('time:', time2-time1)


if __name__ == '__main__':
    # basic_test()
    # do_test()
    do_python_test()
    pass

