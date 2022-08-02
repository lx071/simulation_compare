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

  reg[7:0]  dat_out_v;
  reg[1:0]  xmit_en = 0;

export "DPI-C" function send_long;
export "DPI-C" function send_bit;
export "DPI-C" function send_bit_vec;

function void send_long(longint data);
begin
    $display("send_long side");
    $display(data);
end
endfunction

function void send_bit(bit data);
begin
    $display("send_bit side");
    $display(data);
end
endfunction


function void send_bit_vec(bit[256:0] data);
begin
    $display("send_bit_vec side");
    $display("%h", data);
    $display(data[7:0]);
    $display(data[15:8]);
    $display(data[23:16]);
    $display(data[31:24]);
    $display(data[39:32]);
    $display(data[47:40]);
    $display(data[55:48]);
    $display(data[63:56]);
    $display(data[71:64]);
    $display(data[79:72]);
    $display(data[87:80]);
    $display(data[95:88]);
    $display(data[103:96]);
end
endfunction

endmodule

