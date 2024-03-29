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

    SC_CTOR(Initiator){
        //SC_THREAD(run);     //Similar to a Verilog @initial block
    }

    unsigned char *payload_data;

    void gen_tlm_data(int num) 
    {
        tlm::tlm_generic_payload trans;
        // sc_time delay = sc_time(10, SC_NS);

        sc_time delay = SC_ZERO_TIME;

        payload_data = new unsigned char[num*3];

        for (int i = 0; i < num; i = i + 1) {
            payload_data[i*3] = 1;
            payload_data[i*3+1] = i%100;
            payload_data[i*3+2] = i%100;
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

Target target("target");
Initiator initiator("initiator");

void gen_tlm_data(int num) 
{
    static bool initialized = false;
    if (!initialized) {
        initiator.socket.bind(target.socket);
        initialized = true;
    }
    initiator.gen_tlm_data(num);
}
