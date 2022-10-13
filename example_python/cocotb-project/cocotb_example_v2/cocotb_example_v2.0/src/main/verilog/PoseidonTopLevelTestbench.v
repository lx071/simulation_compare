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
    reg [9*255-1:0] random_inputs[2:0];
    reg [255-1  :0] ref_outputs[2:0];
    initial begin
        //case 0
        random_inputs[0][255*1-1:255*0] = 255'hc59041b7aa57a3757c9e652d111ec48d5f04d67039bae3300000232fffffdcd;
        random_inputs[0][255*2-1:255*1] = 255'h679a444265b1ba53c080b6df7343ce209d88868e94f02215367bf662c87fae9;
        random_inputs[0][255*3-1:255*2] = 255'h143e006c502b069fe52292069d453c237c7b74ba4c59deecb375654e10a6a3b9;
        random_inputs[0][255*4-1:255*3] = 255'h42f3a6e9810b355e309b4012313ace8d646099273951e85911a481a2c5cea3e1;
        random_inputs[0][255*5-1:255*4] = 255'h592622519f8e2d5793bbd200c8f291ae1efcde748e117800a00c178176bbac09;
        random_inputs[0][255*6-1:255*5] = 255'h234552fc8431beb406a7d9aa53de335c811736b78535d8776df905886af39720;
        random_inputs[0][255*7-1:255*6] = 255'h1f4604cf52f7fae7297d5363daf235ae9e32fe5a2e93e901774004c933ebb27;
        random_inputs[0][255*8-1:255*7] = 255'h26145f1513c6a66978961c6a7ebc270227d8c921168cd15f8757133a8f56a6b9;
        random_inputs[0][255*9-1:255*8] = 255'h26d5604c226f0f63b7936449ed7d4582451d695a2f172fea9f2cd530fa3a5407;
        ref_outputs[0] = 255'h2e95b69784d5aa354fb26c4b9f95dd264657db5a429d24fb9b5b040de43fbd17;

        // case 1:
        random_inputs[1][255*1-1:255*0] = 255'hc59041b7aa57a3757c9e652d111ec48d5f04d67039bae3300000232fffffdcd;
        random_inputs[1][255*2-1:255*1] = 255'h6f11990bfb9ca86bf726930e2de68f8d2ae0e9037e6993e592006fd957cd80e3;
        random_inputs[1][255*3-1:255*2] = 255'h36e238d3a6e96acaa0b7ca1ef44cacda4c5e26901cca0ea6a32fc9e630ddd0fa;
        random_inputs[1][255*4-1:255*3] = 255'hb4657784e4116ee2edf9d203daebda116557609d04365ef0db9afefff010171;
        random_inputs[1][255*5-1:255*4] = 255'h4f93a02c34551debecd2884e5141e95111e3a7899fb75dda37328085ef4ab379;
        random_inputs[1][255*6-1:255*5] = 255'h2e7e3e614381b4da1160d6a2d7b7abadbae14f0c2eefbc833f3d2ee049f16665;
        random_inputs[1][255*7-1:255*6] = 255'h704b3140f36f63f4f21afc8a2e1e1ec38b5a1ca67a610b0332e93ed2f0a291a8;
        random_inputs[1][255*8-1:255*7] = 255'h183213296a669d78a688377ab58eea5243cc8247d885d98bbe03a53620da02b2;
        random_inputs[1][255*9-1:255*8] = 255'h2b7fc36781eee8ee6ade67abd4205217d323be744cac9188428ecbdf70cc3838;
        
        ref_outputs[1] = 255'h996bc24754bdd40613c52f50cf55bc580dce6efa3f52fc694f652715ce557b8;

        // case 2:
        random_inputs[2][255*1-1:255*0] = 255'hc59041b7aa57a3757c9e652d111ec48d5f04d67039bae3300000232fffffdcd;
        random_inputs[2][255*2-1:255*1] = 255'h5ae52e74136a9e5f5100528fd2a33acbc8eacf411af217a5de145b5592610e4;
        random_inputs[2][255*3-1:255*2] = 255'h6b95ade0eabdca4331fcb448ea632dcb98dd04fcab223e39e974f7d2b4594bd4;
        random_inputs[2][255*4-1:255*3] = 255'h3c151224c5f8f1bac24fd648c57b7cf543ab361344727e0a20a1e83183a0926b;
        random_inputs[2][255*5-1:255*4] = 255'h49c34eb094f35eacee0031e5c32416394c6048e31bdc9ebc3dfa46e0d5db68ce;
        random_inputs[2][255*6-1:255*5] = 255'h131e26b1ba3ebba667cb7e680bcb84d022b0b1299a6a2ab7258e063fa5a0d940;
        random_inputs[2][255*7-1:255*6] = 255'h6da1f2037d27cc38ce4c1767b777baee66b0ae31cddc89b433a39d5c6bcb0652;
        random_inputs[2][255*8-1:255*7] = 255'h26edec17ca2a6b41a281cbd5056e8b1afcc49e2f3998bc2759dfbc039100f81a;
        random_inputs[2][255*9-1:255*8] = 255'hf11e5f0c53a80ad12f49da3c6970cb4707f7b73a486c868b925c7515726c990;
        
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
        resetn = 0;
        #(2*ClockPeriod) resetn = 1;
    end


    // drive input ports
    reg [254:0] io_input_payload;
    reg io_input_valid;
    wire io_input_ready, io_input_last;
    wire input_handshake = io_input_valid & io_input_ready;
    reg [1:0] input_counter;
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
    reg [1:0] output_counter;

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
