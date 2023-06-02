#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>

std::mutex mtx;
std::condition_variable cv;
bool ready = false;
int value = 0;

void myFunction() {
    while (true) {
        std::unique_lock<std::mutex> lock(mtx);
        cv.wait(lock, [] { return ready; });
        std::cout << "Hello from thread! value = " << value << std::endl;
        value++;
        ready = false;
        cv.notify_one();
    }
}

int main() {
    std::thread myThread(myFunction);

    std::cout << "Hello from main!" << std::endl;

    while (true) {
        std::unique_lock<std::mutex> lock(mtx);
        ready = true;
        cv.notify_one();
       cv.wait(lock, [] { return !ready; });
        std::cout << "Hello from main! value = " << value << std::endl;
        value++;
    }

    myThread.join();

    return 0;
}