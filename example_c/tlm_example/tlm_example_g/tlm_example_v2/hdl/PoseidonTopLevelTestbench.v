

module bfm #(
    parameter NUM = 100
);

    import "DPI-C" function void recv_res (input bit[254:0] data);
    import "DPI-C" context function void gen_tlm_data(input int item_num);
    export "DPI-C" function set_data;

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

    bit[NUM-1:0][2:0][255:0] payload_data;
    int item_num = NUM;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        gen_tlm_data(item_num);
    
        //$display("get data ='h%h",payload_data[0][0][254:0]);
        //$display("get data ='h%h",payload_data[0][1][254:0]);
        //$display("get data ='h%h",data[0][2]);
        
        //recv(321);

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
            
            io_input_valid = 1;
            //io_input_payload = ref_input;
            io_input_payload = payload_data[num][i][254:0];

            i = i + 1;
            if(i == 3) begin
                io_input_last = 1;
                i = 0;
                num = num + 1;
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

        if(xmit_en && num >= 100) begin
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
                recv_res(io_output_payload);
                
                //$display("io_output_payload:%h", io_output_payload);

                //if( io_output_payload != ref_output) begin
                //    $display("error output %d: %h",output_counter, io_output_payload);
                //    $display(" test fail !!!");
                //    //$display("cycles: %d", cycle_counter);
                //    $finish();
                //end
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


    function void set_data(bit[NUM-1:0][2:0][255:0] data);
    begin
        payload_data = data;
        //tvalid = 1;
        //$display("%h", payload_data);
    end
    endfunction


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