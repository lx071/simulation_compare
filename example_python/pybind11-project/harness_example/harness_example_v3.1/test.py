import random
import sys
from utils.harness_utils import sim, verilog_parse
import time


def do_clk_test():
    time1 = time.time()
    s = sim('./hdl/', 'PoseidonTopLevel.v')
    time2 = time.time()
    s.disableWave()
    # s.setValue("reset_i", 1)
    # 设置获取message数据的回调函数名
    s.set_send_message_func("send_msg")
    # 设置时钟信息(时钟端口名、时钟周期、运行周期数)  10ps*300=3000ps=3ns
    s.set_clk_info("clk", 10, 10020)

    s.deleteHandle()
    time3 = time.time()
    print('compile time:', time2 - time1)
    print('simulation time:', time3 - time2)
    pass


if __name__ == '__main__':
    # do_clk_test()
    input_ports_name, output_ports_name = verilog_parse('./hdl/', 'PoseidonTopLevel.v')
    print(input_ports_name)
    print(output_ports_name)
    pass

