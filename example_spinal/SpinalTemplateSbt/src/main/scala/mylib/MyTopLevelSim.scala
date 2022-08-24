package mylib

import spinal.core._
import spinal.sim._
import spinal.core.sim._

import scala.util.Random


//MyTopLevel's testbench
object MyTopLevelSim {
  def main(args: Array[String]) {
    SimConfig.withWave.doSim(new MyTopLevel){dut =>
      //Fork a process to generate the reset and the clock on the dut
      dut.clockDomain.forkStimulus(period = 10)

      for(idx <- 0 to 1000000){
        //Drive the dut inputs with random values
        dut.io.A #= idx % 100
        dut.io.B #= idx % 100

        //Wait a rising edge on the clock
        dut.clockDomain.waitRisingEdge()
      }
    }
  }
}
