module bfm (
    
);
    bit clk;
    always #5 clk = ~clk;

    reg io_input_valid, io_input_last, io_output_ready, resetn;
    reg [254:0] io_input_payload;
    
    wire io_input_ready, io_output_valid, io_output_last;
    wire [254:0] io_output_payload;

    reg [7649:0] data;
    reg xmit_en = 0;
    reg [2:0] i = 0;
    reg flag = 1;
    reg [5:0] num = 0;

    always @(posedge clk) begin

        if(xmit_en && io_input_valid && io_input_ready) begin
            flag = 1;
        end

        if(xmit_en && flag) begin
            num = num + 1;
            io_input_valid = 1;
            io_input_payload = data[254:0];
            
            i = i + 1;
            if(i == 3) begin
                io_input_last = 1;
                i = 0;
            end else begin
                io_input_last = 0;
            end
            //$display("io_input_last:", io_input_last);
            //$display("io_input_payload:", io_input_payload);

            data = (data >> 255);
            flag = 0;
        end    

        if(!xmit_en && flag == 0) begin
            io_input_valid = 0;     
            flag = 1;
        end

        if(xmit_en && num >= 30) begin
            xmit_en = 0;     
            num = 0;   
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