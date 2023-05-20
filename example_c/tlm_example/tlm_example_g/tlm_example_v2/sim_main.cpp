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

extern "C" void gen_tlm_data(int num);
extern "C" void set_data(const svBitVecVal* data);
extern "C" void recv_tlm_data(int num);
extern "C" void get_data(svBitVecVal* data);

SC_MODULE(Target) { // 其实只是个target
public:
    tlm_utils::simple_target_socket<Target> socket;

    SC_CTOR(Target) : count(0) {
        socket.register_b_transport(this, &Target::b_transport);   //register methods with each socket
        socket.register_transport_dbg(this, &Target::transport_dbg);

    }

private:
    int count;
    // char *payload_data;
    unsigned char* input_payload_data = nullptr;
    unsigned int *output_payload_data = nullptr;

    // TLM-2 blocking transport method
    virtual void b_transport(tlm::tlm_generic_payload& trans, sc_time& delay) {
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
            input_payload_data = data;
            //std::cout << "write_len:" << len << std::endl;
            // for(int i=0;i<len;i++) cout << std::hex << static_cast<int>(*(payload_data + i)) << endl;

            //  ‘const svBitVecVal*’ {aka ‘const unsigned int*’}
            const unsigned int* sv_data = reinterpret_cast<const unsigned int*>(input_payload_data);
            set_data(sv_data);
            
            trans.set_response_status(tlm::TLM_OK_RESPONSE);
        } else {
            trans.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);
            return;
        }
    }


    // *********************************************
    // TLM-2 debug transport method
    // *********************************************

    virtual unsigned int transport_dbg(tlm::tlm_generic_payload& trans)
    {
        tlm::tlm_command cmd = trans.get_command();
        sc_dt::uint64    adr = trans.get_address() / 4;
        unsigned char*   ptr = trans.get_data_ptr();
        unsigned int     len = trans.get_data_length();

        // Calculate the number of bytes to be actually copied
        // unsigned int num_bytes = (len < (SIZE - adr) * 4) ? len : (SIZE - adr) * 4;
    
        output_payload_data = new unsigned int[3200/4]; 

        if ( cmd == tlm::TLM_READ_COMMAND )
        {
            get_data(output_payload_data);
            memcpy(ptr, output_payload_data, 3200);
        }
            
        else if ( cmd == tlm::TLM_WRITE_COMMAND )
        {

        }

        return 0;
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

        unsigned char *ref_input_0 = (unsigned char*)"\x5f\x6d\x26\xe8\xb8\x97\x72\xdf\x73\xb4\x9b\x71\x9b\x5e\x94\x6c\xdf\x1d\x55\x18\xba\x3e\xef\xca\x94\x03\x2a\x29\xcc\x0a\x4c\x5f";
        unsigned char *ref_input_1 = (unsigned char*)"\x5f\x6d\x26\xe8\xb8\x97\x72\xdf\x73\xb4\x9b\x71\x9b\x5e\x94\x6c\xdf\x1d\x55\x18\xba\x3e\xef\xca\x94\x03\x2a\x29\xcc\x0a\x4c\x5f";
        unsigned char *ref_input_2 = (unsigned char*)"\x5f\x6d\x26\xe8\xb8\x97\x72\xdf\x73\xb4\x9b\x71\x9b\x5e\x94\x6c\xdf\x1d\x55\x18\xba\x3e\xef\xca\x94\x03\x2a\x29\xcc\x0a\x4c\x5f";
        
        payload_data = new unsigned char[32 * 3 * num];

        for (int i = 0; i < num; i ++)
        {
            for (int k = 0; k < 32; k ++)
            {
                payload_data[i * 32 * 3 + 0 * 32 + k] = ref_input_0[31 - k]; 
                payload_data[i * 32 * 3 + 1 * 32 + k] = ref_input_1[31 - k]; 
                payload_data[i * 32 * 3 + 2 * 32 + k] = ref_input_2[31 - k]; 
            }
        }

        // set data
        trans.set_command(tlm::TLM_WRITE_COMMAND);
        trans.set_address(0x0);
        trans.set_data_ptr(reinterpret_cast<unsigned char*>(payload_data));
        trans.set_data_length(strlen((const char*)payload_data));
        socket->b_transport(trans, delay);

        assert(trans.is_response_ok());
    }

    void recv_tlm_data(int num)
    {
        tlm::tlm_generic_payload trans;
        // sc_time delay = sc_time(10, SC_NS);

        sc_time delay = SC_ZERO_TIME;

        trans.set_command(tlm::TLM_READ_COMMAND);
        trans.set_address(0);
        trans.set_read();
        trans.set_data_length(128);

        unsigned char* data = new unsigned char[3200];
        trans.set_data_ptr(data);

        unsigned int n_bytes = socket->transport_dbg( trans );

        // check
        unsigned char *ref_output = (unsigned char*)"\x13\x2e\x0f\xb5\x8f\x03\xf4\x9e\xaf\xd6\x55\xb5\x59\xcb\xf6\xe2\xbd\x37\x1c\x26\x9f\x80\x39\xcb\xd3\xfa\x6f\x6b\x17\xa2\x97\x97";
        for (int k = 0; k < 100; k ++)
        {
            for (int i = 0; i < 32; i++) {
                if (data[k*32 + i] != ref_output[31 - i]) cout << "ERROR" << endl;
                // printf("%02x", output[i]);
            }
        }
    }
};

Target target("target");
Initiator initiator("initiator");

void gen_tlm_data(int num)
{
    //cout << "gen_tlm_data" << endl;
    static bool initialized = false;
    if (!initialized) {
        initiator.socket.bind(target.socket);
        initialized = true;
    }
    initiator.gen_tlm_data(num);
}

void recv_tlm_data(int num) 
{
    
    initiator.recv_tlm_data(num);

}