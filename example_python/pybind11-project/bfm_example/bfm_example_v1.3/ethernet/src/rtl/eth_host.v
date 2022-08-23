`include "tb_eth_defines.v"
`include "timescale.v"

module eth_host
(
  // WISHBONE common
  wb_clk_i, wb_rst_i, 
  
  // WISHBONE master
  wb_adr_o, wb_sel_o, wb_we_o, wb_dat_i, wb_dat_o, wb_cyc_o, wb_stb_o, wb_ack_i, wb_err_i
);

parameter Tp=1;

input         wb_clk_i, wb_rst_i;

input  [31:0] wb_dat_i;
input         wb_ack_i, wb_err_i;

output [31:0] wb_adr_o, wb_dat_o;
output  [3:0] wb_sel_o;
output        wb_cyc_o, wb_stb_o, wb_we_o;

reg    [31:0] wb_adr_o, wb_dat_o;
reg     [3:0] wb_sel_o;
reg           wb_cyc_o, wb_stb_o, wb_we_o;

integer host_log;

// Reset pulse
initial
begin
  host_log = $fopen("eth_host.log");
end


task wb_write;

  input  [31:0] addr;
  input   [3:0] sel;
  input  [31:0] data;

  begin
    @ (posedge wb_clk_i);   // Sync. with clock
    #1;
    wb_adr_o = addr;
    wb_dat_o = data;
    wb_sel_o = sel;
    wb_cyc_o = 1;
    wb_stb_o = 1;
    wb_we_o  = 1;
  
    wait(wb_ack_i | wb_err_i);
    $fdisplay(host_log, "(%0t)(%m)wb_write (0x%0x) = 0x%0x", $time, wb_adr_o, wb_dat_o);
    @ (posedge wb_clk_i);   // Sync. with clock
    #1;
    wb_adr_o = 'hx;
    wb_dat_o = 'hx;
    wb_sel_o = 'hx;
    wb_cyc_o = 0;
    wb_stb_o = 0;
    wb_we_o  = 'hx;
  end
endtask


task wb_read;

  input  [31:0] addr;
  input   [3:0] sel;
  output [31:0] data;

  begin
    @ (posedge wb_clk_i);   // Sync. with clock
    #1;
    wb_adr_o = addr;
    wb_sel_o = sel;
    wb_cyc_o = 1;
    wb_stb_o = 1;
    wb_we_o  = 0;
  
    wait(wb_ack_i | wb_err_i);
    @ (posedge wb_clk_i);   // Sync. with clock
    data = wb_dat_i;
    $fdisplay(host_log, "(%0t)(%m)wb_read (0x%0x) = 0x%0x", $time, wb_adr_o, wb_dat_i);
    #1;
    wb_adr_o = 'hx;
    wb_sel_o = 'hx;
    wb_cyc_o = 0;
    wb_stb_o = 0;
    wb_we_o  = 'hx;
  end
endtask



endmodule
