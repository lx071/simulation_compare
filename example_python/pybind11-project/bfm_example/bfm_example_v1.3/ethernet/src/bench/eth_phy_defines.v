`define ETH_PHY_ADDR                 5'h01

// LED/Configuration pins on PHY device - see the specification, page 26, table 8
// Initial set of bits 13, 12 and 8 of Control Register
`define LED_CFG1                     1'b0
`define LED_CFG2                     1'b0
`define LED_CFG3                     1'b1

// Supported speeds and physical ports - see the specification, page 67, table 41
// Set bits 15 to 9 of Status Register
`define SUPPORTED_SPEED_AND_PORT     7'h3F

// Extended status register (address 15)
// Set bit 8 of Status Register
`define EXTENDED_STATUS              1'b0

// Default status bits - see the specification, page 67, table 41
// Set bits 6 to 0 of Status Register
`define DEFAULT_STATUS               7'h09

// PHY ID 1 number - see the specification, page 68, table 42
// Set bits of Phy Id Register 1
`define PHY_ID1                      16'h0013

// PHY ID 2 number - see the specification, page 68, table 43
// Set bits 15 to 10 of Phy Id Register 2
`define PHY_ID2                      6'h1E

// Manufacturer MODEL number - see the specification, page 68, table 43
// Set bits 9 to 4 of Phy Id Register 2
`define MAN_MODEL_NUM                6'h0E

// Manufacturer REVISION number - see the specification, page 68, table 43
// Set bits 3 to 0 of Phy Id Register 2
`define MAN_REVISION_NUM             4'h2




