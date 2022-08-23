`include "timescale.v"


module eth_register(DataIn, DataOut, Write, Clk, Reset, SyncReset);

parameter WIDTH = 8; // default parameter of the register width
parameter RESET_VALUE = 0;

input [WIDTH-1:0] DataIn;

input Write;
input Clk;
input Reset;
input SyncReset;

output [WIDTH-1:0] DataOut;
reg    [WIDTH-1:0] DataOut;



always @ (posedge Clk or posedge Reset)
begin
  if(Reset)
    DataOut<=#1 RESET_VALUE;
  else
  if(SyncReset)
    DataOut<=#1 RESET_VALUE;
  else
  if(Write)                         // write
    DataOut<=#1 DataIn;
end



endmodule   // Register
