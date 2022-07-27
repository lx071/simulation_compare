import example
#             signal[0] = new Signal(top.io_A);
#             signal[1] = new Signal(top.io_B);
#             signal[2] = new Signal(top.io_X);
#             signal[3] = new Signal(top.clk);
#             signal[4] = new Signal(top.reset);

signal_id = {"io_A": 0, "io_B": 1, "io_X": 2, "clk": 3, "reset": 4}
num = 0


def setValue(dut, signal_name, value):
    example.setValue(dut, signal_id[signal_name], value)


def getValue(dut, signal_name):
    return example.getValue(dut, signal_id[signal_name])


def assign(dut):
    global num
    setValue(dut, "io_A", num % 200)
    setValue(dut, "io_B", num % 200)
    num = num + 1


def test(dut):
    setValue(dut, "clk", 0)
    setValue(dut, "reset", 1)
    main_time = 0
    reset_value = 1
    while True:
        global num
        if num >= 1000000:
            break
        if main_time == 100:
            setValue(dut, "reset", 0)
        if reset_value == 1:
            reset_value = getValue(dut, "reset")
        if reset_value == 0 and main_time % 5 == 0:
            if getValue(dut, "clk") == 0:
                setValue(dut, "clk", 1)
                assign(dut)
            else:
                setValue(dut, "clk", 0)
        example.eval(dut)
        main_time = main_time + 1


def basic_test(dut):
    example.setValue(dut, 0, 11)
    example.setValue(dut, 1, 12)
    example.setValue(dut, 3, 0)
    example.setValue(dut, 4, 1)
    example.eval(dut)
    for i in range(5):
        value = example.getValue(dut, i)
        print(value)
    example.setValue(dut, 0, 12)
    example.setValue(dut, 1, 13)
    example.setValue(dut, 3, 1)
    example.setValue(dut, 4, 0)
    example.eval(dut)
    for i in range(5):
        value = example.getValue(dut, i)
        print(value)
    example.setValue(dut, 0, 13)
    example.setValue(dut, 1, 14)
    example.setValue(dut, 3, 0)
    example.setValue(dut, 4, 1)
    example.eval(dut)
    for i in range(5):
        value = example.getValue(dut, i)
        print(value)


if __name__ == '__main__':

    dut = example.getHandle('add_dut')
    basic_test(dut)
    # test(dut)
    example.deleteHandle(dut)
