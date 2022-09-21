from utils.harness_utils import sim, gen_msg, finish_condition
import time
from multiprocessing import Process, Queue, Semaphore, Event


class sequence_item:
    def __init__(self):
        # self.finish_condition = Event()
        self.data = 0
        pass


def do_clk_test():
    time1 = time.time()
    s = sim('./hdl/', 'bfm.v')
    time2 = time.time()
    # s.disableWave()
    # 设置获取message数据的回调函数名
    s.set_send_message_func("send_msg")
    
    def a():
        # 设置时钟信息(时钟端口名、时钟周期、运行周期数)  10ps*300=3000ps=3ns
        s.set_clk_info("clk_i", 10, 1010)

        s.deleteHandle()
        time3 = time.time()
        print('compile time:', time2 - time1)
        print('simulation time:', time3 - time2)
        pass

    def b():
        item = sequence_item()
        gen_msg(item)
        print("wait finish_condition")
        finish_condition.wait()
        print("get finish_condition")
        # gen_msg()
        print("func b()")
        pass

    drink_process = Process(target=a)
    eat_process = Process(target=b)
 
    drink_process.start()
    eat_process.start()


if __name__ == '__main__':
    do_clk_test()
    pass

