#include <pybind11/embed.h>
#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include <dlfcn.h>
#include <unordered_map>
#include <iostream>
#include <memory>
#include <sys/time.h>
#include "svdpi.h"

// SystemC global header
#include <systemc.h>

#include <tlm.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

//typedef unsigned char uint8_t;
//typedef unsigned int uint32_t; 
//typedef uint8_t svScalar;
//typedef svScalar svBit;
//typedef uint32_t svBitVecVal;

namespace py=pybind11;

py::scoped_interpreter guard;

extern "C" __attribute__((visibility("default"))) void c_py_gen_data(svBitVecVal* data);
extern "C" __attribute__((visibility("default"))) void recv_data(svBitVecVal* data, int n);

extern "C" void set_data(const svBitVecVal* data);
extern "C" void gen_tlm_data(int num);

SC_MODULE(Target) { // 其实只是个target
public:
    tlm_utils::simple_target_socket<Target> socket;

    SC_CTOR(Target) : count(0) {
        socket.register_b_transport(this, &Target::b_transport);   //register methods with each socket
    }

private:
    int count;
    // char *payload_data;
    unsigned char* payload_data = nullptr;

    void b_transport(tlm::tlm_generic_payload& trans, sc_time& delay) {
        tlm::tlm_command cmd = trans.get_command();
        sc_dt::uint64 addr = trans.get_address();
        unsigned char* data = trans.get_data_ptr();
        unsigned int len = trans.get_data_length();
        unsigned char* byte_en = trans.get_byte_enable_ptr();
        unsigned int wid = trans.get_streaming_width();

        if (addr != 0x0) {
            trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
            return;
        }

        if (cmd == tlm::TLM_READ_COMMAND) {
            //std::cout << "read_len:" << len << std::endl;
            if (len != sizeof(count)) {
                trans.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
                return;
            }
            memcpy(data, &count, sizeof(count));
            trans.set_response_status(tlm::TLM_OK_RESPONSE);
        } else if (cmd == tlm::TLM_WRITE_COMMAND) {
            payload_data = data;
            //std::cout << "write_len:" << len << std::endl;
            // for(int i=0;i<len;i++) cout << std::hex << static_cast<int>(*(payload_data + i)) << endl;

            //  ‘const svBitVecVal*’ {aka ‘const unsigned int*’}
            const unsigned int* sv_data = reinterpret_cast<const unsigned int*>(payload_data);
            set_data(sv_data);
            
            trans.set_response_status(tlm::TLM_OK_RESPONSE);
        } else {
            trans.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);
            return;
        }
    }
};

SC_MODULE(Initiator) {
public:
    tlm_utils::simple_initiator_socket<Initiator> socket;

    SC_CTOR(Initiator) {
        // SC_THREAD(run);     //Similar to a Verilog @initial block
    }

    unsigned char *payload_data;

    void gen_tlm_data(int num)
    {
        tlm::tlm_generic_payload trans;
        // sc_time delay = sc_time(10, SC_NS);

        sc_time delay = SC_ZERO_TIME;

        payload_data = new unsigned char[num*2];

        for (int i = 0; i < num; i = i + 1) {
            payload_data[i*2] = i%100;
            payload_data[i*2+1] = i%100;
        }

        // set data
        trans.set_command(tlm::TLM_WRITE_COMMAND);
        trans.set_address(0x0);
        trans.set_data_ptr(reinterpret_cast<unsigned char*>(payload_data));
        trans.set_data_length(strlen((const char*)payload_data));
        socket->b_transport(trans, delay);

        assert(trans.is_response_ok());
    }
};

void recv_data(svBitVecVal* data, int n) 
{
    py::module_ sys = py::module_::import("sys");
    py::list path = sys.attr("path");
    path.attr("append")("../utils");    //for verilator
    // path.attr("append")("./utils");    //for galaxsim
    py::module_ utils = py::module_::import("harness_utils");
   
    size_t size_data = sizeof(data);
    
    auto res = py::array(py::buffer_info(
        data,                              // 数据指针
        sizeof(char),                      // 元素大小
        py::format_descriptor<char>::value, // 格式化描述符
        1,                                  // 维度
        { n },                           // 形状
        { sizeof(char) }                    // 每个维度的字节数
    ));
    
    utils.attr("recv_res")(res);

}

void c_py_gen_data(svBitVecVal* data) 
{
    py::module_ sys = py::module_::import("sys");
    py::list path = sys.attr("path");
    path.attr("append")("../utils");    //for verilator
    // path.attr("append")("./utils");    //for galaxsim
    py::module_ utils = py::module_::import("harness_utils");

    py::bytes result = utils.attr("send_data")();
    Py_ssize_t size = PyBytes_GET_SIZE(result.ptr());
    char * ptr = PyBytes_AsString(result.ptr());    //# low bit 01 02 03 ... 20 high bit

    memcpy(data, ptr, size);
}



#include <memory>
#include "svdpi.h"
#include "verilated.h"
#include "Vbfm.h"

using namespace std;

int sc_main(int argc, char** argv)
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