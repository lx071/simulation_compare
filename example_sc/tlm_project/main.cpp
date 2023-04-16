#include <systemc.h>
#include <tlm.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

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

int sc_main(int argc, char* argv[]) {
    Counter counter("counter");
    Initiator initiator("initiator");

    initiator.socket.bind(counter.socket);

    sc_start();

    return 0;
}