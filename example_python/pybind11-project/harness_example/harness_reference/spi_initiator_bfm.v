module spi_initiator_bfm #(
		parameter DAT_WIDTH=8
        ) (
        input				clk,
        output				sck,
        output reg			sdo,
        input				sdi,
        output[3:0]			csn
        );

	reg[3:0]				csn_r = 4'he;
	reg[DAT_WIDTH-1:0]		dat_in_r;
	reg[DAT_WIDTH-1:0]		dat_out_v;
	reg[DAT_WIDTH-1:0]		dat_out_r;
	reg[1:0]				xmit_en = 0;
	reg[7:0]				sck_div = 0;
	reg[7:0]				sck_div_cnt = 0;

	reg sck_r = 0;
	wire sck_i = (sck_div)?sck_r:clk;
	assign sck = (xmit_en)?sck_i:1'b1;
	assign csn = (xmit_en)?csn_r:{4{1'b1}};
	
	always @(posedge clk) begin
		if (sck_div == sck_div_cnt) begin
			sck_r <= ~sck_r;
			sck_div_cnt <= 0;
		end else begin
			sck_div_cnt <= sck_div_cnt + 1;
		end
	end

	// Transmit state machine
	reg      xmit_state = 0;
	reg[7:0] xmit_count = 0;
	always @(negedge sck) begin
		sdo <= (xmit_state)?dat_out_r[DAT_WIDTH-1]:dat_out_v[DAT_WIDTH-1];
		case (xmit_state) 
			0: begin
				dat_out_r <= {dat_out_v[DAT_WIDTH-2:0], 1'b0};
				xmit_state <= 1'b1;
				xmit_count <= 1;
			end
			1: begin
				dat_out_r <= {dat_out_r[DAT_WIDTH-2:0], 1'b0};
				if (xmit_count == DAT_WIDTH-1) begin
					xmit_state <= 0;
				end else begin
					xmit_count <= xmit_count + 1;
				end
			end
		endcase
	end
	
	// Receive state machine
	reg      recv_state = 0;
	reg[7:0] recv_count = 0;
	always @(posedge sck) begin
		dat_in_r <= {dat_in_r[DAT_WIDTH-2:0], sdi};
		case (recv_state)
			0: begin
				if (xmit_en) begin
					recv_count <= 1;
					recv_state <= 1;
				end
			end
			1: begin
				if (recv_count == DAT_WIDTH-1) begin
					recv_state <= 0;
					// Send the resulting data back. Note that
					// The final bit hasn't been shifted in, so we
					// handle that here
					xmit_en = xmit_en - 1;
					recv({dat_in_r[DAT_WIDTH-2:0], sdi});
				end else begin
					recv_count <= recv_count + 1;
				end
			end
		endcase
	end
	
	task send(reg[63:0]	data);
	begin
		xmit_en = xmit_en + 1;
		dat_out_v = data[DAT_WIDTH-1:0];
	end
	endtask

    
	
    // Auto-generated code to implement the BFM API

${cocotb_bfm_api_impl}


endmodule
