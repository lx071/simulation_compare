`define WB_FREQ 0.100

// memory frequency in GHz
`define MEM_FREQ 0.100

// setup and hold time definitions for WISHBONE - used in BFMs for signal generation
`define Tsetup 4
`define Thold  1

// how many clock cycles should model wait for design's response - integer 32 bit value
`define WAIT_FOR_RESPONSE 1023

// maximum number of transactions allowed in single call to block or cab transfer routines
`define MAX_BLK_SIZE  1024

// maximum retry terminations allowed for WISHBONE master to repeat an access
`define WB_TB_MAX_RTY 0


// some common types and defines
`define WB_ADDR_WIDTH 32
`define WB_DATA_WIDTH 32
`define WB_SEL_WIDTH `WB_DATA_WIDTH/8
`define WB_TAG_WIDTH 5
`define WB_ADDR_TYPE [(`WB_ADDR_WIDTH - 1):0]
`define WB_DATA_TYPE [(`WB_DATA_WIDTH - 1):0]
`define WB_SEL_TYPE  [(`WB_SEL_WIDTH  - 1):0]
`define WB_TAG_TYPE  [(`WB_TAG_WIDTH  - 1):0]

// read cycle stimulus - consists of:
//    - address field - which address read will be performed from
//    - sel field     - what byte select value should be
//    - tag field     - what tag values should be put on the bus
`define READ_STIM_TYPE [(`WB_ADDR_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH - 1):0]
`define READ_STIM_LENGTH (`WB_ADDR_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH)
`define READ_ADDRESS  [(`WB_ADDR_WIDTH - 1):0]
`define READ_SEL      [(`WB_ADDR_WIDTH + `WB_SEL_WIDTH - 1):`WB_ADDR_WIDTH]
`define READ_TAG_STIM [(`WB_ADDR_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH - 1):(`WB_ADDR_WIDTH + `WB_SEL_WIDTH)]

// read cycle return type consists of:
//    - read data field
//    - tag field received from WISHBONE
//    - wishbone slave response fields - ACK, ERR and RTY
//    - test bench error indicator (when testcase has not used wb master model properly)
//    - how much data was actually transfered
`define READ_RETURN_TYPE [(32 + 4 + `WB_DATA_WIDTH + `WB_TAG_WIDTH - 1):0]
`define READ_DATA        [(32 + `WB_DATA_WIDTH + 4 - 1):32 + 4]
`define READ_TAG_RET     [(32 + 4 + `WB_DATA_WIDTH + `WB_TAG_WIDTH - 1):(`WB_DATA_WIDTH + 32 + 4)]
`define READ_RETURN_LENGTH (32 + 4 + `WB_DATA_WIDTH + `WB_TAG_WIDTH - 1)

// write cycle stimulus type consists of
//    - address field
//    - data field
//    - sel field
//    - tag field
`define WRITE_STIM_TYPE [(`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH - 1):0]
`define WRITE_ADDRESS       [(`WB_ADDR_WIDTH - 1):0]
`define WRITE_DATA          [(`WB_ADDR_WIDTH + `WB_DATA_WIDTH - 1):`WB_ADDR_WIDTH]
`define WRITE_SEL           [(`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH - 1):(`WB_ADDR_WIDTH + `WB_DATA_WIDTH)]
`define WRITE_TAG_STIM      [(`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH - 1):(`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH)]

// length of WRITE_STIMULUS
`define WRITE_STIM_LENGTH (`WB_ADDR_WIDTH + `WB_DATA_WIDTH + `WB_SEL_WIDTH + `WB_TAG_WIDTH)

// write cycle return type consists of:
//    - test bench error indicator (when testcase has not used wb master model properly)
//    - wishbone slave response fields - ACK, ERR and RTY
//    - tag field received from WISHBONE
//    - how much data was actually transfered
`define WRITE_RETURN_TYPE [(32 + 4 + `WB_TAG_WIDTH - 1):0]
`define WRITE_TAG_RET     [(32 + 4 + `WB_TAG_WIDTH - 1):32 + 4]

// this four fields are common to both read and write routines return values
`define TB_ERROR_BIT [0]
`define CYC_ACK [1]
`define CYC_RTY [2]
`define CYC_ERR [3]
`define CYC_RESPONSE [3:1]
`define CYC_ACTUAL_TRANSFER [35:4]

// block transfer flags
`define WB_TRANSFER_FLAGS [41:0]
// consists of:
// - number of transfer cycles to perform
// - flag that enables retry termination handling - if disabled, block transfer routines will return on any termination other than acknowledge
// - flag indicating CAB transfer is to be performed - ignored by all single transfer routines
// - number of initial wait states to insert
// - number of subsequent wait states to insert
`define WB_TRANSFER_SIZE     [41:10]
`define WB_TRANSFER_AUTO_RTY [8]
`define WB_TRANSFER_CAB      [9]
`define INIT_WAITS           [3:0]
`define SUBSEQ_WAITS         [7:4]

// wb slave response
`define ACK_RESPONSE  3'b100
`define ERR_RESPONSE  3'b010
`define RTY_RESPONSE  3'b001
`define NO_RESPONSE   3'b000
