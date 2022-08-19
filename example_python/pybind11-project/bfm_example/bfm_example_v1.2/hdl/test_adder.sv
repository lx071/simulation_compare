`timescale 1ps/1ps

module test_adder();

//import "DPI-C" function void c_method();
//import "DPI-C" function void c_py_gen_packet(output bit[255:0] pkt);
//import "DPI-C" function void recv (input int data);
//import "DPI-C" task void recv (input int data);

reg clk;

reg reset;

reg [31:0] data1_i;

reg [31:0] data2_i;

wire [31:0] data_o;


initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    data1_i = 0;
    data2_i = 0;

    #100
    reset = 0;

    repeat(100000) begin
        @(posedge clk) begin
            data1_i <= (data1_i + 8'd1) % 100;
            data2_i <= (data2_i + 8'd1) % 100;
        end
    end

    $stop;

end

Top u_add(
    .clock( clk ),
    .reset( reset ),
    .io_a( data1_i ),
    .io_b( data2_i ),
    .io_c ( data_o )
);

endmodule