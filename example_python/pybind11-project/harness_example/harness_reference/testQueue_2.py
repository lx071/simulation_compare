import multiprocessing
q = multiprocessing.Queue()


def gen_msg():
    # 01 02 03 ... 20
    for j in range(311):
        data_all = 0
        for i in range(32):
            # data = random.randint(1, 100)
            # print(data)
            data = i % 100
            data_all = (data_all << 8) + data

        bytes_val = data_all.to_bytes(32, 'big')
        q.put(bytes_val)


def send_msg():
    data = q.get()
    print(data)
    pass


if __name__ == '__main__':
    drink_process = multiprocessing.Process(target=gen_msg)
    eat_process = multiprocessing.Process(target=send_msg)
 
    drink_process.start()
    eat_process.start()



