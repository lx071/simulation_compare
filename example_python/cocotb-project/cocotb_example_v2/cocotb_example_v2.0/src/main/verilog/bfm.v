module bfm (
    input clk
    
);
    //bit clk;
    //always #5 clk = ~clk;

    reg io_input_valid, io_input_last, io_output_ready, resetn;
    reg [254:0] io_input_payload;
    
    wire io_input_ready, io_output_valid, io_output_last;
    wire [254:0] io_output_payload;


    initial begin
        //$dumpfile("dump.vcd");
        //$dumpvars;
    end


    PoseidonTopLevel poseidonInst(
        .io_input_valid    (io_input_valid  ),
        .io_input_ready    (io_input_ready  ),
        .io_input_last     (io_input_last      ),
        .io_input_payload  (io_input_payload   ),

        .io_output_valid   (io_output_valid ),
        .io_output_ready   (io_output_ready ),
        .io_output_last    (io_output_last     ),
        .io_output_payload (io_output_payload  ),
        .clk               (clk             ),
        .resetn             (resetn           )
    );


endmodule