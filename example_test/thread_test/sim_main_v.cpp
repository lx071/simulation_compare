#include <iostream>
#include "svdpi.h"

#include <thread>
#include <condition_variable>
#include <chrono>

#include "verilated.h"
#include "Vbfm.h"

using namespace std;

extern "C" void init();
extern "C" void kill();
extern "C" void finalize();

extern "C" void set_data();
extern "C" void get_data();

std::condition_variable cv;
std::mutex mtx;
bool output_ready = false;

class Initiator{
public:

    Initiator() {
        
    }

    void run(int k) {
        
        const svScope scope = svGetScopeFromName("TOP.bfm");
        assert(scope);  // Check for nullptr if scope not found
        svSetScope(scope);

        set_data();

        //wait signal
        std::unique_lock<std::mutex> lock(mtx);
        cv.wait(lock, [this] { return output_ready; });
        output_ready = false;
    
        finalize();
    }

    void init() {
        std::thread th(&Initiator::run, this, 5);
        myThread = std::move(th);
    }

    void kill() {
        myThread.join();
    }
    
private:
    
    std::thread myThread;
    
};

Initiator initiator;

void get_data() 
{
    cout << "get_data()" << endl;
    std::unique_lock<std::mutex> lock(mtx);
    output_ready = true;
    cv.notify_one();
}

void init() 
{
    initiator.init();
}

void kill()
{
    initiator.kill();
}

int main(int argc, char** argv)
{
    auto contextp {make_unique<VerilatedContext>()};
    // std::unique_ptr<VerilatedContext> contextp_;
    // Vwrapper* top_;
    contextp->commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    auto top {make_unique<Vbfm>(contextp.get())};
    while(!contextp->gotFinish()){
        top->eval();
        contextp->timeInc(4000);
    }

    return 0;
}