from queue import Queue
import threading
q = Queue()


def gen_msg():
    # 01 02 03 ... 20
    for j in range(31251):
        data_all = 0
        for i in range(32):
            # data = random.randint(1, 100)
            # print(data)
            data = i % 100
            data_all = (data_all << 8) + data

        bytes_val = data_all.to_bytes(32, 'big')
        q.put(bytes_val)


def send_msg():
    return q.get()
    pass


if __name__ == '__main__':
    gen_msg()
    num = 1000000/32
    for i in range(31251):
        send_msg()
    print(num)


