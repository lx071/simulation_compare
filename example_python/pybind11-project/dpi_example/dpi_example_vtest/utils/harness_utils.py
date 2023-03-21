import os
# import random
import subprocess
import re


def do_python_api():
    print('do_python_api')
    return 0


def add(a, b):
    return a + b


def recv(data):
    print("recv_python")
    print('recv_python:', data)


def send_msg():
    data_all = 0
    # 01 02 03 ... 20
    for i in range(512):
        # data = random.randint(1, 100)
        # print(data)
        data = i % 100
        data_all = (data_all << 8) + data

    bytes_val = data_all.to_bytes(512, 'big')
    return bytes_val
    pass



if __name__ == '__main__':
    pass
