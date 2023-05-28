// 演示多线程的CPP程序
// 使用三个不同的可调用对象
#include <iostream>
#include <chrono>
#include <thread>
#include <functional>
using namespace std;
 
 
// 一个虚拟函数
void foo(int Z)
{
    for (int i = 0; i < Z; i++) {
        
        cout << "线程使用函数指针作为可调用参数\n";
    }
}
 
// 可调用对象
class thread_obj {
public:
    void operator()(int x)  // 重载运算符()
    {
        std::chrono::milliseconds dura( 2000 );
        
        for (int i = 0; i < x; i++)
        {   

            std::this_thread::sleep_for( dura );
            cout << "线程使用函数对象作为可调用参数\n";
            do_something(2);
        }
    }

    void do_something(int i)
    {
        cout << "do_something(" << i << ")" << endl;
    }

};
 
int main()
{
    cout << "线程 1 、2 、3 "
         "独立运行" << endl;
    
    thread_obj obj;
    thread th4([&obj]() {
        obj.do_something(4);
    });

    thread th5(std::bind(&thread_obj::do_something, &obj, 5));

    // 函数指针
    thread th1(foo, 3);
 
    // 函数对象
    thread th2(thread_obj(), 3);
 
    // 定义 Lambda 表达式
    auto f = [](int x) {
        for (int i = 0; i < x; i++)
            cout << "线程使用 lambda 表达式作为可调用参数\n";
    };
 
    // 线程通过使用 lambda 表达式作为可调用的参数
    thread th3(f, 3);
    
    
    
    // 等待线程完成
    // 等待线程 t1 完成
    th1.join();
 
    // 等待线程 t2 完成
    th2.join();
 
    // 等待线程 t3 完成
    th3.join();

    th4.join();

    th5.join();
 
    return 0;
}