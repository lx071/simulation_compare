#include <iostream>
#include "svdpi.h"

// SystemC global header
#include <systemc.h>

#include <tlm.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

// #include "verilated.h"
// #include "Vbfm.h"

using namespace std;
//typedef unsigned char uint8_t;
//typedef unsigned int uint32_t; 
//typedef uint8_t svScalar;
//typedef svScalar svBit;
//typedef uint32_t svBitVecVal;

extern "C" void gen_tlm_data(int num);
extern "C" void set_data(const svBitVecVal* data);
extern "C" void recv_tlm_data(int num);
extern "C" void get_data(svBitVecVal* data);

class Target : sc_module{
public:
    tlm_utils::simple_target_socket<Target> socket;

    Target(sc_module_name name) : sc_module(name) {
        socket.register_b_transport(this, &Target::b_transport);   //register methods with each socket
        socket.register_transport_dbg(this, &Target::transport_dbg);
    }

private:
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
    
        output_payload_data = new unsigned int[11]; 

        if ( cmd == tlm::TLM_READ_COMMAND )
        {
            get_data(output_payload_data);
            memcpy(ptr, output_payload_data, 42);
        }
            
        else if ( cmd == tlm::TLM_WRITE_COMMAND )
        {

        }

        return 0;
    }
};

class Initiator : sc_module{
public:
    tlm_utils::simple_initiator_socket<Initiator> socket;

    Initiator(sc_module_name name) : sc_module(name) {
        // SC_THREAD(run);     //Similar to a Verilog @initial block
    }

    unsigned char* input_payload_data = nullptr;
    unsigned char *output_payload_data = nullptr;
    unsigned char *ref_output = nullptr;
    
    void gen_tlm_data(int num)
    {
        tlm::tlm_generic_payload trans;
        // sc_time delay = sc_time(10, SC_NS);

        sc_time delay = SC_ZERO_TIME;   

        // tx_payload_data ='hffffffffffff5a5152535455080600010800060400015a5152535455c0a80164000000000000c0a80165

        const char* hex_string = "\xff\xff\xff\xff\xff\xff\x5a\x51\x52\x53\x54\x55\x08\x06\x00\x01\x08\x00\x06\x04\x00\x01\x5a\x51\x52\x53\x54\x55\xc0\xa8\x01\x64\x00\x00\x00\x00\x00\x00\xc0\xa8\x01\x65";
        int len = 42;
        input_payload_data = new unsigned char[len];

        for (int i = 0; i < len; i ++)
        {
            input_payload_data[i] = hex_string[len-1-i];
        }
        // cout << "gen data: ";
        // for (int k = 0; k < 42; k ++) printf("%02x", input_payload_data[k]);
        // cout << endl;

        // set data
        trans.set_command(tlm::TLM_WRITE_COMMAND);
        trans.set_address(0x0);
        trans.set_data_ptr(reinterpret_cast<unsigned char*>(input_payload_data));
        trans.set_data_length(strlen((const char*)input_payload_data));
        socket->b_transport(trans, delay);

        assert(trans.is_response_ok());
    }


    void recv_tlm_data(int num)
    {
        tlm::tlm_generic_payload trans;
        // sc_time delay = sc_time(10, SC_NS);

        sc_time delay = SC_ZERO_TIME;

        // rx_payload_data ='h5a5152535455dad1d2d3d4d508060001080006040002dad1d2d3d4d5c0a801655a5152535455c0a80164

        trans.set_command(tlm::TLM_READ_COMMAND);
        trans.set_address(0);
        trans.set_read();
        trans.set_data_length(128);

        output_payload_data = new unsigned char[42];
        trans.set_data_ptr(output_payload_data);

        unsigned int n_bytes = socket->transport_dbg( trans );

        const char* hex_string = "\x5a\x51\x52\x53\x54\x55\xda\xd1\xd2\xd3\xd4\xd5\x08\x06\x00\x01\x08\x00\x06\x04\x00\x02\xda\xd1\xd2\xd3\xd4\xd5\xc0\xa8\x01\x65\x5a\x51\x52\x53\x54\x55\xc0\xa8\x01\x64";
        ref_output = (unsigned char*) hex_string;

        int len = 42;
        
        // cout << "recv data: ";
        for (int i = 0; i < 42; i ++)
        {
            if (output_payload_data[i] != ref_output[len-1-i]) cout << "ERRPR!" << endl;
            // printf("%02x", output_payload_data[i]);
        }
        // cout << endl;
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
