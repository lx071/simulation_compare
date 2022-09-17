import os
import re


# 解析verilog代码, 返回输入端口名列表 和 输出端口名列表
def verilog_parse(dut_path, top_module_file_name):
    dut_name = top_module_file_name.split('.')[0]  # 模块名
    top_module_path = os.path.join(dut_path, top_module_file_name)
    # print(top_module_path)
    module_begin_match = r"module\s+([a-zA-Z0-9_]+)"
    # 匹配输入端口        input clock, input [31:0] io_a
    input_port_match = r"input\s+(reg|wire)*\s*(\[[0-9]+\:[0-9]+\]*)*\s*([a-zA-Z0-9_]+)"
    # 匹配输出端口        output [31:0] io_c
    output_port_match = r"output\s+(reg|wire)*\s*(\[[0-9]+\:[0-9]+\]*)*\s*([a-zA-Z0-9_]+)"
    current_module_name = ''
    input_ports_name = []
    output_ports_name = []
    ports_width = dict()
    with open(top_module_path, "r") as verilog_file:
        while verilog_file:
            verilog_line = verilog_file.readline().strip(' ')  # 读取一行
            # print(verilog_line)
            if verilog_line == "":  # 注：如果是空行，为'\n'
                break
            if "DPI-C" in verilog_line or "function" in verilog_line or "task" in verilog_line:
                continue
            module_begin = re.search(module_begin_match, verilog_line)

            if module_begin:
                current_module_name = module_begin.group(1)
                # print(current_module_name)

            if current_module_name == dut_name:
                input_port = re.search(input_port_match, verilog_line)
                output_port = re.search(output_port_match, verilog_line)
                if input_port:
                    # 输入端口名列表
                    input_ports_name.append(input_port.group(3))
                    range = input_port.group(2)
                    if range is None:
                        ports_width[input_port.group(3)] = 1
                    else:
                        left, right = range[1:-1].split(':')
                        ports_width[input_port.group(3)] = abs(int(left)-int(right))+1
                if output_port:
                    # 输出端口名列表
                    output_ports_name.append(output_port.group(3))
                    range = output_port.group(2)
                    if range is None:
                        ports_width[output_port.group(3)] = 1
                    else:
                        left, right = range[1:-1].split(':')
                        ports_width[output_port.group(3)] = abs(int(left) - int(right)) + 1
    print(dut_name)
    print(input_ports_name)
    print(output_ports_name)
    for x, y in ports_width.items():
        print(x, y)
    return input_ports_name, output_ports_name, ports_width


if __name__ == '__main__':
    verilog_parse('./hdl/', 'MyTopLevel.v')
