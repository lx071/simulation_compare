`define ETH_MBIST_CTRL_WIDTH 3        // width of MBIST control bus

// Ethernet implemented in Xilinx Chips
// `define ETH_FIFO_XILINX             // Use Xilinx distributed ram for tx and rx fifo
// `define ETH_XILINX_RAMB4            // Selection of the used memory for Buffer descriptors
                                      // Core is going to be implemented in Virtex FPGA and contains Virtex 
                                      // specific elements. 

// Ethernet implemented in ASIC with Virtual Silicon RAMs
// `define ETH_VIRTUAL_SILICON_RAM     // Virtual Silicon RAMS used storing buffer decriptors (ASIC implementation)
// `define ETH_ARTISAN_RAM             // Artisan RAMS used storing buffer decriptors (ASIC implementation)

`define ETH_MODER_ADR         8'h0    // 0x0 
`define ETH_INT_SOURCE_ADR    8'h1    // 0x4 
`define ETH_INT_MASK_ADR      8'h2    // 0x8 
`define ETH_IPGT_ADR          8'h3    // 0xC 
`define ETH_IPGR1_ADR         8'h4    // 0x10
`define ETH_IPGR2_ADR         8'h5    // 0x14
`define ETH_PACKETLEN_ADR     8'h6    // 0x18
`define ETH_COLLCONF_ADR      8'h7    // 0x1C
`define ETH_TX_BD_NUM_ADR     8'h8    // 0x20
`define ETH_CTRLMODER_ADR     8'h9    // 0x24
`define ETH_MIIMODER_ADR      8'hA    // 0x28
`define ETH_MIICOMMAND_ADR    8'hB    // 0x2C
`define ETH_MIIADDRESS_ADR    8'hC    // 0x30
`define ETH_MIITX_DATA_ADR    8'hD    // 0x34
`define ETH_MIIRX_DATA_ADR    8'hE    // 0x38
`define ETH_MIISTATUS_ADR     8'hF    // 0x3C
`define ETH_MAC_ADDR0_ADR     8'h10   // 0x40
`define ETH_MAC_ADDR1_ADR     8'h11   // 0x44
`define ETH_HASH0_ADR         8'h12   // 0x48
`define ETH_HASH1_ADR         8'h13   // 0x4C
`define ETH_TX_CTRL_ADR       8'h14   // 0x50
`define ETH_RX_CTRL_ADR       8'h15   // 0x54


`define ETH_MODER_DEF_0         8'h00
`define ETH_MODER_DEF_1         8'hA0
`define ETH_MODER_DEF_2         1'h0
`define ETH_INT_MASK_DEF_0      7'h0
`define ETH_IPGT_DEF_0          7'h12
`define ETH_IPGR1_DEF_0         7'h0C
`define ETH_IPGR2_DEF_0         7'h12
`define ETH_PACKETLEN_DEF_0     8'h00
`define ETH_PACKETLEN_DEF_1     8'h06
`define ETH_PACKETLEN_DEF_2     8'h40
`define ETH_PACKETLEN_DEF_3     8'h00
`define ETH_COLLCONF_DEF_0      6'h3f
`define ETH_COLLCONF_DEF_2      4'hF
`define ETH_TX_BD_NUM_DEF_0     8'h40
`define ETH_CTRLMODER_DEF_0     3'h0
`define ETH_MIIMODER_DEF_0      8'h64
`define ETH_MIIMODER_DEF_1      1'h0
`define ETH_MIIADDRESS_DEF_0    5'h00
`define ETH_MIIADDRESS_DEF_1    5'h00
`define ETH_MIITX_DATA_DEF_0    8'h00
`define ETH_MIITX_DATA_DEF_1    8'h00
`define ETH_MIIRX_DATA_DEF     16'h0000 // not written from WB
`define ETH_MAC_ADDR0_DEF_0     8'h00
`define ETH_MAC_ADDR0_DEF_1     8'h00
`define ETH_MAC_ADDR0_DEF_2     8'h00
`define ETH_MAC_ADDR0_DEF_3     8'h00
`define ETH_MAC_ADDR1_DEF_0     8'h00
`define ETH_MAC_ADDR1_DEF_1     8'h00
`define ETH_HASH0_DEF_0         8'h00
`define ETH_HASH0_DEF_1         8'h00
`define ETH_HASH0_DEF_2         8'h00
`define ETH_HASH0_DEF_3         8'h00
`define ETH_HASH1_DEF_0         8'h00
`define ETH_HASH1_DEF_1         8'h00
`define ETH_HASH1_DEF_2         8'h00
`define ETH_HASH1_DEF_3         8'h00
`define ETH_TX_CTRL_DEF_0       8'h00 //
`define ETH_TX_CTRL_DEF_1       8'h00 //
`define ETH_TX_CTRL_DEF_2       1'h0  //
`define ETH_RX_CTRL_DEF_0       8'h00
`define ETH_RX_CTRL_DEF_1       8'h00


`define ETH_MODER_WIDTH_0       8
`define ETH_MODER_WIDTH_1       8
`define ETH_MODER_WIDTH_2       1
`define ETH_INT_SOURCE_WIDTH_0  7
`define ETH_INT_MASK_WIDTH_0    7
`define ETH_IPGT_WIDTH_0        7
`define ETH_IPGR1_WIDTH_0       7
`define ETH_IPGR2_WIDTH_0       7
`define ETH_PACKETLEN_WIDTH_0   8
`define ETH_PACKETLEN_WIDTH_1   8
`define ETH_PACKETLEN_WIDTH_2   8
`define ETH_PACKETLEN_WIDTH_3   8
`define ETH_COLLCONF_WIDTH_0    6
`define ETH_COLLCONF_WIDTH_2    4
`define ETH_TX_BD_NUM_WIDTH_0   8
`define ETH_CTRLMODER_WIDTH_0   3
`define ETH_MIIMODER_WIDTH_0    8
`define ETH_MIIMODER_WIDTH_1    1
`define ETH_MIICOMMAND_WIDTH_0  3
`define ETH_MIIADDRESS_WIDTH_0  5
`define ETH_MIIADDRESS_WIDTH_1  5
`define ETH_MIITX_DATA_WIDTH_0  8
`define ETH_MIITX_DATA_WIDTH_1  8
`define ETH_MIIRX_DATA_WIDTH    16 // not written from WB
`define ETH_MIISTATUS_WIDTH     3 // not written from WB
`define ETH_MAC_ADDR0_WIDTH_0   8
`define ETH_MAC_ADDR0_WIDTH_1   8
`define ETH_MAC_ADDR0_WIDTH_2   8
`define ETH_MAC_ADDR0_WIDTH_3   8
`define ETH_MAC_ADDR1_WIDTH_0   8
`define ETH_MAC_ADDR1_WIDTH_1   8
`define ETH_HASH0_WIDTH_0       8
`define ETH_HASH0_WIDTH_1       8
`define ETH_HASH0_WIDTH_2       8
`define ETH_HASH0_WIDTH_3       8
`define ETH_HASH1_WIDTH_0       8
`define ETH_HASH1_WIDTH_1       8
`define ETH_HASH1_WIDTH_2       8
`define ETH_HASH1_WIDTH_3       8
`define ETH_TX_CTRL_WIDTH_0     8
`define ETH_TX_CTRL_WIDTH_1     8
`define ETH_TX_CTRL_WIDTH_2     1
`define ETH_RX_CTRL_WIDTH_0     8
`define ETH_RX_CTRL_WIDTH_1     8


// Outputs are registered (uncomment when needed)
`define ETH_REGISTERED_OUTPUTS

// Settings for TX FIFO
`define ETH_TX_FIFO_CNT_WIDTH  5
`define ETH_TX_FIFO_DEPTH      16
`define ETH_TX_FIFO_DATA_WIDTH 32

// Settings for RX FIFO
`define ETH_RX_FIFO_CNT_WIDTH  5
`define ETH_RX_FIFO_DEPTH      16
`define ETH_RX_FIFO_DATA_WIDTH 32

// Burst length
`define ETH_BURST_LENGTH       4    // Change also ETH_BURST_CNT_WIDTH
`define ETH_BURST_CNT_WIDTH    3    // The counter must be width enough to count to ETH_BURST_LENGTH

// WISHBONE interface is Revision B3 compliant (uncomment when needed)
//`define ETH_WISHBONE_B3


// Following defines are needed when eth_cop.v is used. Otherwise they may be deleted.
`define ETH_BASE              32'hd0000000
`define ETH_WIDTH             32'h800
`define MEMORY_BASE           32'h2000
`define MEMORY_WIDTH          32'h10000

`define M1_ADDRESSED_S1 ( (m1_wb_adr_i >= `ETH_BASE)    & (m1_wb_adr_i < (`ETH_BASE    + `ETH_WIDTH   )) )
`define M1_ADDRESSED_S2 ( (m1_wb_adr_i >= `MEMORY_BASE) & (m1_wb_adr_i < (`MEMORY_BASE + `MEMORY_WIDTH)) )
`define M2_ADDRESSED_S1 ( (m2_wb_adr_i >= `ETH_BASE)    & (m2_wb_adr_i < (`ETH_BASE    + `ETH_WIDTH   )) )
`define M2_ADDRESSED_S2 ( (m2_wb_adr_i >= `MEMORY_BASE) & (m2_wb_adr_i < (`MEMORY_BASE + `MEMORY_WIDTH)) )
// Previous defines are only needed for eth_cop.v

