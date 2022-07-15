import os
import subprocess
import example
from simlite_verilog import Simlite
import random


def main():
    # Emitter.dumpVerilog(Emitter.dump(Emitter.emit(Top()), "Add.fir"))
    top_module_name = 'MyTopLevel.v'
    dut_path = './../harness_reference/hdl/'
    s = Simlite(top_module_name, dut_path, debug=True)

    # test_step(s)
    # test_task(s)
    # test_file(s)

    s.close()


def test():
    p = example.getHandle('value')
    for i in range(5):
        value = example.getValue(p, i)
        print(value)
    example.setValue(p, 0, 11)
    value = example.getValue(p, 0)
    print(value)
    example.eval(p)

    # <example.Pet object at 0x7fd6dbb5cf30>
    # Molly
    # Charly


if __name__ == '__main__':
    # verilator --cc {dut_name}.v --trace --exe {dut_name}-harness.cpp
    # make -j -C ./obj_dir -f V{dut_name}.mk V{dut_name}
    # ./obj_dir/V{dut_name}
    dut = example.getHandle('add_dut')
    # dut_name = 'MyTopLevel'
    # verilator --cc MyTopLevel.v --trace --exe example.cpp
    # command = f'verilator --cc {dut_name}.v --trace --exe {dut_name}-harness.cpp'
    # os.system(command)
    example.setValue(dut, 0, 11)
    example.setValue(dut, 1, 12)
    example.setValue(dut, 3, 0)
    example.setValue(dut, 4, 1)
    example.eval()

    # command = f'make -j -C ./obj_dir -f V{dut_name}.mk V{dut_name}'
    # os.system(command)
    #
    # command = f'./obj_dir/V{dut_name}'
    # env = {"LD_LIBRARY_PATH": "."}  # 环境变量
    # p = subprocess.Popen(command, env=env, stdin=subprocess.PIPE, stdout=subprocess.PIPE)


