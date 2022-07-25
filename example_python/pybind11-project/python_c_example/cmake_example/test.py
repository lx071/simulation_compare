import os
import sys

os.chdir('./build')
os.system("cmake ..")
os.system("make")
# print(sys.path)
# print(sys.argv[0])
# print(os.getcwd())
# print(os.path.abspath('..'))
sys.path.append(os.path.abspath('..') + '/src')
print(sys.path)
from build import example


example.add(7, 9)

example.main()
