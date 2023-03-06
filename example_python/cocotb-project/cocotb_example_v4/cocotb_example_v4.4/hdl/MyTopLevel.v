// Generator : SpinalHDL v1.7.0a    git head : 150a9b9067020722818dfb17df4a23ac712a7af8
// Component : MyTopLevel
// Git hash  : 23f8152f1f76822abe6de05999e6f5a903223b02

`timescale 1ns/1ps

module MyTopLevel (
  input      [7:0]    io_A,
  input      [7:0]    io_B,
  output     [7:0]    io_X,
  input               clk,
  input               reset
);

  reg        [7:0]    a;
  reg        [7:0]    b;
  wire                when_MyTopLevel_l36;

  assign when_MyTopLevel_l36 = 1'b1;
  assign io_X = (a + b);

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      a <= 8'h0;
      b <= 8'h0;
    end else begin
      if(when_MyTopLevel_l36) begin
        a <= io_A;
        b <= io_B;
      end
    end
  end


endmodule
