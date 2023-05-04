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

#if VM_TRACE
#include <verilated_vcd_sc.h>
#endif

#include <iostream>


SC_MODULE(TLMTrafficGenerator)
{
	tlm_utils::simple_initiator_socket<TLMTrafficGenerator> socket;

	TLMTrafficGenerator(sc_module_name name, int numThreads = 1) :
		m_debug(false),
		m_startDelay(SC_ZERO_TIME)
	{
		int i;

		// SC_THREAD(run);
	}

private:
    bool m_debug;
	sc_time m_startDelay;

    void run()
	{
		wait(m_startDelay);
        // sc_core::wait(resetn.negedge_event());
		//...
	}
    
};

SC_MODULE(Top)
{
    int num_;
	sc_clock clk;
	sc_signal<bool> rst_n; // Active low.
    sc_signal<bool> tvalid;
    sc_signal<bool> xmit_en;

    int xmit_en_old;

    sc_signal<uint32_t> res_o;
    sc_signal<uint32_t> *payload_data;

    TLMTrafficGenerator tg;

    // Vwrapper dut;
    const std::unique_ptr<Vwrapper> dut{new Vwrapper{"dut"}};
    
	tlm_utils::simple_target_socket<Top> target_socket;

	Top(sc_module_name name, int num) :
        sc_module(name),
        num_(num),
		// clk("clk", sc_time(1, SC_US)),
        res_o("res_o"),
		tg("traffic_generator")
		// dut("dut")

	{
        payload_data = new sc_signal<uint32_t>[num_*2];

		target_socket.register_b_transport(this, &Top::b_transport);
        tg.socket.bind(target_socket);

        dut->res_o(res_o);
        dut->tvalid(tvalid);
        dut->xmit_en(xmit_en);

        for (int i = 0; i < num_*2; i++) {
            dut->payload_data[i](payload_data[i]);
        }   
        sc_start(SC_ZERO_TIME);
	}

	virtual void b_transport(tlm::tlm_generic_payload &trans, sc_time &delay)
	{
        
		// cout<<"b_transport"<<endl;
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
            // payload_data[0] = 16;
            for (int i = 0; i < num_*2; i++) {
                payload_data[i] = data[i];
            }
            tvalid = 1;

            xmit_en_old = xmit_en;

            while(xmit_en == xmit_en_old)
            {   
                sc_start(1, SC_NS);
            } 
            xmit_en_old = xmit_en;
            
            trans.set_response_status(tlm::TLM_OK_RESPONSE);
        } else {
            trans.set_response_status(tlm::TLM_COMMAND_ERROR_RESPONSE);
            return;
        }
	}

    ~Top() {
		// delete target_socket;
        dut->final();
        // delete dut;
		
	}
};

int sc_main(int argc, char* argv[]) {

    Verilated::commandArgs(argc, argv);
	
    #if VM_TRACE
    // Before any evaluation, need to know to calculate those signals only used for tracing
        Verilated::traceEverOn(true);
    #endif

    int num = 10;
    int item_num = 200;

    Top top("Top", item_num);

    tlm::tlm_generic_payload trans;
    // sc_time delay = sc_time(10, SC_NS);
    sc_time delay = SC_ZERO_TIME;

    unsigned char arr[item_num*2];

    for (int k = 0; k < num; k++)
    {
        for (int i = 0; i < item_num; i = i + 1) {
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

        top.tg.socket->b_transport(trans, delay);

    }
    // Return good completion status
    return 0;
}