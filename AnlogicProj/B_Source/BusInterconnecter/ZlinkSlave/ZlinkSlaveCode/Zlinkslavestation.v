module Zlinkslavestation(
    input                   clk,
    input                   rst,
    //Port0
    input                   RXDV0,
    input                   RXD0,
    output                  TXEN0,
    output                  TXD0,
    input                   Linkstate0,
    //Port1
    input                   RXDV1,
    input                   RXD1,
    output                  TXEN1,
    output                  TXD1,
    input                   Linkstate1,
    //Local Space Access Interface
    output                  ZlinkS_RE,
    output                  ZlinkS_WE,
    output          [15:0]  ZlinkS_XA,
    output          [15:0]  ZlinkS_XDout,
    input                   ZlinkS_XDinValid,
    input           [15:0]  ZlinkS_XDin 
);


    wire         RXDV;
    wire         RXD;
    wire [7:0]   TAG_ByteStream;
    wire         TAG_ByteActive; 
    wire [3:0]   TAG_FrameState;
    wire [15:0]  TAG_DataPartByteCNT;
    wire [47:0]  MSG_TargetAddress;
    wire [47:0]  MSG_SourceAddress;
    wire [15:0]  MSG_EthernetType;
    wire         CK_FrameOK;
    wire         CK_CRC_Valid;
    wire         CK_CheckResult;
Slave100MHz_FrameAnalysis FrameAnalysis(
    .clk(clk),
    .rst(rst),
    .RXDV_org(RXDV0),
    .RXD_org(RXD0),
    //=============
    .RXDV(RXDV),
    .RXD(RXD), 
    //===sync to RXD ... frame tags relate
    .TAG_ByteStream(TAG_ByteStream), 
    .TAG_ByteActive(TAG_ByteActive), 
    .TAG_FrameState(TAG_FrameState),
    .TAG_DataPartByteCNT(TAG_DataPartByteCNT),
    //===delay RXD by 1 clk ... frame message capture 
    .MSG_TargetAddress(MSG_TargetAddress),
    .MSG_SourceAddress(MSG_SourceAddress),
    .MSG_EthernetType(MSG_EthernetType),
    //===delay RXD by 2 clk ... frame crc check
    .CK_FrameOK(CK_FrameOK),
    .CK_CRC_Valid(CK_CRC_Valid),
    .CK_CheckResult(CK_CheckResult)
    );
    
    
    wire        TopPackReplaceFlag;
    wire        TopPackTXD;
    wire [15:0] Datalength;
    wire [7:0]  SlaveDetect;
Slave100MHz_TopUnPack TopUnPack(
    .clk(clk),
    .rst(rst),

    .RXDV(RXDV),
    .RXD(RXD), 
    .TAG_ByteStream(TAG_ByteStream), 
    .TAG_ByteActive(TAG_ByteActive), 
    .TAG_FrameState(TAG_FrameState),
    .TAG_DataPartByteCNT(TAG_DataPartByteCNT),
    .MSG_EthernetType(MSG_EthernetType),
    
    //==Msg Out
    .SysRefClk(),
    .OperationMode(),
    .SlaveDetect(SlaveDetect),
    .FrameIndex(),
    .Datalength(Datalength),
    
    //==sync RXDV
    .ReplaceFlag(TopPackReplaceFlag),
    .TXD(TopPackTXD)
    );
    
    wire                SubDatagramIndicate;
    wire    [15:0]      SubDatagramCNT;
    wire    [15:0]      SubDatagramByteCNT;
    wire    [7:0]       SubDatagram_CMD;
    wire    [7:0]       SubDatagram_SlaveAddr;
    wire    [15:0]      SubDatagram_LocalAddr;
    wire    [15:0]      SubDatagram_Datalength;
    wire                SubDatagram_NextFlag;
    wire                SubDatagram_CMDValid;
Slave100MHz_SubDatagramdeal SubDatagramdeal(
    .clk(clk),
    .rst(rst),
    //==Msg from FrameAnalysis
    .RXDV(RXDV),
    .RXD(RXD), 
    .TAG_ByteStream(TAG_ByteStream), 
    .TAG_ByteActive(TAG_ByteActive), 
    .TAG_FrameState(TAG_FrameState),
    .TAG_DataPartByteCNT(TAG_DataPartByteCNT),
    .MSG_EthernetType(MSG_EthernetType),
    
    //==Msg from TopUnPack
    .Datalength(Datalength),
    
    //==output SubDatagramdeal Msg
    .SubDatagramIndicate(SubDatagramIndicate),
    .SubDatagramCNT(SubDatagramCNT),
    .SubDatagramByteCNT(SubDatagramByteCNT),
    .SubDatagram_CMD(SubDatagram_CMD),
    .SubDatagram_SlaveAddr(SubDatagram_SlaveAddr),
    .SubDatagram_LocalAddr(SubDatagram_LocalAddr),
    .SubDatagram_Datalength(SubDatagram_Datalength),
    .SubDatagram_NextFlag(SubDatagram_NextFlag),
    .SubDatagram_CMDValid(SubDatagram_CMDValid)
    );
    
    wire [15:0] ZlinkS_XA_WR;
Slave100MHz_IndependentWrite IndependentWrite(//包含了广播写、独立寻址写的处理
    .clk(clk),
    .rst(rst),
    
    .TAG_ByteStream(TAG_ByteStream), 
    .TAG_ByteActive(TAG_ByteActive), 
    
    .SubDatagramIndicate(SubDatagramIndicate),
    .SubDatagramCNT(SubDatagramCNT),
    .SubDatagramByteCNT(SubDatagramByteCNT),
    .SubDatagram_CMD(SubDatagram_CMD),
    .SubDatagram_SlaveAddr(SubDatagram_SlaveAddr),
    .SubDatagram_LocalAddr(SubDatagram_LocalAddr),
    .SubDatagram_Datalength(SubDatagram_Datalength),
    .SubDatagram_NextFlag(SubDatagram_NextFlag),
    .SubDatagram_CMDValid(SubDatagram_CMDValid),
    
    .SetSlaveAddr(SlaveDetect),//(8'd0),
    
    .WRPluse(ZlinkS_WE),
    .WRADDR(ZlinkS_XA_WR),
    .WRDATA(ZlinkS_XDout)
    );
    
    wire RDPluse;
    reg RDVirtualValid;
    wire [15:0] RDADDR;
    reg [15:0]  RDDATAVirtual;
    wire IndependentReadReplaceFlag;
    wire IndependentReadTXD;
    wire [15:0] ZlinkS_XA_RD;
Slave100MHz_IndependentRead IndependentRead(//包含了独立寻址读的处理
    .clk(clk),
    .rst(rst),
    
    .RXDV(RXDV),
    .RXD(RXD), 
    .TAG_ByteStream(TAG_ByteStream), 
    .TAG_ByteActive(TAG_ByteActive), 
    
    .SubDatagramIndicate(SubDatagramIndicate),
    .SubDatagramCNT(SubDatagramCNT),
    .SubDatagramByteCNT(SubDatagramByteCNT),
    .SubDatagram_CMD(SubDatagram_CMD),
    .SubDatagram_SlaveAddr(SubDatagram_SlaveAddr),
    .SubDatagram_LocalAddr(SubDatagram_LocalAddr),
    .SubDatagram_Datalength(SubDatagram_Datalength),
    .SubDatagram_NextFlag(SubDatagram_NextFlag),
    .SubDatagram_CMDValid(SubDatagram_CMDValid),
    
    .SetSlaveAddr(SlaveDetect),//(8'd0),
    
    .RDPluse(ZlinkS_RE),
    .RDADDR(ZlinkS_XA_RD),
    .RDDATA(ZlinkS_XDin),
    .RDValid(ZlinkS_XDinValid),
    
    .ReplaceFlag(IndependentReadReplaceFlag),
    .TXD(IndependentReadTXD)
    );
    
    assign ZlinkS_XA = ZlinkS_RE?ZlinkS_XA_RD:ZlinkS_XA_WR;
    
    
    wire TXEN;
    wire TXD;
Slave100MHz_FrameTramsmit FrameTramsmit(
    .clk(clk),
    .rst(rst),

    .RXDV(RXDV),
    .RXD(RXD), 
    .TAG_ByteStream(TAG_ByteStream), 
    .TAG_ByteActive(TAG_ByteActive), 
    .TAG_FrameState(TAG_FrameState),
    .TAG_DataPartByteCNT(TAG_DataPartByteCNT),
    .MSG_EthernetType(MSG_EthernetType),

    .Datalength(Datalength),
    .TopPackReplaceFlag(TopPackReplaceFlag),
    .TopPackTXD(TopPackTXD),
    .IndependentReadReplaceFlag(IndependentReadReplaceFlag),
    .IndependentReadTXD(IndependentReadTXD),
    
    .TXEN(TXEN),
    .TXD(TXD)
    );
    
    //TopologyManage========================
Slave100MHz_TopologyManage TopologyManage(
    .clk(clk),
    .rst(rst),
    //processed sigs
    .TXEN(TXEN),
    .TXD(TXD),
    //Port0
    .RXDV0(RXDV0),
    .RXD0(RXD0),
    .TXEN0(TXEN0),
    .TXD0(TXD0),
    .Linkstate0(Linkstate0),
    //Port1
    .RXDV1(RXDV1),
    .RXD1(RXD1),
    .TXEN1(TXEN1),
    .TXD1(TXD1),
    .Linkstate1(Linkstate1)
    );

    
endmodule
