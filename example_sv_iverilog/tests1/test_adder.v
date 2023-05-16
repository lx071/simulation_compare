`timescale 1ps/1ps

module test_adder();

reg clk;

reg reset;

reg [7:0] data1_i;

reg [7:0] data2_i;

wire [7:0] data_o;

initial begin
    //$dumpfile("test.vcd");
    //$dumpvars;
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

    repeat(2000000) begin
        @(posedge clk) begin
            data1_i <= (data1_i + 8'd1) % 200;
            data2_i <= (data2_i + 8'd1) % 200;
        end
    end

    $finish;

end

MyTopLevel u_add(
    .clk( clk ),
    .reset( reset ),
    .io_A( data1_i ),
    .io_B( data2_i ),
    .io_X ( data_o )
);

endmodule