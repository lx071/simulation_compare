`timescale 1ns/1ps 

module bfm (
    
);
    reg clk;

    reg io_input_valid, io_input_last, io_output_ready, resetn;
    reg [254:0] io_input_payload;
    
    wire io_input_ready, io_output_valid, io_output_last;
    wire [254:0] io_output_payload;

    reg [254:0] ref_input;
    reg [254:0] ref_output;
    reg xmit_en = 0;
    reg [2:0] i = 0;
    reg flag = 1;
    reg [8:0] num = 0;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        io_input_payload = 0;
        io_input_valid = 0;
        io_input_last = 0;
        resetn = 0;
        io_output_ready = 1;
        ref_input = 255'h5f6d26e8b89772df73b49b719b5e946cdf1d5518ba3eefca94032a29cc0a4c5f;
        ref_output = 255'h132e0fb58f03f49eafd655b559cbf6e2bd371c269f8039cbd3fa6f6b17a29797;
        #100 
        resetn = 1;
        xmit_en = 1;
    end

    always @(posedge clk) begin
    
        if(xmit_en && io_input_valid && io_input_ready) begin
            flag = 1;
        end

        if(xmit_en && flag) begin
            num = num + 1;
            io_input_valid = 1;
            io_input_payload = ref_input;
            
            i = i + 1;
            if(i == 3) begin
                io_input_last = 1;
                i = 0;
            end else begin
                io_input_last = 0;
            end
            //$display("io_input_last:", io_input_last);
            //$display("io_input_payload:", io_input_payload);

            flag = 0;
        end    

        if(!xmit_en && flag == 0) begin
            io_input_valid = 0;     
            flag = 1;
        end

        if(xmit_en && num >= 300) begin
            xmit_en = 0;     
            num = 0;   
        end
        
    end
    
    wire output_handshake = io_output_valid & io_output_ready;
    reg [6:0] output_counter;

    //assign io_output_ready = 1'b1;
    always@(posedge clk) begin
        if(~resetn) begin
            output_counter <= 0;
        end
        else begin
            if(output_handshake) begin
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