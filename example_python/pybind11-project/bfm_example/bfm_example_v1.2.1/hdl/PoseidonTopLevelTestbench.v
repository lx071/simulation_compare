`timescale 1ns/1ps

module PoseidonTester ();

    //initial begin
    //    $dumpfile("dump.vcd");
    //    $dumpvars(1, PoseidonTester);
    //end

    localparam ClockPeriod = 10;
    localparam StateSize   = 9;
    localparam CaseNum     = 3;


    // init test cases
    reg [9*255-1:0] random_inputs[4:0];
    reg [255-1  :0] ref_outputs[2:0];

    reg [255-1:0] read_inputs_0[8:0];
    reg [255-1:0] read_inputs_1[8:0];
    reg [255-1:0] read_inputs_2[8:0];

    initial begin
        $readmemh("input_case0.txt", read_inputs_0);
        $readmemh("input_case1.txt", read_inputs_1);
        $readmemh("input_case2.txt", read_inputs_2);


        //case 0
        random_inputs[0][255*1-1:255*0] = read_inputs_0[0];
        random_inputs[0][255*2-1:255*1] = read_inputs_0[1];
        random_inputs[0][255*3-1:255*2] = read_inputs_0[2];
        random_inputs[0][255*4-1:255*3] = read_inputs_0[3];
        random_inputs[0][255*5-1:255*4] = read_inputs_0[4];
        random_inputs[0][255*6-1:255*5] = read_inputs_0[5];
        random_inputs[0][255*7-1:255*6] = read_inputs_0[6];
        random_inputs[0][255*8-1:255*7] = read_inputs_0[7];
        random_inputs[0][255*9-1:255*8] = read_inputs_0[8];
        ref_outputs[0] = 255'h2e95b69784d5aa354fb26c4b9f95dd264657db5a429d24fb9b5b040de43fbd17;


        // case 1:
        random_inputs[1][255*1-1:255*0] = read_inputs_1[0];
        random_inputs[1][255*2-1:255*1] = read_inputs_1[1];
        random_inputs[1][255*3-1:255*2] = read_inputs_1[2];
        random_inputs[1][255*4-1:255*3] = read_inputs_1[3];
        random_inputs[1][255*5-1:255*4] = read_inputs_1[4];
        random_inputs[1][255*6-1:255*5] = read_inputs_1[5];
        random_inputs[1][255*7-1:255*6] = read_inputs_1[6];
        random_inputs[1][255*8-1:255*7] = read_inputs_1[7];
        random_inputs[1][255*9-1:255*8] = read_inputs_1[8];
        ref_outputs[1] = 255'h996bc24754bdd40613c52f50cf55bc580dce6efa3f52fc694f652715ce557b8;


        // case 2:
        random_inputs[2][255*1-1:255*0] = read_inputs_2[0];
        random_inputs[2][255*2-1:255*1] = read_inputs_2[1];
        random_inputs[2][255*3-1:255*2] = read_inputs_2[2];
        random_inputs[2][255*4-1:255*3] = read_inputs_2[3];
        random_inputs[2][255*5-1:255*4] = read_inputs_2[4];
        random_inputs[2][255*6-1:255*5] = read_inputs_2[5];
        random_inputs[2][255*7-1:255*6] = read_inputs_2[6];
        random_inputs[2][255*8-1:255*7] = read_inputs_2[7];
        random_inputs[2][255*9-1:255*8] = read_inputs_2[8];

        ref_outputs[2] = 255'h69a166cb6dee33831b692198b7898d3ba5bf91ff6168039bf87f0e0e81c1c60f;


    end


    // generate clk and resetn signal
    reg [49:0] cycle_counter;
    reg clk, resetn;

    initial begin cycle_counter = 0; end
    always @(posedge clk) begin
        if(~resetn) begin
            cycle_counter <= 0;
        end
        else begin
            cycle_counter <= cycle_counter + 1;
        end

    end
    initial begin
        clk = 0;
        forever #(ClockPeriod/2) clk = ~clk;
    end

    initial begin
        resetn = 1;
        #(ClockPeriod) resetn = 0;
        #(2*ClockPeriod) resetn = 1;
    end


    // drive input ports
    reg [254:0] io_input_payload;
    reg io_input_valid;
    wire io_input_ready, io_input_last;
    wire input_handshake = io_input_valid & io_input_ready;
    reg [4:0] input_counter;
    reg [4:0] index_counter;
    always @(posedge clk) begin
        if(~resetn) begin
            index_counter <= 0;
            input_counter <= 0;
            io_input_valid <= 0;
        end
        else begin
            if(input_counter < 3) begin
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
    assign io_input_last = (index_counter == 8);
    always @(*) begin
        case(index_counter)
            0:io_input_payload = random_inputs[input_counter][255*1-1:255*0];
            1:io_input_payload = random_inputs[input_counter][255*2-1:255*1];
            2:io_input_payload = random_inputs[input_counter][255*3-1:255*2];
            3:io_input_payload = random_inputs[input_counter][255*4-1:255*3];
            4:io_input_payload = random_inputs[input_counter][255*5-1:255*4];
            5:io_input_payload = random_inputs[input_counter][255*6-1:255*5];
            6:io_input_payload = random_inputs[input_counter][255*7-1:255*6];
            7:io_input_payload = random_inputs[input_counter][255*8-1:255*7];
            8:io_input_payload = random_inputs[input_counter][255*9-1:255*8];
        endcase
    end


    // check output
    wire io_output_last, io_output_valid, io_output_ready;
    wire output_handshake = io_output_valid & io_output_ready;
    wire [254:0] io_output_payload;
    reg [4:0] output_counter;

    assign io_output_ready = 1'b1;
    always@(posedge clk) begin
        if(~resetn) begin
            output_counter <= 0;
        end
        else begin
            if(output_handshake) begin
                if( io_output_payload != ref_outputs[output_counter]) begin
                    $display("error output %d: %h",output_counter, io_output_payload);
                    $display(" test fail !!!");
                    $display("cycles: %d", cycle_counter);
                    $finish();
                end
                $display("res %d: %h correct",output_counter, io_output_payload);
                output_counter <= output_counter + 1;
            end

            if(output_counter == 3) begin
                $display("test success !!!");
                $display("cycles: %d", cycle_counter);
                $finish();
            end
        end
    end

    PoseidonTopLevel poseidonInst(
        .io_input_valid    (io_input_valid   ),
        .io_input_ready    (io_input_ready   ),
        .io_input_last     (io_input_last    ),
        .io_input_payload  (io_input_payload ),
        .io_output_valid   (io_output_valid  ),
        .io_output_ready   (io_output_ready  ),
        .io_output_last    (io_output_last   ),
        .io_output_payload (io_output_payload),
        .clk    (   clk),
        .resetn (resetn)
    );

    
endmodule
