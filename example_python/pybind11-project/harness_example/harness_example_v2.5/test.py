import random
import sys

from utils.harness_utils import sim
import time


import threading
from utils.harness_utils import gen_msg


def do_clk_test():
    time1 = time.time()
    s = sim('./hdl/', 'bfm.v')
    time2 = time.time()
    s.disableWave()

    # 设置获取message数据的回调函数名
    s.set_send_message_func("send_msg")

    def a():
        # 设置时钟信息(时钟端口名、时钟周期、运行周期数)  10ps*300=3000ps=3ns
        s.set_clk_info("clk_i", 10, 1000010)

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
        t1 = threading.Thread(target=a, args=())
        t2 = threading.Thread(target=b, args=())
        # b()
        # a()

        t1.start()
        t2.start()

        pass

    func()
    print("end...")


if __name__ == '__main__':
    do_clk_test()
    pass

