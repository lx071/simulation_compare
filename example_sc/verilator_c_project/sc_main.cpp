// -*- SystemC -*-
// DESCRIPTION: Verilator Example: Top level main for invoking SystemC model
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// SystemC global header
#include <systemc.h>

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vwrapper.h"

#include <tlm.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include "svdpi.h"
#include "Vwrapper__Dpi.h"
#include <iostream>

using namespace std;


SC_MODULE(Counter) { // 其实只是个target
public:
    tlm_utils::simple_target_socket<Counter> socket;

    SC_CTOR(Counter) : count(0) {
        socket.register_b_transport(this, &Counter::b_transport);   //register methods with each socket
    }

private:
    int count;

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
            if (len != sizeof(count)) {
                trans.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
                return;
            }
            memcpy(data, &count, sizeof(count));
            trans.set_response_status(tlm::TLM_OK_RESPONSE);
        } else if (cmd == tlm::TLM_WRITE_COMMAND) {
            if (len != sizeof(count)) {
                trans.set_response_status(tlm::TLM_BURST_ERROR_RESPONSE);
                return;
            }
            memcpy(&count, data, sizeof(count));
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

    SC_CTOR(Initiator) : count(0) {
        SC_THREAD(run);     //Similar to a Verilog @initial block
    }

private:
    int count;

    void run() {
        tlm::tlm_generic_payload trans;
        sc_time delay = sc_time(10, SC_NS);

        // 读取计数器的值
        trans.set_command(tlm::TLM_READ_COMMAND);
        trans.set_address(0x0);
        trans.set_data_ptr(reinterpret_cast<unsigned char*>(&count));
        trans.set_data_length(sizeof(count));
        socket->b_transport(trans, delay);

        assert(trans.is_response_ok());
        int count = *reinterpret_cast<int*>(trans.get_data_ptr());
        cout << "计数器的值为：" << count << endl;

        // 将计数器的值加1
        count++;
        trans.set_command(tlm::TLM_WRITE_COMMAND);
        trans.set_address(0x0);
        trans.set_data_ptr(reinterpret_cast<unsigned char*>(&count));
        trans.set_data_length(sizeof(count));
        socket->b_transport(trans, delay);

        assert(trans.is_response_ok());
        cout << "计数器的值加1后为：" << count << endl;

        // 读取计数器的值
        trans.set_command(tlm::TLM_READ_COMMAND);
        trans.set_address(0x0);
        trans.set_data_ptr(reinterpret_cast<unsigned char*>(&count));
        trans.set_data_length(sizeof(count));
        socket->b_transport(trans, delay);

        assert(trans.is_response_ok());
        cout << "计数器的值为：" << count << endl;
    }
};

extern void recv(int data);
extern void send_long(long long int data);
extern void send_bit(const svBit data);
extern void send_bit_vec(const svBitVecVal* data);


void c_py_gen_data(svBitVecVal* data) 
{
    char *payload_data = "\x11\x22\x33\x44\x44";
    // char payload_data[5];
    // tlm::tlm_generic_payload trans;
    // sc_time delay = sc_time(10, SC_NS);
    
    // // 读取计数器的值
    // trans.set_command(tlm::TLM_READ_COMMAND);
    // trans.set_address(0x0);
    // trans.set_data_ptr(reinterpret_cast<unsigned char*>(payload_data));
    // trans.set_data_length(strlen(payload_data));

    // initiator.socket->b_transport(trans, delay);

    // assert(trans.is_response_ok());
    // payload_data = reinterpret_cast<char*>(trans.get_data_ptr());
    // std::cout << "get payload_data：" << payload_data << std::endl;
    
    memcpy(data, payload_data, 5);
}

void put()
{
    long long int data_1 = 131;
    unsigned char data_2 = 231;
    const svBitVecVal data_3[4] = {0xFFEEFEF7, 0xF133FEF3, 0xF234FEF1, 0xF379FEF9};
    send_long(data_1);
    send_bit(data_2);
    send_bit_vec(data_3);
}

void recv(int data) 
{
    std::cout<<data<<std::endl;
    put();
}

Counter counter("counter");
Initiator initiator("initiator");

int sc_main(int argc, char* argv[]) {
    
    // Vwrapper* top = new Vwrapper{"wrapper"};
    
    auto contextp {make_unique<VerilatedContext>()};
    auto top {make_unique<Vwrapper>(contextp.get())};
    contextp->commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    
    // sc_signal<uint32_t> res_o;
    // top->res_o(res_o);

    // const svScope scope = svGetScopeFromName("TOP.top");
    // assert(scope);  // Check for nullptr if scope not found
    // svSetScope(scope);

    // Simulate until $finish
    while (!Verilated::gotFinish()) {

        top->eval();
        contextp->timeInc(1000);
    }

    // Final model cleanup
    top->final();

    // Return good completion status
    return 0;
}