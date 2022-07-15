from simlite_verilog import Simlite
import random


# 每次给输入端口赋值, 跑一个时间单位
def test_step(s):
    s.start()
    s.step([0, 0, 20, 20])
    print("cnt: %d\t\tresult:%s" % (s.cnt, s.getRes()))
    s.step([1, 0, 15, 10])
    print("cnt: %d\t\tresult:%s" % (s.cnt, s.getRes()))
    s.step([0, 0, 1000, 1])
    print("cnt: %d\t\tresult:%s" % (s.cnt, s.getRes()))
    s.step([1, 0, 999, 201])
    print("cnt: %d\t\tresult:%s" % (s.cnt, s.getRes()))
    s.stop()


def test_task(s):
    tasks = []
    tasks.append([0, 0, 20, 20])
    tasks.append([1, 0, 15, 10])
    tasks.append([0, 0, 1000, 1])
    tasks.append([1, 0, 999, 201])

    s.start_task('Top', tasks)


def randomInput(ifn):
    fd = open(ifn, "w")
    instr = ""
    for i in range(100):
        instr += "0 0 0 " + str(random.randint(1, 2000)) + ' ' + str(random.randint(1, 2000)) + "\n"
    instr = instr + "-1\n"
    fd.write(instr)
    fd.close()


def doInput(ifn):
    fd = open(ifn, "w")
    instr = ""
    clk = 0
    reset = 1
    num = 0
    time = 0
    while True:
        for j in range(5):
            if time == 100:
                reset = 0
            if num >= 100:
                break
            if reset == 0 and time % 5 == 0:
                if clk == 0:
                    clk = 1
                    num = num + 1
                else:
                    clk = 0
                instr += '0 ' + str(num % 200) + ' ' + str(num % 200) + ' ' + str(clk) + ' ' + str(reset) + "\n"
            else:
                instr += '0 ' + str(num % 200) + ' ' + str(num % 200) + ' ' + str(clk) + ' ' + str(reset) + "\n"
            time = time + 1
        if num >= 100:
            break
    instr = instr + "1\n"
    fd.write(instr)
    fd.close()


def test_file(s):
    ifn = f"../tmp/MyTopLevel_inputs"
    ofn = f"../tmp/MyTopLevel_outputs"
    doInput(ifn)
    s.start(mode="task", ofn=ofn, ifn=ifn)
    pass


def main():
    # Emitter.dumpVerilog(Emitter.dump(Emitter.emit(Top()), "Add.fir"))
    top_module_name = 'MyTopLevel.v'
    dut_path = './tmp/dut/'
    s = Simlite(top_module_name, dut_path, debug=True)

    # test_step(s)
    # test_task(s)
    test_file(s)

    s.close()


if __name__ == '__main__':
    main()
    # doInput(f"./tmp/Top_inputs")
