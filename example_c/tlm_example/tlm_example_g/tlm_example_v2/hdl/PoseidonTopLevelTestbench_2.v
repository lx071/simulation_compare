`timescale 1ns/1ps 

module bfm #(
    parameter ClockPeriod = 10,
    parameter NUM = 100
);
    reg clk, resetn;

    reg [254:0] ref_input;
    reg [254:0] ref_output;
    reg xmit_en = 0;
    reg [2:0] i = 0;
    reg flag = 1;
    reg [8:0] num = 0;

    int item_num = NUM;

    initial begin
        clk = 0;
        forever #(ClockPeriod/2) clk = ~clk;
    end

    initial begin
        resetn = 0;
        #(2*ClockPeriod) resetn = 1;
    end

    initial begin
        ref_input = 255'h5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f;
        ref_output = 255'h132e0fb58f03f49eafd655b559cbf6e2bd371c269f8039cbd3fa6f6b17a29797;
    end


    // drive input ports
    reg [254:0] io_input_payload;
    reg io_input_valid;
    wire io_input_ready, io_input_last;
    wire input_handshake = io_input_valid & io_input_ready;
    reg [9:0] input_counter;
    reg [1:0] index_counter;
    always @(posedge clk) begin
        if(~resetn) begin
            index_counter <= 0;
            input_counter <= 0;
            io_input_valid <= 0;
        end
        else begin
            if(input_counter < 100) begin
                io_input_valid <= 1'b1;
            end
            else begin
                io_input_valid <= 1'b0;
            end

            if(input_handshake) begin
                if(io_input_last) begin
                    $display("input %d successfully", input_counter);
                    input_counter <= input_counter + 1;
                    index_counter <= 0;
                end
                else begin
                    index_counter <= index_counter + 1;
                end
            end
        end
    end
    assign io_input_last = (index_counter == 2);
    always @(*) begin
        case(index_counter)
            0:io_input_payload = ref_input;
            1:io_input_payload = ref_input;
            2:io_input_payload = ref_input;
        endcase
    end

    
    // check output
    wire io_output_last, io_output_valid, io_output_ready;
    wire output_handshake = io_output_valid & io_output_ready;
    wire [254:0] io_output_payload;
    reg [6:0] output_counter;

    assign io_output_ready = 1'b1;
    
    always@(posedge clk) begin
        if(~resetn) begin
            output_counter <= 0;
        end
        else begin
            if(output_handshake) begin
                //$display("io_output_payload:%h", io_output_payload);

                if( io_output_payload != ref_output) begin
                    $display("error output %d: %h",output_counter, io_output_payload);
                    $display(" test fail !!!");
                    //$display("cycles: %d", cycle_counter);
                    $finish();
                end
                //$display("ref_outputs[output_counter]: %d",ref_output);
                //$display("res %d: %h correct",output_counter, io_output_payload);
                $display("res %d: correct",output_counter);
                output_counter <= output_counter + 1;
            end

            if(output_counter == 100) begin
                $display("test success !!!");
                //$display("cycles: %d", cycle_counter);
                $finish();
            end
        end
    end


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