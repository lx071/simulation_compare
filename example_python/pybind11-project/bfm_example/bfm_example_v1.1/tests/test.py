import os
import subprocess
import time


def runCompile(dut_path, top_module_file_name):
    print("\n\n---------------------iverilog build info--------------------------\n")

    dut_name = top_module_file_name.split('.')[0]  # 模块名

    # 在当前目录创建simulation文件夹
    try:
        os.mkdir("simulation")
    except FileExistsError:
        pass

    if not dut_path.endswith('/'):
        dut_path = dut_path + '/'

    # 把所有dut文件复制到simulation文件夹下
    os.system("cp {}* ./simulation/".format(dut_path))

    # vfn = "{}.v".format(self.dut_name)              # {dut_name}.v
    vfn = top_module_file_name
    tfn = "../test_adder.v"
    mfn = "V{}.mk".format(dut_name)  # V{dut_name}.mk
    efn = "V{}".format(dut_name)  # V{dut_name}

    # 改变当前工作目录到指定的路径--simulation
    os.chdir("./simulation")

    compile_command_1 = f"iverilog -o run.out *.v"
    compile_command_2 = f"vvp -n run.out"

    print(compile_command_1)
    print(compile_command_2)

    time1 = time.time()
    os.system(compile_command_1)
    time2 = time.time()
    os.system(compile_command_2)
    time3 = time.time()
    print('compile time:', time2 - time1)
    print('simulation time:', time3 - time2)


if __name__ == '__main__':
    runCompile('../hdl', 'test_adder.v')
    pass
