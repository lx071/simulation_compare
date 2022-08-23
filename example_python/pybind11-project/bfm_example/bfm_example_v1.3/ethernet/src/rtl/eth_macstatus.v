`include "timescale.v"


module eth_macstatus(
                      MRxClk, Reset, ReceivedLengthOK, ReceiveEnd, ReceivedPacketGood, RxCrcError, 
                      MRxErr, MRxDV, RxStateSFD, RxStateData, RxStatePreamble, RxStateIdle, Transmitting, 
                      RxByteCnt, RxByteCntEq0, RxByteCntGreat2, RxByteCntMaxFrame, 
                      InvalidSymbol, MRxD, LatchedCrcError, Collision, CollValid, RxLateCollision,
                      r_RecSmall, r_MinFL, r_MaxFL, ShortFrame, DribbleNibble, ReceivedPacketTooBig, r_HugEn,
                      LoadRxStatus, StartTxDone, StartTxAbort, RetryCnt, RetryCntLatched, MTxClk, MaxCollisionOccured, 
                      RetryLimit, LateCollision, LateCollLatched, DeferIndication, DeferLatched, RstDeferLatched, TxStartFrm,
                      StatePreamble, StateData, CarrierSense, CarrierSenseLost, TxUsedData, LatchedMRxErr, Loopback, 
                      r_FullD
                    );



parameter Tp = 1;


input         MRxClk;
input         Reset;
input         RxCrcError;
input         MRxErr;
input         MRxDV;

input         RxStateSFD;
input   [1:0] RxStateData;
input         RxStatePreamble;
input         RxStateIdle;
input         Transmitting;
input  [15:0] RxByteCnt;
input         RxByteCntEq0;
input         RxByteCntGreat2;
input         RxByteCntMaxFrame;
input   [3:0] MRxD;
input         Collision;
input   [5:0] CollValid;
input         r_RecSmall;
input  [15:0] r_MinFL;
input  [15:0] r_MaxFL;
input         r_HugEn;
input         StartTxDone;
input         StartTxAbort;
input   [3:0] RetryCnt;
input         MTxClk;
input         MaxCollisionOccured;
input         LateCollision;
input         DeferIndication;
input         TxStartFrm;
input         StatePreamble;
input   [1:0] StateData;
input         CarrierSense;
input         TxUsedData;
input         Loopback;
input         r_FullD;


output        ReceivedLengthOK;
output        ReceiveEnd;
output        ReceivedPacketGood;
output        InvalidSymbol;
output        LatchedCrcError;
output        RxLateCollision;
output        ShortFrame;
output        DribbleNibble;
output        ReceivedPacketTooBig;
output        LoadRxStatus;
output  [3:0] RetryCntLatched;
output        RetryLimit;
output        LateCollLatched;
output        DeferLatched;
input         RstDeferLatched;
output        CarrierSenseLost;
output        LatchedMRxErr;


reg           ReceiveEnd;

reg           LatchedCrcError;
reg           LatchedMRxErr;
reg           LoadRxStatus;
reg           InvalidSymbol;
reg     [3:0] RetryCntLatched;
reg           RetryLimit;
reg           LateCollLatched;
reg           DeferLatched;
reg           CarrierSenseLost;

wire          TakeSample;
wire          SetInvalidSymbol; // Invalid symbol was received during reception in 100Mbps 

// Crc error
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    LatchedCrcError <=#Tp 1'b0;
  else
  if(RxStateSFD)
    LatchedCrcError <=#Tp 1'b0;
  else
  if(RxStateData[0])
    LatchedCrcError <=#Tp RxCrcError & ~RxByteCntEq0;
end


// LatchedMRxErr
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    LatchedMRxErr <=#Tp 1'b0;
  else
  if(MRxErr & MRxDV & (RxStatePreamble | RxStateSFD | (|RxStateData) | RxStateIdle & ~Transmitting))
    LatchedMRxErr <=#Tp 1'b1;
  else
    LatchedMRxErr <=#Tp 1'b0;
end


// ReceivedPacketGood
assign ReceivedPacketGood = ~LatchedCrcError;


// ReceivedLengthOK
assign ReceivedLengthOK = RxByteCnt[15:0] >= r_MinFL[15:0] & RxByteCnt[15:0] <= r_MaxFL[15:0];





// Time to take a sample
//assign TakeSample = |RxStateData     & ~MRxDV & RxByteCntGreat2  |
assign TakeSample = (|RxStateData)   & (~MRxDV)                    |
                      RxStateData[0] &   MRxDV & RxByteCntMaxFrame;


// LoadRxStatus
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    LoadRxStatus <=#Tp 1'b0;
  else
    LoadRxStatus <=#Tp TakeSample;
end



// ReceiveEnd
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    ReceiveEnd  <=#Tp 1'b0;
  else
    ReceiveEnd  <=#Tp LoadRxStatus;                     
end


// Invalid Symbol received during 100Mbps mode
assign SetInvalidSymbol = MRxDV & MRxErr & MRxD[3:0] == 4'he;


// InvalidSymbol
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    InvalidSymbol <=#Tp 1'b0;
  else
  if(LoadRxStatus & ~SetInvalidSymbol)
    InvalidSymbol <=#Tp 1'b0;
  else
  if(SetInvalidSymbol)
    InvalidSymbol <=#Tp 1'b1;
end


// Late Collision

reg RxLateCollision;
reg RxColWindow;
// Collision Window
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    RxLateCollision <=#Tp 1'b0;
  else
  if(LoadRxStatus)
    RxLateCollision <=#Tp 1'b0;
  else
  if(Collision & (~r_FullD) & (~RxColWindow | r_RecSmall))
    RxLateCollision <=#Tp 1'b1;
end

// Collision Window
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    RxColWindow <=#Tp 1'b1;
  else
  if(~Collision & RxByteCnt[5:0] == CollValid[5:0] & RxStateData[1])
    RxColWindow <=#Tp 1'b0;
  else
  if(RxStateIdle)
    RxColWindow <=#Tp 1'b1;
end


// ShortFrame
reg ShortFrame;
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    ShortFrame <=#Tp 1'b0;
  else
  if(LoadRxStatus)
    ShortFrame <=#Tp 1'b0;
  else
  if(TakeSample)
    ShortFrame <=#Tp RxByteCnt[15:0] < r_MinFL[15:0];
end


// DribbleNibble
reg DribbleNibble;
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    DribbleNibble <=#Tp 1'b0;
  else
  if(RxStateSFD)
    DribbleNibble <=#Tp 1'b0;
  else
  if(~MRxDV & RxStateData[1])
    DribbleNibble <=#Tp 1'b1;
end


reg ReceivedPacketTooBig;
always @ (posedge MRxClk or posedge Reset)
begin
  if(Reset)
    ReceivedPacketTooBig <=#Tp 1'b0;
  else
  if(LoadRxStatus)
    ReceivedPacketTooBig <=#Tp 1'b0;
  else
  if(TakeSample)
    ReceivedPacketTooBig <=#Tp ~r_HugEn & RxByteCnt[15:0] > r_MaxFL[15:0];
end



// Latched Retry counter for tx status
always @ (posedge MTxClk or posedge Reset)
begin
  if(Reset)
    RetryCntLatched <=#Tp 4'h0;
  else
  if(StartTxDone | StartTxAbort)
    RetryCntLatched <=#Tp RetryCnt;
end


// Latched Retransmission limit
always @ (posedge MTxClk or posedge Reset)
begin
  if(Reset)
    RetryLimit <=#Tp 1'h0;
  else
  if(StartTxDone | StartTxAbort)
    RetryLimit <=#Tp MaxCollisionOccured;
end


// Latched Late Collision
always @ (posedge MTxClk or posedge Reset)
begin
  if(Reset)
    LateCollLatched <=#Tp 1'b0;
  else
  if(StartTxDone | StartTxAbort)
    LateCollLatched <=#Tp LateCollision;
end



// Latched Defer state
always @ (posedge MTxClk or posedge Reset)
begin
  if(Reset)
    DeferLatched <=#Tp 1'b0;
  else
  if(DeferIndication)
    DeferLatched <=#Tp 1'b1;
  else
  if(RstDeferLatched)
    DeferLatched <=#Tp 1'b0;
end


// CarrierSenseLost
always @ (posedge MTxClk or posedge Reset)
begin
  if(Reset)
    CarrierSenseLost <=#Tp 1'b0;
  else
  if((StatePreamble | (|StateData)) & ~CarrierSense & ~Loopback & ~Collision & ~r_FullD)
    CarrierSenseLost <=#Tp 1'b1;
  else
  if(TxStartFrm)
    CarrierSenseLost <=#Tp 1'b0;
end


endmodule
