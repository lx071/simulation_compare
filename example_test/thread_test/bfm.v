
`timescale 1ns / 1ps

module bfm
(
    
);

bit clk;
always #4 clk = ~clk;

import "DPI-C" context function void init();

export "DPI-C" function set_data;
import "DPI-C" context function void get_data();

export "DPI-C" function finalize;
import "DPI-C" context function void kill();

bit input_valid;
bit ready;
bit final_en;

initial begin   
    final_en = 0;
    ready = 0;
    input_valid = 0;

    init();

    @(posedge final_en) kill();
    
    $finish;
end

always @(posedge clk) begin

    if (input_valid == 1) begin
        get_data();
        input_valid = 0;
    end
end                

function set_data();
begin
    $display("set_data()");
    input_valid = 1;
end
endfunction


function finalize();
begin
    //$display("finalize");
    final_en = 1;
end
endfunction

endmodule
