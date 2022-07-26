import os
import subprocess
import sys


def runCompile():
    pybind_i = subprocess.getoutput('python3 -m pybind11 --includes')

    compile_command = f"c++ -O3 -Wall -shared -std=c++11 -fPIC {pybind_i} main.cpp -o example.so"
    os.chdir('./src')
    os.system(compile_command)

    sys.path.append(os.path.abspath('..') + '/src')
    print(sys.path)
    import example

    example.add(7, 9)
    example.test()


if __name__ == '__main__':
    runCompile()
