#include <iostream>
// 必须的头文件
#include <pthread.h>
#include <unistd.h>
using namespace std;
 
#define NUM_THREADS 2
 
// 线程的运行函数
void* say_A(void* args)
{
    cout << "Hello A！" << endl;
    sleep(1);
    cout << "Hello A end！" << endl;
    return 0;
}

// 线程的运行函数
void* say_B(void* args)
{
    cout << "Hello B！" << endl;
    cout << "Hello B end！" << endl;
    return 0;
}
 
int main()
{
    // 定义线程的 id 变量，多个变量使用数组
    pthread_t tids[NUM_THREADS];
    int ret1 = pthread_create(&tids[0], NULL, say_A, NULL);
    int ret2 = pthread_create(&tids[1], NULL, say_B, NULL);
    if (ret1 != 0 || ret2 != 0)
    {
       cout << "pthread_create error: error_code=" << ret1 <<" "<< ret2 << endl;
    }

    //等各个线程退出后，进程才结束，否则进程强制结束了，线程可能还没反应过来；
    pthread_exit(NULL);
}