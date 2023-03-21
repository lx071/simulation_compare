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

    ref_input = 0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f
    ref_output = 0x132e0fb58f03f49eafd655b559cbf6e2bd371c269f8039cbd3fa6f6b17a29797
    print('%#x'%ref_input)
    bytes_val = ref_input.to_bytes(32, 'big')
    return bytes_val
    pass



if __name__ == '__main__':
    pass
