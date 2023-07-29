
`timescale 1ns / 1ps

module bfm
(
    
);

bit clk;
always #4 clk = ~clk;

bit[7:0] in_data[];
bit[7:0] out_data[];

import "DPI-C" context task init(unsigned char *in_data_addr, unsigned char *out_data_addr);
import "DPI-C" context function void recv_data();
import "DPI-C" context function void gen_data();


initial begin   
    in_data = new[5];
    out_data = new[5];

    $display("Address of in_data = %p", $unsigned(&in_data[0]));
    
    init(in_data, out_data);

    $display("in_data:");
    foreach(in_data[i]) begin
        in_data[i]=i;
        out_data[i]=i+1;
        $display(in_data[i]);
    end

    $display("out_data:");
    foreach(out_data[i]) begin
        $display(out_data[i]);
    end

    gen_data();

    foreach(in_data[i]) begin
        out_data[i] = in_data[i] + 2;
    end
    
    $display("in_data:");
    foreach(in_data[i]) begin
        $display(in_data[i]);
    end

    $display("out_data:");
    foreach(out_data[i]) begin
        $display(out_data[i]);
    end

    recv_data();
    
    //$display("Address of in_data = %p", $unsigned(&in_data[1]));   
    //$display("Address of in_data = %p", $unsigned(&in_data[2]));
    
    $finish;
end


endmodule
