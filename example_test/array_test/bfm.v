
`timescale 1ns / 1ps

module bfm
(
    
);

bit clk;
always #4 clk = ~clk;

bit[7:0] in_data[5];
bit[7:0] out_data[5];

import "DPI-C" context task init(inout bit[7:0] in_data[], inout bit[7:0] out_data[]);
import "DPI-C" context function void recv_data();
import "DPI-C" context function void gen_data();


initial begin   
    
    init(in_data, out_data);
    gen_data();

    $display("in_data:");
    foreach(in_data[i]) begin
        out_data[i] = in_data[i] + 1;
        $display(in_data[i]);
    end

    recv_data();
    $finish;
end


endmodule
