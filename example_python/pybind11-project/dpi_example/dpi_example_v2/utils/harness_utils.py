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
    # print("type(data):", type(data))
    # print("type(data):", type(data[0]))
    res = 0
    ref_output = 0x132e0fb58f03f49eafd655b559cbf6e2bd371c269f8039cbd3fa6f6b17a29797
    for i in range(8):
        res = res + (int(data[i]) << (32 * i))
    if(res != ref_output):
        print("test fail !!!")


def send_msg():

    ref_input_0 = 0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f
    ref_input_1 = 0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f
    ref_input_2 = 0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f
    ref_output = 0x132e0fb58f03f49eafd655b559cbf6e2bd371c269f8039cbd3fa6f6b17a29797

    # ref_input = (ref_input_0 << 510) + (ref_input_1 << 255) + ref_input_2
    ref_input = 0
    for i in range(300):
        ref_input = (ref_input << 255) + ref_input_0

    # print('%#x'%ref_input)
    bytes_val = ref_input.to_bytes(9563, 'little')
    return bytes_val
    pass



if __name__ == '__main__':
    pass
