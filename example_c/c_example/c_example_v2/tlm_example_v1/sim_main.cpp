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

#include <iostream>

using namespace std;

class Target : sc_module{
public:
    tlm_utils::simple_target_socket<Target> socket;
    int item_num;

    Target(sc_module_name name) : sc_module(name) {
        socket.register_b_transport(this, &Target::b_transport);   //register methods with each socket
        
        contextp_ = std::make_unique<VerilatedContext>();
        top_ = new Vwrapper(contextp_.get());

        item_num = sizeof(top_->payload_data);

        Verilated::traceEverOn(true);

    }
    ~Target() {
        top_->final();
        delete top_;
	}

private:
    std::unique_ptr<VerilatedContext> contextp_;
    Vwrapper* top_;
    
    int xmit_en = 0;
    
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

            trans.set_response_status(tlm::TLM_OK_RESPONSE);

        } else if (cmd == tlm::TLM_WRITE_COMMAND) {
            payload_data = data;
            //std::cout << "write_len:" << len << std::endl;
            // for(int i=0;i<len;i++) cout << std::hex << static_cast<int>(*(payload_data + i)) << endl;
            //  ‘const svBitVecVal*’ {aka ‘const unsigned int*’}

            for (int i = 0; i < item_num; i++) {
                top_->payload_data[i] = payload_data[i];
            }
            top_->tvalid = 1;
            while(top_->xmit_en == xmit_en)
            {
                top_->eval();
                contextp_->timeInc(5000);
            } 
            xmit_en = top_->xmit_en;
            
            trans.set_response_status(tlm::TLM_OK_RESPONSE);
        } else {
            trans.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);
            return;
        }
    }
};

class Initiator : sc_module{
public:
    tlm_utils::simple_initiator_socket<Initiator> socket;

    Initiator(sc_module_name name) : sc_module(name) {
        
    }


    // typedef unsigned __int32 uint32_t;
    // typedef uint32_t svBitVecVal;
    void send_tlm_data(int num) 
    {
        tlm::tlm_generic_payload trans;
        // sc_time delay = sc_time(10, SC_NS);

        sc_time delay = SC_ZERO_TIME;

        unsigned char arr[num*3];

        for (int i = 0; i < num; i = i + 1) {
            arr[i*3] = 1;
            arr[i*3+1] = i%100;
            arr[i*3+2] = i%100;
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

        // memcpy(data, payload_data, 5);
    }
};



int sc_main(int argc, char* argv[]) {

    int NUM = 4;    //send times
    //int item_num = 100;
    int num = 0;
    int xmit_en = 1;
    
    Target target("target");
    Initiator initiator("initiator");

    initiator.socket.bind(target.socket);
    
    // Simulate until $finish
    while (!Verilated::gotFinish()) {       
        
        num = num + 1;
        if(num >= NUM + 1) break;
        //target.item_num 表示每个tlm包含的数的个数; 除以2后表示每个tlm包含的激励组数
        initiator.send_tlm_data(target.item_num/3);

    }
    return 0;
}