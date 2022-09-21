from pyuvm import *
from cocotb.triggers import ClockCycles
from tinyalu_utils import Ops, alu_prediction, TinyAluBfm
import random
import asyncio


class AluSeqItem(uvm_sequence_item):

    def __init__(self, name, aa=0, bb=0, op=Ops.ADD):
        super().__init__(name)
        self.A = aa
        self.B = bb
        self.op = Ops(op)

    def __eq__(self, other):
        same = self.A == other.A and self.B == other.B and self.op == other.op
        return same

    def __str__(self):
        return f"{self.get_name()} : A: 0x{self.A:02x} "
        f"OP: {self.op.name} ({self.op.value}) B: 0x{self.B:02x}"

    def randomize(self):
        self.A = random.randint(0, 255)
        self.B = random.randint(0, 255)
        self.op = random.choice(list(Ops))


class AluSeq(uvm_sequence):
    async def body(self):
        for op in list(Ops):
            cmd_tr = AluSeqItem("cmd_tr")
            print("await start_item")
            await self.start_item(cmd_tr)
            cmd_tr.randomize()
            cmd_tr.op = op
            print("await finish_item")
            await self.finish_item(cmd_tr)


class Driver(uvm_driver):
    def connect_phase(self):
        global bfm
        self.bfm = bfm
        # self.bfm = ConfigDB().get(self, "", "BFM")
        print("FULL NAME", self.get_full_name())

    async def run_phase(self):
        while True:
            command = await self.seq_item_port.get_next_item()
            await self.bfm.send_op(command.A, command.B, command.op)
            self.logger.debug(f"Sent command: {command}")
            self.seq_item_port.item_done()


class Monitor(uvm_component):
    def __init__(self, name, parent, method_name):
        super().__init__(name, parent)
        self.method_name = method_name

    def build_phase(self):
        self.ap = uvm_analysis_port("ap", self)

    def connect_phase(self):
        global bfm
        self.bfm = bfm
        # self.bfm = self.cdb_get("BFM")

    async def run_phase(self):
        while True:
            get_method = getattr(self.bfm, self.method_name)
            datum = await get_method()
            self.ap.write(datum)


class AluEnv(uvm_env):

    def build_phase(self):
        self.cmd_mon = Monitor("cmd_mon", self, "get_cmd")
        self.result_mon = Monitor("result_mon", self, "get_result")

        self.driver = Driver("driver", self)
        self.seqr = uvm_sequencer("seqr", self)
        ConfigDB().set(None, "*", "SEQR", self.seqr)

    def connect_phase(self):
        self.driver.seq_item_port.connect(self.seqr.seq_item_export)


class AluTest(uvm_test):
    def build_phase(self):
        self.env = AluEnv.create("env", self)

    async def run_phase(self):
        self.raise_objection()
        seqr = ConfigDB().get(self, "", "SEQR")
        global bfm
        # bfm = ConfigDB().get(self, "", "BFM")
        seq = AluSeq("seq")
        await seq.start(seqr)
        # await ClockCycles(bfm.dut.clk, 50)  # to do last transaction
        self.drop_objection()

    def end_of_elaboration_phase(self):
        self.set_logging_level_hier(logging.DEBUG)


async def test_alu(dut):
    global bfm
    bfm = TinyAluBfm(dut)
    ConfigDB().set(None, "*", "BFM", bfm)
    await bfm.startup_bfms()
    await uvm_root().run_test("AluTest")


from utils.harness_utils import sim
import time


def do_clk_test():
    time1 = time.time()
    s = sim('./hdl/', 'bfm.v')
    # s.disableWave()
    # 设置获取message数据的回调函数名
    s.set_send_message_func("send_msg")
    asyncio.run(test_alu(s))

    time2 = time.time()
    
    s.deleteHandle()
    time3 = time.time()
    print('compile time:', time2 - time1)
    print('simulation time:', time3 - time2)
    pass


if __name__ == '__main__':
    do_clk_test()   
    pass