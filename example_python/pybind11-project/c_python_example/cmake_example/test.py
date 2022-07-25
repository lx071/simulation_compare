# 命令行执行 python test.py
import os
import sys


os.chdir('./build')
sys.path.append(os.path.abspath('..') + '/src')
# print(sys.path)
#
os.system("cmake ..")
os.system("make")
print(sys.path)
# print(sys.argv[0])
# print(os.getcwd())
# print(os.path.abspath('..'))


os.system('./example')
