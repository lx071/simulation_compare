module spi_initiator_bfm(
input   clk_i,
input   reset_i
);
    parameter DAT_WIDTH = 8;
    parameter TOTAL_WIDTH = 256;

	wire sck;
	reg sdo;
	wire sdi;
	wire[3:0] csn;
	wire sel;

    reg[3:0]				csn_r = 4'he;
	reg[TOTAL_WIDTH-1:0]		dat_in_r;
	reg[TOTAL_WIDTH-1:0]		dat_out_v;
	reg[TOTAL_WIDTH-1:0]		dat_out_r;
	reg xmit_en = 0;

	assign sel = csn[0];
    assign sck = (xmit_en)?clk_i:1'b0;

	SPI_Slave target(
			.clk(clk_i),
			.SCK(sck),
			.SSEL(sel),
			.MOSI(sdo),
			.MISO(sdi)
	);

	bit[255:0] data;
    reg[31:0] data_recv;

	initial begin
		//$dumpfile("dump.vcd");
		//$dumpvars;
		dat_out_v = 0;
		dat_in_r = 0;
		dat_out_r = 0;
		
		sdo = 0;
	end


    // Transmit state machine
	reg      xmit_state = 0;
	reg[7:0] xmit_count = 0;
	always @(posedge sck) begin
		sdo <= (xmit_state)?dat_out_r[TOTAL_WIDTH-1]:dat_out_v[TOTAL_WIDTH-1];
		case (xmit_state)
			0: begin
				dat_out_r <= {dat_out_v[TOTAL_WIDTH-2:0], 1'b0};
				xmit_state <= 1'b1;
				xmit_count <= 1;
			end
			1: begin
				dat_out_r <= {dat_out_r[TOTAL_WIDTH-2:0], 1'b0};
				if (xmit_count == TOTAL_WIDTH-1) begin
					xmit_state <= 0;
				end else begin
					xmit_count <= xmit_count + 1;
					//$display("xmit_count:",xmit_count);
				end
			end
		endcase
	end

	// Receive state machine
	reg      recv_state = 0;
	reg[7:0] recv_count = 0;
	//reg[7:0] data_out = 0;
	always @(negedge sck) begin
		dat_in_r <= {dat_in_r[TOTAL_WIDTH-2:0], sdi};
		case (recv_state)
			0: begin
				if (xmit_en) begin
					recv_count <= 1;
					recv_state <= 1;
				end
			end
			1: begin
				if (recv_count == TOTAL_WIDTH-1) begin
					// Send the resulting data back. Note that
					// The final bit hasn't been shifted in, so we
					// handle that here
					xmit_en = xmit_en - 1;
					recv_count <= 0;

				end else begin
					recv_count <= recv_count + 1;
				end

			end
		endcase
	end

endmodule
