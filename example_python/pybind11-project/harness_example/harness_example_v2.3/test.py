from utils.harness_utils import sim
import time


def do_clk_test():
    time1 = time.time()
    s = sim('./hdl/', 'bfm.v')
    time2 = time.time()
    s.disableWave()
    # 设置获取message数据的回调函数名
    s.set_send_message_func("send_msg")
    # 设置时钟信息(时钟端口名、时钟周期、运行周期数)  10ps*300=3000ps=3ns
    s.set_clk_info("clk_i", 10, 1000010)

    s.deleteHandle()
    time3 = time.time()
    print('compile time:', time2 - time1)
    print('simulation time:', time3 - time2)
    pass


if __name__ == '__main__':
    do_clk_test()
    pass

