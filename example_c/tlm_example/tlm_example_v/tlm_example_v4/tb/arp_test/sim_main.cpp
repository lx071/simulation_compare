#include <iostream>
#include "svdpi.h"

// SystemC global header
#include <systemc.h>

#include <tlm.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include "verilated.h"
#include "Vbfm.h"

using namespace std;
//typedef unsigned char uint8_t;
//typedef unsigned int uint32_t; 
//typedef uint8_t svScalar;
//typedef svScalar svBit;
//typedef uint32_t svBitVecVal;


extern "C" void init(svOpenArrayHandle input_payload_data, svOpenArrayHandle output_payload_data);

extern "C" void gen_tlm_data(int num);
extern "C" void recv_tlm_data(int num);
//extern "C" void set_data(const unsigned char* data);
//extern "C" void get_data(unsigned char* data);

class Target : sc_module{
public:
    tlm_utils::simple_target_socket<Target> socket;

    Target(sc_module_name name) : sc_module(name) {
        socket.register_b_transport(this, &Target::b_transport);   //register methods with each socket
        socket.register_get_direct_mem_ptr(this, &Target::get_direct_mem_ptr);
        socket.register_transport_dbg(this, &Target::transport_dbg);
    }

    unsigned char *dut_in_data = nullptr;
    unsigned char *dut_out_data = nullptr;
    int len = 42;
    
    void recv_tlm_data(int num)
    {
        // cout << "recv_tlm_data" << endl;

        tlm::tlm_generic_payload* trans = new tlm::tlm_generic_payload;

        tlm::tlm_sync_enum status;
        tlm::tlm_phase bw_phase;
        sc_time delay;

        // response_in_progress = true;
        bw_phase = tlm::BEGIN_RESP;
        delay = SC_ZERO_TIME;

        trans->set_data_ptr(dut_out_data);

        status = socket->nb_transport_bw( *trans, bw_phase, delay );
    } 

    void init(unsigned char* in_data, unsigned char* out_data) 
    {
        // cout << "init" << endl;
        dut_in_data = in_data;
        dut_out_data = out_data;
    }

private:
    
    // TLM-2 blocking transport method
    virtual void b_transport(tlm::tlm_generic_payload& trans, sc_time& delay) {
        tlm::tlm_command cmd = trans.get_command();
        sc_dt::uint64    adr = trans.get_address() / 4;
        unsigned char*   ptr = trans.get_data_ptr();
        // unsigned int     len = trans.get_data_length();
        unsigned char* byte_en = trans.get_byte_enable_ptr();
        unsigned int wid = trans.get_streaming_width();

        if (adr != 0x0) {
            trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
            return;
        }

        if (cmd == tlm::TLM_READ_COMMAND) {

            trans.set_response_status(tlm::TLM_OK_RESPONSE);

        } else if (cmd == tlm::TLM_WRITE_COMMAND) {

            memcpy(dut_in_data, ptr, len);

            trans.set_response_status(tlm::TLM_OK_RESPONSE);
        } else {
            trans.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);
            return;
        }
    }


    // *********************************************
    // TLM-2 forward DMI method
    // *********************************************

    virtual bool get_direct_mem_ptr(tlm::tlm_generic_payload& trans,
                                    tlm::tlm_dmi& dmi_data)
    {
        tlm::tlm_command cmd = trans.get_command();
        if (cmd == tlm::TLM_READ_COMMAND) {
            dmi_data.set_dmi_ptr( dut_out_data );
            
        } else if (cmd == tlm::TLM_WRITE_COMMAND) {
            dmi_data.set_dmi_ptr( dut_in_data );
        
        } else {
            return false;
        }

        // Permit read and write access
        dmi_data.allow_read_write();

        // Set other details of DMI region
        dmi_data.set_start_address( 0 );
        dmi_data.set_end_address( 256*4-1 );
        dmi_data.set_read_latency( SC_ZERO_TIME );
        dmi_data.set_write_latency( SC_ZERO_TIME );

        return true;
    }

    // *********************************************
    // TLM-2 debug transport method
    // *********************************************

    virtual unsigned int transport_dbg(tlm::tlm_generic_payload& trans)
    {
        tlm::tlm_command cmd = trans.get_command();
        sc_dt::uint64    adr = trans.get_address() / 4;
        unsigned char*   ptr = trans.get_data_ptr();
        // unsigned int     len = trans.get_data_length();

        // Calculate the number of bytes to be actually copied
        // unsigned int num_bytes = (len < (SIZE - adr) * 4) ? len : (SIZE - adr) * 4;
    
        // output_payload_data = new unsigned char[42]; 

        if ( cmd == tlm::TLM_READ_COMMAND )
        {
            memcpy(ptr, dut_out_data, len);
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

    Initiator(sc_module_name name) : sc_module(name) 
    {
        dmi_ptr_valid = false;

        // Register callbacks for incoming interface method calls
        socket.register_nb_transport_bw(this, &Initiator::nb_transport_bw);

        // SC_THREAD(thread_process);  //Similar to a Verilog @initial block
    }

    unsigned char* input_payload_data = nullptr;
    unsigned char *output_payload_data = nullptr;
    unsigned char *ref_output = nullptr;
    
    bool dmi_ptr_valid;
    tlm::tlm_dmi dmi_data;

    const char* in_hex_string = "\xff\xff\xff\xff\xff\xff\x5a\x51\x52\x53\x54\x55\x08\x06\x00\x01\x08\x00\x06\x04\x00\x01\x5a\x51\x52\x53\x54\x55\xc0\xa8\x01\x64\x00\x00\x00\x00\x00\x00\xc0\xa8\x01\x65";
    const char* out_hex_string = "\x5a\x51\x52\x53\x54\x55\xda\xd1\xd2\xd3\xd4\xd5\x08\x06\x00\x01\x08\x00\x06\x04\x00\x02\xda\xd1\xd2\xd3\xd4\xd5\xc0\xa8\x01\x65\x5a\x51\x52\x53\x54\x55\xc0\xa8\x01\x64";

    int len = 42;
        
    void gen_tlm_data(int num)
    {
        tlm::tlm_generic_payload* trans = new tlm::tlm_generic_payload;
        // sc_time delay = sc_time(10, SC_NS);

        sc_time delay = SC_ZERO_TIME;

        // tx_payload_data ='hffffffffffff5a5152535455080600010800060400015a5152535455c0a80164000000000000c0a80165

        input_payload_data = new unsigned char[len];

        for (int i = 0; i < len; i ++)
        {
            input_payload_data[i] = in_hex_string[len-1-i];
        }
        // cout << "gen data: ";
        // for (int k = 0; k < 42; k ++) printf("%02x", input_payload_data[k]);
        // cout << endl;

        // set data
        trans->set_command(tlm::TLM_WRITE_COMMAND);
        trans->set_address(0x0);
        trans->set_data_ptr(reinterpret_cast<unsigned char*>(input_payload_data));
        trans->set_data_length(strlen((const char*)input_payload_data));
        socket->b_transport(*trans, delay);

        assert(trans->is_response_ok());
    }

    void gen_tlm_data_dmi(int num)
    {
        // cout << "gen_tlm_data_dmi" << endl;
        // TLM-2 generic payload transaction, reused across calls to b_transport, DMI and debug
        tlm::tlm_generic_payload* trans = new tlm::tlm_generic_payload;
        trans->set_command(tlm::TLM_WRITE_COMMAND);
        sc_time delay = SC_ZERO_TIME;

        trans->set_dmi_allowed( true ); // Mandatory initial value

        // *********************************************
        // Check DMI hint
        // *********************************************

        if ( trans->is_dmi_allowed() )
        {
          // Re-user transaction object for DMI
            dmi_data.init();
            dmi_ptr_valid = socket->get_direct_mem_ptr( *trans, dmi_data );
        }

        unsigned char *data = dmi_data.get_dmi_ptr();

        // *********************************************
        // Use DMI if it is available, reusing same transaction object
        // *********************************************

        if (dmi_ptr_valid)
        {
            for (int i = 0; i < len; i ++)
            {
                data[i] = in_hex_string[len-1-i];
            }
        }
    }

    void check()
    {

        ref_output = (unsigned char*) out_hex_string;

        int len = 42;

        for (int i = 0; i < 42; i ++)
        {
            if (output_payload_data[i] != ref_output[len-1-i]) cout << "ERROR!" << endl;
            // printf("%02x", output_payload_data[i]);
        }
        // cout << endl;
    }
    
private:

    // TLM-2 backward non-blocking transport method

    virtual tlm::tlm_sync_enum nb_transport_bw( tlm::tlm_generic_payload& trans,
                                                tlm::tlm_phase& phase, sc_time& delay )
    {

        // The timing annotation must be honored
        // m_peq.notify( trans, phase, delay );

        // rx_payload_data ='h5a5152535455dad1d2d3d4d508060001080006040002dad1d2d3d4d5c0a801655a5152535455c0a80164

        unsigned char*   ptr = trans.get_data_ptr();
        // output_payload_data = new unsigned char[42];
        output_payload_data = ptr;

        check();
        
        return tlm::TLM_ACCEPTED;
    }

    // *********************************************
    // TLM-2 backward DMI method
    // *********************************************

    virtual void invalidate_direct_mem_ptr(sc_dt::uint64 start_range,
                                            sc_dt::uint64 end_range)
    {
        // Ignore range and invalidate all DMI pointers regardless
        dmi_ptr_valid = false;
    }

};


Target target("target");
Initiator initiator("initiator");

static bool initialized = false;

void gen_tlm_data(int num)
{
    // cout << "gen_tlm_data" << endl;
    
    if (!initialized) {
        initiator.socket.bind(target.socket);
        initialized = true;
    }
    // initiator.gen_tlm_data(num);
    initiator.gen_tlm_data_dmi(num);
}

void recv_tlm_data(int num) 
{
    if (!initialized) {
        initiator.socket.bind(target.socket);
        initialized = true;
    }
    target.recv_tlm_data(num);
}

void init(svOpenArrayHandle input_payload_data, svOpenArrayHandle output_payload_data) 
{
    unsigned char *in_data;
    unsigned char *out_data;
    in_data = ( unsigned char* ) svGetArrayPtr(input_payload_data);
    out_data = ( unsigned char* ) svGetArrayPtr(output_payload_data);
    // int len = svSize(input_payload_data, 0);
    // cout << "len:" << len << endl;

    target.init(in_data, out_data);

}

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