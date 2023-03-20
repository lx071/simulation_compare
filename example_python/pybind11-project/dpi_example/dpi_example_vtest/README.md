# 通过DPI调用python代码性能测试（仅供参考）

模拟器：verilator 5.002

python：3.10

os：Win11-WSL-Ubuntu20.4

编译：`verilator --cc --exe --sv --timing --build hdl/MyTopLevel.v hdl/bfm.v hdl/wrapper.sv sim_main.cpp ../test_adder.so`

Python负责生成数据，C++接口负责传输

|运算次数|总时间|传输用时（Python+C++）|模拟用时（总时间-传输用时）|
|-|-|-|-|
|两百万|0.785s|0.379s|0.406s|
|五百万|1.557s|0.743s|0.814|
|一千万|2.899s|1.268s|1.631s|
|两千万|5.262s|2.279s|2.983s|
|五千万（最高）|13.868s|6.041s|7.827s|