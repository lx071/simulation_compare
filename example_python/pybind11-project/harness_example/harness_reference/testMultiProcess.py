import multiprocessing
import time

def drink():
    for i in range(3):
        print("喝汤……")
        time.sleep(1)
 
def eat():
    for i in range(3):
        print("吃饭……")
        time.sleep(1)
 
if __name__ == '__main__':
    #target:指定函数名
    drink_process = multiprocessing.Process(target=drink)
    eat_process = multiprocessing.Process(target=eat)
 
    drink_process.start()
    eat_process.start()
