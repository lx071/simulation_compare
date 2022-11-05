module SPI_Slave(
                 clk,
                 SCK, SSEL, MOSI,MISO//SPI communication pin

                 );
 input clk;
 input SCK, SSEL, MOSI;
 output MISO;

 reg [7:0] mem;

 assign MISO = MOSI;

 always @(posedge SCK)
 	begin
 		if (SSEL) begin
 			if (mem == 255) begin
 				mem <= 0;
 			end else begin
 				mem <= mem + 1;
 			end
 		end
 	end
 endmodule