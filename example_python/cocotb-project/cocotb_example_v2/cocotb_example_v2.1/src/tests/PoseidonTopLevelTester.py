import cocotb
import random
from cocotb.clock import Clock
from cocotb.result import TestSuccess, TestFailure
from cocotb.triggers import RisingEdge
from queue import Queue
from poseidon_python import finite_field as ff
from poseidon_python import poseidon_ff, basic


CASES_NUM = 100


class PoseidonTopLevelTester:
    def __init__(self, target):
        self.dut = target
        # self.ref_inputs = Queue(maxsize=500)
        # self.ref_outputs = Queue(maxsize=500)
        self.ref_inputs_2 = [[0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f,
0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f,
0x5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f] for i in range(CASES_NUM)]
        self.ref_outputs_2 = [0x132e0fb58f03f49eafd655b559cbf6e2bd371c269f8039cbd3fa6f6b17a29797 for i in range(CASES_NUM)]

    async def reset_dut(self):
        """reset the dut reset active level: low"""
        self.dut.resetn.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.resetn.value = 0
        for i in range(2):
            await RisingEdge(self.dut.clk)

        self.dut.resetn.value = 1

    def get_random_values(self, cases_count):
        """get random input values"""
        size_range = [3, 5, 9, 12]
        # state_size  = size_range[random.randint(0,3)]
        state_size = 3  # size_range[int(cases_count / 25)]
        state_elements = []
        for i in range(state_size):
            state_elements.append(ff.PrimeField(random.randint(0, basic.P - 1)))
        return state_elements

    async def drive_input(self):
        """generate input signals"""
        cases_count = 0
        while cases_count < CASES_NUM:
            # state_elements = self.get_random_values(cases_count)
            state_elements = self.ref_inputs_2[cases_count]

            # assign random valuess to dut io port
            for i in range(len(state_elements)):
                self.dut.io_input_valid.value = True  # (random.random()>0.2)
                self.dut.io_input_payload.value = state_elements[i]
                self.dut.io_input_last.value = i == (len(state_elements) - 1)

                await RisingEdge(self.dut.clk)

                while (
                    self.dut.io_input_valid.value & self.dut.io_input_ready.value
                ) == False:
                    self.dut.io_input_valid.value = True  # (random.random()>0.2)
                    await RisingEdge(self.dut.clk)
            print("input case {}".format(cases_count))
            cases_count += 1


        self.dut.io_input_valid.value = False

    async def monitor_output(self):
        """compare output signals to reference model"""
        count_cases = 0

        while count_cases < CASES_NUM:
            self.dut.io_output_ready.value = True  # (random.random() > 0.3)
            
            await RisingEdge(self.dut.clk)

            if (
                self.dut.io_output_ready.value & self.dut.io_output_valid.value
            ) == True:
                dut_res = int(self.dut.io_output_payload.value)

                ref_input = self.ref_inputs_2[count_cases]
                ref_output = self.ref_outputs_2[count_cases]
              
                if dut_res != ref_output:
                    # print error info
                    print("test case {} failed: ".format(count_cases))
                    print("ref input:\n")
                    print("lenght of preimage:{}".format(len(ref_input)))
                    for element in ref_input:
                        print(hex(element))
                    print("ref output:\n{}".format(hex(ref_output)))
                    print("dut res:\n{}".format(hex(dut_res)))

                    raise TestFailure(" test failed!!! ")

                print("output case {}".format(count_cases))
                count_cases += 1

        raise TestSuccess(" pass {} test cases".format(CASES_NUM))


@cocotb.test(timeout_time=60000000000, timeout_unit="ns")
async def PoseidonTopLevelTest(dut):
    # await cocotb.start(Clock(dut.clk, 10, "ns").start())

    # set default values to dut ports
    dut.io_input_valid.value = False
    dut.io_input_payload.value = 0
    dut.io_input_last.value = False

    dut.io_output_ready.value = False

    # start testing
    tester = PoseidonTopLevelTester(dut)
    await tester.reset_dut()
    await cocotb.start(tester.drive_input())
    await cocotb.start(tester.monitor_output())
    round_max = -1
    cycle = 0
    while True:
        await RisingEdge(dut.clk)

        # cycle = cycle + 1
        # loop = dut.poseidonInst.poseidonLoop_1

        # if (
        #     loop.streamArbiter_2_io_output_valid.value
        #     & loop.poseidonSerializer_1_io_input_ready.value
        # ):
        #     roundp = (
        #         int(loop.streamArbiter_2_io_output_payload_fullRound.value)
        #         + int(loop.streamArbiter_2_io_output_payload_partialRound.value) % 63
        #     )
        #     if roundp > round_max:
        #         round_max = roundp
        #         print("ID: ", int(loop.streamArbiter_2_io_output_payload_stateID.value))
        #         print(
        #             "isFull: ",
        #             bool(loop.streamArbiter_2_io_output_payload_isFull.value),
        #         )
        #         print(
        #             "fullRound: ",
        #             int(loop.streamArbiter_2_io_output_payload_fullRound.value),
        #         )
        #         print(
        #             "partialRound: ",
        #             int(loop.streamArbiter_2_io_output_payload_partialRound.value),
        #         )