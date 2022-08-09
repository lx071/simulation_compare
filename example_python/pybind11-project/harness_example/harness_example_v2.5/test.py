import random
import sys

from utils.harness_utils import simple_sim_test, sim
import time


def basic_test():
    time1 = time.time()
    s = sim('./hdl/', 'MyTopLevel.v')
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
    s = sim('./hdl/', 'MyTopLevel.v')
    time2 = time.time()
    # s.doPythonApi()
    # res = s.operation("add", 4, 5)
    # print(res)
    # s.setValue("clk", 0)
    s.set_clk_info("clk", 10)
    s.setValue("reset", 1)
    num = 0
    main_time = 0
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
                num = num + 1
            else:
                s.setValue("io_A", num % 100)
                s.setValue("io_B", num % 100)
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
    s = sim('./hdl/', 'MyTopLevel.v')
    time1 = time.time()
    s.doPythonApi()
    time2 = time.time()
    print('time:', time2-time1)


def do_bfm_test():
    time1 = time.time()
    s = sim('./hdl/', 'bfm.v')
    time2 = time.time()

    def put_data():
        data_all = 0
        for i in range(32):
            data = random.randint(0, 100)
            # print(data)
            data_all = (data_all << 8) + data

        bytes_val = data_all.to_bytes(32, 'big')
        # print(bytes_val)
        s.put_bytes(bytes_val)
        print("XXX")

    s.set_clk_info("clk_i", 10)
    s.setValue("reset_i", 1)
    num = 0
    cur_time = 0
    reset_time = 100
    put_time = 120
    while True:
        # if num > 31250:
        if num > 2:
            break
        if cur_time == reset_time:
            s.setValue("reset_i", 0)
        if cur_time == put_time:
            put_data()
            put_time = put_time + 32 * 10

            num = num + 1
        s.eval()
        s.sleep_cycles(5)
        cur_time = cur_time + 5

    s.deleteHandle()
    time3 = time.time()
    print('compile time:', time2 - time1)
    print('simulation time:', time3 - time2)
    pass


import threading
from utils.harness_utils import gen_msg


def do_clk_test():
    time1 = time.time()
    s = sim('./hdl/', 'bfm.v')
    time2 = time.time()
    # s.disableWave()

    # 设置获取message数据的回调函数名
    s.set_send_message_func("send_msg")

    def a():
        # 设置时钟信息(时钟端口名、时钟周期、运行周期数)  10ps*300=3000ps=3ns
        s.set_clk_info("clk_i", 10, 400000)

        s.deleteHandle()
        time3 = time.time()
        print('compile time:', time2 - time1)
        print('simulation time:', time3 - time2)
        pass

    def b():
        gen_msg()
        print("func b()")
        pass

    def func():
        # t1 = threading.Thread(target=a, args=())
        # t2 = threading.Thread(target=b, args=())
        b()
        a()
        # t2.start()
        # t1.start()

        pass

    func()
    print("end...")


if __name__ == '__main__':
    do_clk_test()
    pass

