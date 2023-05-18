// -*- SystemC -*-
// DESCRIPTION: Verilator Example: Top level main for invoking SystemC model
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// SystemC global header
#include <systemc.h>

#include <tlm.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include "svdpi.h"
#include <string.h>
#include <iostream>

using namespace std;

extern "C" void set_data(const svBitVecVal* data);
extern "C" void testbench(int num);

extern "C" void c_py_gen_packet(svBitVecVal* data);
extern "C" void recv_res(svBitVecVal* data);

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

    SC_CTOR(Initiator){
        //SC_THREAD(run);     //Similar to a Verilog @initial block
    }

    unsigned char *arr;

    // typedef unsigned __int32 uint32_t;
    // typedef uint32_t svBitVecVal;
    void send_tlm_data(int num)
    {
        tlm::tlm_generic_payload trans;
        // sc_time delay = sc_time(10, SC_NS);

        sc_time delay = SC_ZERO_TIME;
        //int num = 1000;
        arr = new unsigned char[num*2];

        for (int i = 0; i < num; i = i + 1) {
            arr[i*2] = i%100;
            arr[i*2+1] = i%100;
        }
        // unsigned char arr[] = {0x1, 0x2, 0x3, 0x4, 0x5};
        unsigned char *payload_data = arr;

        // set data
        trans.set_command(tlm::TLM_WRITE_COMMAND);
        trans.set_address(0x0);
        trans.set_data_ptr(reinterpret_cast<unsigned char*>(payload_data));
        trans.set_data_length(strlen((const char*)payload_data));
        socket->b_transport(trans, delay);

        assert(trans.is_response_ok());

        // memcpy(data, payload_data, num*2);
    }
};


void testbench(int item_num)
{
    Target target("target");
    Initiator initiator("initiator");

    static bool initialized = false;
    if (!initialized) {
        initiator.socket.bind(target.socket);
        initialized = true;
    }
    int cycle_num = 2000;
    // int item_num = 100;
    for(int i = 0; i < cycle_num; i++)
    {
        initiator.send_tlm_data(item_num);
    }
}


void c_py_gen_packet(svBitVecVal* data) 
{
    //py::scoped_interpreter guard;
    // py::module_ sys = py::module_::import("sys");
    // py::list path = sys.attr("path");
    // path.attr("append")("../utils");
    // py::module_ utils = py::module_::import("harness_utils");

    // std::cout<<"c_py_gen_packet_cpp"<<std::endl;
    // //static unsigned char tmp[32] = {{0}};
    // py::bytes result = utils.attr("send_msg")();
    // Py_ssize_t size = PyBytes_GET_SIZE(result.ptr());
    // char * ptr = PyBytes_AsString(result.ptr());    //# low bit 01 02 03 ... 20 high bit
    // std::cout<<"size:"<<size<<std::endl;
    // // std::cout<<ptr<<std::endl;
    
    // memcpy(data, ptr, size);
    unsigned char *ref_input_0 = (unsigned char*)"\x5f\x6d\x26\xe8\xb8\x97\x72\xdf\x73\xb4\x9b\x71\x9b\x5e\x94\x6c\xdf\x1d\x55\x18\xba\x3e\xef\xca\x94\x03\x2a\x29\xcc\x0a\x4c\x5f";
    unsigned char *ref_input_1 = (unsigned char*)"\x5f\x6d\x26\xe8\xb8\x97\x72\xdf\x73\xb4\x9b\x71\x9b\x5e\x94\x6c\xdf\x1d\x55\x18\xba\x3e\xef\xca\x94\x03\x2a\x29\xcc\x0a\x4c\x5f";
    unsigned char *ref_input_2 = (unsigned char*)"\x5f\x6d\x26\xe8\xb8\x97\x72\xdf\x73\xb4\x9b\x71\x9b\x5e\x94\x6c\xdf\x1d\x55\x18\xba\x3e\xef\xca\x94\x03\x2a\x29\xcc\x0a\x4c\x5f";
    
    unsigned char *ref_output = (unsigned char*)"\x13\x2e\x0f\xb5\x8f\x03\xf4\x9e\xaf\xd6\x55\xb5\x59\xcb\xf6\xe2\xbd\x37\x1c\x26\x9f\x80\x39\xcb\xd3\xfa\x6f\x6b\x17\xa2\x97\x97";
    
    unsigned char *result = new unsigned char[9600];

    for (int i = 0; i < 100; i ++)
    {

        for (int k = 0; k < 32; k ++)
        {
            result[i * 32 * 3 + 0 * 32 + k] = ref_input_0[i * 32 * 3 + 0 * 32 + 31 - k]; 
            result[i * 32 * 3 + 1 * 32 + k] = ref_input_1[i * 32 * 3 + 1 * 32 + 31 - k]; 
            result[i * 32 * 3 + 2 * 32 + k] = ref_input_2[i * 32 * 3 + 2 * 32 + 31 - k]; 
        }
        
        // memcpy(data + (i * 3 + 0) * 32, ref_input_0, 32);
        // memcpy(data + (i * 3 + 1) * 32, ref_input_1, 32);
        // memcpy(data + (i * 3 + 2) * 32, ref_input_2, 32);
    }
    memcpy(data, result, 9600);
    
    // cout << "result: ";
    // for (int i = 0; i < 320; i++) printf("%02x", result[i]);
    
    cout << endl;
    
    cout << "c_py_gen_packet" << endl;
}

void recv_res(svBitVecVal* data) 
{
    // py::module_ sys = py::module_::import("sys");
    // py::list path = sys.attr("path");
    // path.attr("append")("../utils");
    // //py::print(sys.attr("path"));
    // py::module_ utils = py::module_::import("harness_utils");

    // size_t size_data = sizeof(data);

    // auto res = py::array(py::buffer_info(
    //     data,                                       // 数据指针
    //     sizeof(svBitVecVal),                        // 元素大小
    //     py::format_descriptor<svBitVecVal>::value, // 格式化描述符
    //     1,                                          // 维度
    //     { size_data },                              // 形状
    //     { sizeof(svBitVecVal) }                    // 每个维度的字节数
    // ));

    // utils.attr("recv")(res);

    cout << "recv_res" << endl;

}