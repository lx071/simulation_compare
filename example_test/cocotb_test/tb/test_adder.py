import cocotb
import pytest
from cocotb.triggers import RisingEdge
import cocotb_test.simulator
import os


@cocotb.test()
async def test_adder(dut):

    dut.a.value = 1
    dut.b.value = 2

    print(dut.result.value)


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', 'rtl'))
# lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
# axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'axis', 'rtl'))


if __name__ == '__main__':
    dut = "adder"
    module = os.path.splitext(os.path.basename(__file__))[0]
    print("module", module)

    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        # os.path.join(rtl_dir, "arp_eth_rx.v"),
        # os.path.join(rtl_dir, "arp_eth_tx.v"),
        # os.path.join(rtl_dir, "arp_cache.v"),
        # os.path.join(rtl_dir, "lfsr.v"),
    ]

    parameters = {}

    # parameters['DATA_WIDTH'] = data_width
    # parameters['KEEP_ENABLE'] = int(parameters['DATA_WIDTH'] > 8)
    # parameters['KEEP_WIDTH'] = parameters['DATA_WIDTH'] // 8
    # parameters['CACHE_ADDR_WIDTH'] = 2
    # parameters['REQUEST_RETRY_COUNT'] = 4
    # parameters['REQUEST_RETRY_INTERVAL'] = 300
    # parameters['REQUEST_TIMEOUT'] = 800


    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build")

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )