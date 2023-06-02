#include <iostream>
#include <condition_variable>
#include <thread>
#include <chrono>
 
std::condition_variable cv;
std::mutex cv_m; // This mutex is used for three purposes:
                 // 1) to synchronize accesses to i
                 // 2) to synchronize accesses to std::cerr
                 // 3) for the condition variable cv
int i = 0;
 
/*
void wait( std::unique_lock<std::mutex>& lock )

先 unlock 之前获得的 mutex, 然后阻塞当前的执行线程
把当前线程添加到等待线程列表中, 该线程会持续 block 直到被 notify_all() 或 notify_one() 唤醒
被唤醒后, 该 thread 会重新获取 mutex, 获取到 mutex 后执行后面的动作

void wait( std::unique_lock<std::mutex>& lock, Predicate pred );
只有当 pred 为 false 时, wait 才会阻塞当前线程 
线程被唤醒后, 先重新判断 pred 的值. 如果 pred 为 false, 则会释放 mutex 并重新阻塞在 wait
*/

//[]{return i == 1;}：lambda表达式，检查变量i是否等于1，如果满足条件，则返回true，否则返回false。
void waits()
{
    std::unique_lock<std::mutex> lk(cv_m);
    std::cerr << "Waiting... \n";
    cv.wait(lk, []{return i == 1;});   //wait函数时会自动释放互斥锁lk，以便其他线程可以访问共享资源
    std::cerr << "...finished waiting. i == 1\n";
}
 
// std::chrono::nanoseconds
// std::chrono::microseconds
// std::chrono::milliseconds
// std::chrono::seconds
// std::chrono::minutes
// std::chrono::hours
void signals()
{
    std::this_thread::sleep_for(std::chrono::seconds(1));
    {
        std::lock_guard<std::mutex> lk(cv_m);
        std::cerr << "Notifying...\n";
    }
    cv.notify_all();
 
    std::this_thread::sleep_for(std::chrono::seconds(1));
 
    {
        std::lock_guard<std::mutex> lk(cv_m);
        i = 1;
        std::cerr << "Notifying again...\n";
    }
    cv.notify_all();
}

// 线程t1、t2和t3在waits函数中等待条件变量cv被通知。在等待期间，它们使用互斥锁cv_m保护共享变量i，以避免竞态条件的发生。
// 当条件变量被通知并且i==1时，它们会输出一条消息"...finished waiting. i == 1"，然后结束线程。
// 线程t4在signals函数中等待1秒钟后，通知所有等待条件变量cv的线程。然后等待1秒钟后，将变量i的值设置为1，并再次通知所有等待条件变量的线程。
int main()
{
    std::thread t1(waits), t2(waits), t3(waits), t4(signals);
    t1.join(); 
    t2.join(); 
    t3.join();
    t4.join();
}