import ctypes

lib = ctypes.cdll.LoadLibrary("./example.so")

for i in range(50000000):
    res = lib.add(1, 2)

print('res =', res)
