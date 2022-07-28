from threading import Thread, Event, RLock
import time
import asyncio

event = Event()
lock = RLock()


def light():
    print('红灯正亮着')
    # time.sleep(3)
    event.set()     # 绿灯亮
    event.set()     # 绿灯亮
    event.set()     # 绿灯亮
    event.set()     # 绿灯亮
    print('绿灯亮')
    # event.clear()


async def car(name):
    # time.sleep(3)
    # lock.acquire()
    print('车%s正在等绿灯' % name)
    event.wait()    # 等灯绿 此时event为False,直到event.set()将其值设置为True,才会继续运行.
    print('车%s通行' % name)
    # lock.release()


if __name__ == '__main__':
    # 红绿灯
    # t1 = Thread(target=light)
    # t1.start()
    light()
    # 车
    # for i in range(10):
    #     t = Thread(target=car, args=(i,))
    #     t.start()
    asyncio.run(car("car1"))
    # await car("car1")
    print("pass")
