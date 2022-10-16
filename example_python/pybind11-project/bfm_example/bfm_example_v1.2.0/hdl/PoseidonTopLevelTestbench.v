`timescale 1ns/1ps

module PoseidonTester ();

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, PoseidonTester);
    end

    localparam ClockPeriod = 10;
    localparam StateSize   = 9;
    localparam CaseNum     = 3;


    // init test cases
    reg [9*255-1:0] random_inputs[4:0];
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

        // case 3:
        random_inputs[3][255*1-1:255*0] = 255'h131e5658e4e089ceead74601fdd14684aaa1e2f1db2688ea7314f257f1ea6c8b;
        random_inputs[3][255*2-1:255*1] = 255'h38f255d3ef1caf602fca534a56eb6e3a08d725d288b011c50cd99fc9e758a90c;
        random_inputs[3][255*3-1:255*2] = 255'h232204c0054134e5a139d9b124b1b40944375798219015f5ed6a36b1645be62d;
        random_inputs[3][255*4-1:255*3] = 255'h41d8d2a3af3edaf054ab5eb256de955ccc5e95236553618753d11f7c8c4cf566;
        random_inputs[3][255*5-1:255*4] = 255'h2478593e91410e951358507e67cc771ee718fcbd668fa2fd673cc9c245583991;
        random_inputs[3][255*6-1:255*5] = 255'h3fd63868250700ea3f3caa114e7f3dfbe66069ac31b2152de091190c80c8976b;
        random_inputs[3][255*7-1:255*6] = 255'h50ec1326df5a43a8b9c0f1bb1dbdb670bd2f73594eb16dc5a2aacd6fdd2e2349;
        random_inputs[3][255*8-1:255*7] = 255'h44f796bbd8d40a8dffbf6fceefc8d65bb3bebec7711e69fe0299cbb7f6bd94a0;
        random_inputs[3][255*9-1:255*8] = 255'h53800bb12e2a215f0bbc52065fb3386ca058ebd9220da233c6e6f684f9f5000e;

        ref_outputs[3] = 255'h3f04b4c793ec7cf16c0f141ef4f15c4ed1e3693c3bc267920c22390b3a5382cd;

        // case 4:
        random_inputs[4][255*1-1:255*0] = 255'h11fc9a1c9a0edaa0b9626b834649b6d2c38c8ff1479a56ee4f47325a4a2737df;
        random_inputs[4][255*2-1:255*1] = 255'h586ba496bd0208ffa06b88dbcb7d18140e750311eab398a536534f0377e1d9d8;
        random_inputs[4][255*3-1:255*2] = 255'h71ffa5a0630e8e93f569f8df27911171e8f4f7b48f87f013071739e8a43dd4f4;
        random_inputs[4][255*4-1:255*3] = 255'h579703d904de19da95910673b92f197877799be2558d9786141ec2c823f98c7b;
        random_inputs[4][255*5-1:255*4] = 255'h6777cd4b80fe959ec826387a6e47b37e6ddf314e16070be6210df4a90a9a28eb;
        random_inputs[4][255*6-1:255*5] = 255'h678b4321e03796248e93071186382499afbb46f085f91d405d262a204d075cfb;
        random_inputs[4][255*7-1:255*6] = 255'h20935c6154700808fb36d926074ed0416c2eeca53393fbce01d01351fcf0ccde;
        random_inputs[4][255*8-1:255*7] = 255'h56976127842e4ac35d6a86e741ced6970ffbc8502c4106838950b21562f6c443;
        random_inputs[4][255*9-1:255*8] = 255'h1f5610ab9427ce82ab57ace256358596fbfb3daf13edf01b87299b7329f20251;

        ref_outputs[4] = 255'h19114c745a1bc368246be192841859be57790c3be6c74be9b629f4ccf2ff0d02;

        // case 5:
        random_inputs[5][255*1-1:255*0] = 255'h233f353e507005d2072df2d78034964ac09d80bc624be9975fd4a3dff6744a2d;
        random_inputs[5][255*2-1:255*1] = 255'h43da609d0a6606ed0aa1d284f9311e604ec9e1d70d585e2e9752796ce9dce1a8;
        random_inputs[5][255*3-1:255*2] = 255'h49f2727b6f7a8af852792780d3580530acf35a3413bfaab2d1d447879aa104da;
        random_inputs[5][255*4-1:255*3] = 255'h1763350ecf4f6442afb1de8571a9f84c6fd057ae8ad412b170443b1f17ea0d8f;
        random_inputs[5][255*5-1:255*4] = 255'h1f4ff65b7707dcedfa91eafebde269d6dfc15da2ca5f252675d6805d97528b13;
        random_inputs[5][255*6-1:255*5] = 255'h1fb8db143e638c9d8d234fdb3020a90d413ad844aafaf7191835c983d679c355;
        random_inputs[5][255*7-1:255*6] = 255'h65f4904639a491c2a107ce2316cb0457013258376666617f51f9f47fc797746a;
        random_inputs[5][255*8-1:255*7] = 255'h31023898fe62e4ee0ab509e008a4d6de78346abba5dde376961593e7891fb9f0;
        random_inputs[5][255*9-1:255*8] = 255'h1fec5a58530d2de7f5cab16365482458efd5b3a3a6d4c357eb69c1152378f3a9;

        ref_outputs[5] = 255'h4b155a215c66655d5963049ef9eaa9e2ea8d09f884fe4c73b201eefee0850cf7;

        // case 6:
        random_inputs[6][255*1-1:255*0] = 255'h4dc449d8617361373cfb980c27f9feb1137d789004edf73efd77734e3fa68224;
        random_inputs[6][255*2-1:255*1] = 255'h2eabf3629a397afc82233dac80f18c3ce1f3e5b75c40d2dda375a97a2597672e;
        random_inputs[6][255*3-1:255*2] = 255'h2589f0ffc2f0dca32936f11c43b4c2721e8f77e8637dd75345f1e3229f90807a;
        random_inputs[6][255*4-1:255*3] = 255'h2536a696dc4328af72efca55148bb848484e452927e0fb7c60f26b35c0a4225c;
        random_inputs[6][255*5-1:255*4] = 255'h54afbe26a1b3596181dbc75dc1e81f6264905fea94d4ae5fd3f7eb13e6407df4;
        random_inputs[6][255*6-1:255*5] = 255'h42b0d3c59362bddf0585787f130f402b9598def6dee256718017df105e30a955;
        random_inputs[6][255*7-1:255*6] = 255'h4d19988d68025f396e01cd24f213af6bd4ba7b4365303255d96fefc024d07c9a;
        random_inputs[6][255*8-1:255*7] = 255'h55691b40b2e8f5c01fcfae377cc1b03d8d3c806c46d7fcc2969212bfb6bff476;
        random_inputs[6][255*9-1:255*8] = 255'h6235b2d0d992370df0592b48f96264401861aa94bf264be7b538de40f23b7429;

        ref_outputs[6] = 255'h725c6601d3129d2e481590057d56d2c29b31edeb5d7298d7b5ef6d1cd5bbd41c;


        // case 7:
        random_inputs[7][255*1-1:255*0] = 255'hffaf74a703d7127316dee0a74dbaac5cfb5a6655692a69cecfd2531424f0ed1;
        random_inputs[7][255*2-1:255*1] = 255'h1339a4b5870515c5a3669bc659cc8cc0012d5782cf3b776ff55acc8f340b24d;
        random_inputs[7][255*3-1:255*2] = 255'h51bdb07c81e73d1deaa3447cadae94145cf747d63a6e3ddd8f3d5083b5225ef0;
        random_inputs[7][255*4-1:255*3] = 255'h60e2e169ff62bbb58917cc0825f4e0dc352a3d24d353df937b41a8b01f5a4db;
        random_inputs[7][255*5-1:255*4] = 255'h13ebfae6071a9e33e3a0d5c966ca547a855e313bbe56dde8a5cf6697180535d1;
        random_inputs[7][255*6-1:255*5] = 255'h5c1cb8f402ab745066dee46c8d8fa9b7fb9ec5800d4004c80a17776629951e8f;
        random_inputs[7][255*7-1:255*6] = 255'h1dfcb5cc1b00626f6d4f42f566c47dba75537aad1f4a8257e17b7e72559b2453;
        random_inputs[7][255*8-1:255*7] = 255'h4e20dc17fb1e19d839cf923b53b11cc53d748ef400f21e820d0b214fc6eaeea9;
        random_inputs[7][255*9-1:255*8] = 255'h13e6e2eab58f111c076085f909693ed3b92ef1162c8ba5ec570c1ddfd62b8400;

        ref_outputs[7] = 255'h48a7e93766e14a1bb546542673a66978937ad2dc92c2c94dd1a410005b966f25;


        // case 8:
        random_inputs[8][255*1-1:255*0] = 255'h2bb3184b16cc4e138786b03b86325d4d63167a41c458b7f27a34af30b8a44dc5;
        random_inputs[8][255*2-1:255*1] = 255'h27a4b496804412b414ba9d5c2e391de1f8e9a87a13e40d4a51f3a1019718ca89;
        random_inputs[8][255*3-1:255*2] = 255'h5d270d1c8c6295791519e6cc693f7d34209e7bf40a92d5a9f4cdf86cb5cabc04;
        random_inputs[8][255*4-1:255*3] = 255'h1db618d7c03c4a2acb0ac08edd13078b9aaa9f24f9b0dd000439a1d3a176e13c;
        random_inputs[8][255*5-1:255*4] = 255'h32c6934a2cdbe9b8823ab23ce1ac5a43661dc160391a35dd6520529a41633420;
        random_inputs[8][255*6-1:255*5] = 255'h5663ee7011e294af76e65a53362f9f2e17d9beaaf498fa6a87e2d8883f6fde83;
        random_inputs[8][255*7-1:255*6] = 255'h1208271d4a6fa39c8abbd447c86118f80b462fbf952930ea1e58b9e8edf3356;
        random_inputs[8][255*8-1:255*7] = 255'h3f2e6afc9853836adbd9ceebcd4e916d198b670ecc9080dd844c000b7e54f608;
        random_inputs[8][255*9-1:255*8] = 255'h42b46f301bb0b27df0106865730f72300348416010b95a123b227b96b8b9efcc;

        ref_outputs[8] = 255'h9cd8384c7efdc6b5576b438f652f7660162576971eef6ca60daab57d79e6b9;


        // case 9:
        random_inputs[9][255*1-1:255*0] = 255'h5366490121da2ed4138e49f7d4e70491784fca1fddcd0eac9daba5c025746373;
        random_inputs[9][255*2-1:255*1] = 255'h2d2ceaf46a46cb196da74494ea347300f4c83792544891564d3315b3064b756e;
        random_inputs[9][255*3-1:255*2] = 255'h3ed9f08d009e543d84eeb82fb016167a9701d9b54b3a825eb69b4e230cce65c6;
        random_inputs[9][255*4-1:255*3] = 255'h3e25d336c63aa157ea460c67e2b44f51bb291a54c6349133fd503fd22d61df39;
        random_inputs[9][255*5-1:255*4] = 255'h71b13b9d6deee0851c3f68cf6a045bab2c5943b682c63f8065980bd99e4e3ce9;
        random_inputs[9][255*6-1:255*5] = 255'h48151ce0ee128c4aeefe92e6ed59fc301807f0b2823a6c0b94103d5cabf00976;
        random_inputs[9][255*7-1:255*6] = 255'h6e0a69ac9e084010ed230c5d9f92ae412482589c256e9e117b11f42bdfd1b438;
        random_inputs[9][255*8-1:255*7] = 255'h67cc89eab2ccc8f9d67fe163881dddc2605b54ecadf41498c573a3b4165d0611;
        random_inputs[9][255*9-1:255*8] = 255'h6c7b13f7d2a87d6e2248ef16a11e1bcd849aa9981afb07f73bb5ce3fec4e56ed;

        ref_outputs[9] = 255'h2eeef73349fa0ae266b1eb15006a45580f1c612dbdd2a5bff53ce2d5cc02f9ab;


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
            if(input_counter < 10) begin
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
                $display("ref_outputs[output_counter]: %d",ref_outputs[output_counter]);
                $display("res %d: %h correct",output_counter, io_output_payload);
                output_counter <= output_counter + 1;
            end

            if(output_counter == 10) begin
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
