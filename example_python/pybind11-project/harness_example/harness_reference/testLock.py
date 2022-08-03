from threading import Thread, Event, RLock
import time
import asyncio

event = Event()
lock = RLock()

time_start = time.time()


def light():
    i = 1
    while True:
        print('红灯正亮着')
        time.sleep(2)
        event.set()     # 绿灯亮
        print('time:', time.time()-time_start)
        print(f'绿灯{i}亮')
        event.clear()
        print(f'绿灯{i}暗')
        i = i + 1
        if i > 5:
            break
    # event.clear()


async def car(name):
    # time.sleep(3)
    # lock.acquire()
    j = 1
    while True:
        print("time:", time.time()-time_start)
        print(f'车{j}正在等绿灯')
        event.wait()    # 等灯绿 此时event为False,直到event.set()将其值设置为True,才会继续运行.
        print("time:", time.time()-time_start)
        print(f'车{j}通行')
        j = j + 1
        if j > 5:
            break
    # lock.release()


if __name__ == '__main__':
    # 红绿灯
    t1 = Thread(target=light)
    t1.start()
    # light()
    # 车
    # for i in range(10):
    #     t = Thread(target=car, args=(i,))
    #     t.start()
    asyncio.run(car("car1"))
    # await car("car1")
    print("pass")
