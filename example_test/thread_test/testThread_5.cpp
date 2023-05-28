#include <iostream>
#include <thread>
#include <mutex>

class MyClass {
public:
    void runn(int k) {
        std::cout << "runn: " << k << std::endl;
    }

    void init() {
        std::unique_lock<std::mutex> lock(mtx);
        ready = false;
        std::thread th(&MyClass::runn, this, 4);
        myThread = std::move(th);
    }

    void wait() {
        std::unique_lock<std::mutex> lock(mtx);
        if (!ready) {
            myThread.join();
            ready = true;
        }
    }

private:
    std::mutex mtx;
    std::thread myThread;
    bool ready = true;
};

int main() {
    MyClass obj;

    std::cout << "Hello from main!" << std::endl;

    obj.init();
    obj.wait();

    std::cout << "Done!" << std::endl;

    return 0;
}