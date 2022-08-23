`include "timescale.v"


module eth_txcounters (StatePreamble, StateIPG, StateData, StatePAD, StateFCS, StateJam, 
                       StateBackOff, StateDefer, StateIdle, StartDefer, StartIPG, StartFCS, 
                       StartJam, StartBackoff, TxStartFrm, MTxClk, Reset, MinFL, MaxFL, HugEn, 
                       ExDfrEn, PacketFinished_q, DlyCrcEn, StateSFD, ByteCnt, NibCnt, 
                       ExcessiveDefer, NibCntEq7, NibCntEq15, MaxFrame, NibbleMinFl, DlyCrcCnt
                      );

parameter Tp = 1;

input MTxClk;             // Tx clock
input Reset;              // Reset
input StatePreamble;      // Preamble state
input StateIPG;           // IPG state
input [1:0] StateData;    // Data state
input StatePAD;           // PAD state
input StateFCS;           // FCS state
input StateJam;           // Jam state
input StateBackOff;       // Backoff state
input StateDefer;         // Defer state
input StateIdle;          // Idle state
input StateSFD;           // SFD state
input StartDefer;         // Defer state will be activated in next clock
input StartIPG;           // IPG state will be activated in next clock
input StartFCS;           // FCS state will be activated in next clock
input StartJam;           // Jam state will be activated in next clock
input StartBackoff;       // Backoff state will be activated in next clock
input TxStartFrm;         // Tx start frame
input [15:0] MinFL;       // Minimum frame length (in bytes)
input [15:0] MaxFL;       // Miximum frame length (in bytes)
input HugEn;              // Pakets bigger then MaxFL enabled
input ExDfrEn;            // Excessive deferral enabled
input PacketFinished_q;             
input DlyCrcEn;           // Delayed CRC enabled

output [15:0] ByteCnt;    // Byte counter
output [15:0] NibCnt;     // Nibble counter
output ExcessiveDefer;    // Excessive Deferral occuring
output NibCntEq7;         // Nibble counter is equal to 7
output NibCntEq15;        // Nibble counter is equal to 15
output MaxFrame;          // Maximum frame occured
output NibbleMinFl;       // Nibble counter is greater than the minimum frame length
output [2:0] DlyCrcCnt;   // Delayed CRC Count

wire ExcessiveDeferCnt;
wire ResetNibCnt;
wire IncrementNibCnt;
wire ResetByteCnt;
wire IncrementByteCnt;
wire ByteCntMax;

reg [15:0] NibCnt;
reg [15:0] ByteCnt;
reg  [2:0] DlyCrcCnt;



assign IncrementNibCnt = StateIPG | StatePreamble | (|StateData) | StatePAD 
                       | StateFCS | StateJam | StateBackOff | StateDefer & ~ExcessiveDefer & TxStartFrm;


assign ResetNibCnt = StateDefer & ExcessiveDefer & ~TxStartFrm | StatePreamble & NibCntEq15 
                   | StateJam & NibCntEq7 | StateIdle | StartDefer | StartIPG | StartFCS | StartJam;

// Nibble Counter
always @ (posedge MTxClk or posedge Reset)
begin
  if(Reset)
    NibCnt <= #Tp 16'h0;
  else
    begin
      if(ResetNibCnt)
        NibCnt <= #Tp 16'h0;
      else
      if(IncrementNibCnt)
        NibCnt <= #Tp NibCnt + 1'b1;
     end
end


assign NibCntEq7   = &NibCnt[2:0];
assign NibCntEq15  = &NibCnt[3:0];

assign NibbleMinFl = NibCnt >= (((MinFL-3'h4)<<1) -1);  // FCS should not be included in NibbleMinFl

assign ExcessiveDeferCnt = NibCnt[13:0] == 16'h17b7;

assign ExcessiveDefer  = NibCnt[13:0] == 16'h17b7 & ~ExDfrEn;   // 6071 nibbles

assign IncrementByteCnt = StateData[1] & ~ByteCntMax
                        | StateBackOff & (&NibCnt[6:0])
                        | (StatePAD | StateFCS) & NibCnt[0] & ~ByteCntMax;

assign ResetByteCnt = StartBackoff | StateIdle & TxStartFrm | PacketFinished_q;


// Transmit Byte Counter
always @ (posedge MTxClk or posedge Reset)
begin
  if(Reset)
    ByteCnt[15:0] <= #Tp 16'h0;
  else
    begin
      if(ResetByteCnt)
        ByteCnt[15:0] <= #Tp 16'h0;
      else
      if(IncrementByteCnt)
        ByteCnt[15:0] <= #Tp ByteCnt[15:0] + 1'b1;
    end
end


assign MaxFrame = ByteCnt[15:0] == MaxFL[15:0] & ~HugEn;

assign ByteCntMax = &ByteCnt[15:0];


// Delayed CRC counter
always @ (posedge MTxClk or posedge Reset)
begin
  if(Reset)
    DlyCrcCnt <= #Tp 3'h0;
  else
    begin        
      if(StateData[1] & DlyCrcCnt == 3'h4 | StartJam | PacketFinished_q)
        DlyCrcCnt <= #Tp 3'h0;
      else
      if(DlyCrcEn & (StateSFD | StateData[1] & (|DlyCrcCnt[2:0])))
        DlyCrcCnt <= #Tp DlyCrcCnt + 1'b1;
    end
end



endmodule
