module BusInterconnecter(
    input                       clk,
    input                       clk50M,
    input                       rst,
    input               [3:0]   Master1Sel,
    input               [3:0]   Master2Sel,
    //Master1===========================
    input               [15:0]  AsyncADDRBus,//Async Renesas
    input               [15:0]  AsyncDATABus_in,
    output              [15:0]  AsyncDATABus_out,
    input                       AsyncCS,
    input                       AsyncWE0,
    input                       AsyncRD,
    input                       AsyncNADV,
    //Master1_backup====================
    input                       SPI_SEL,
    input                       SPI_CLK,
    input                       SPI_MOSI,
    output                      SPI_MISO,    
    //Master2===========================
    input                       DealBaseTrig,
    input                       RXD,//Debug Module Interface
    output                      TXD,   
    //Master2_backup
    input                       PHY_REFCLK,
    input                       PHY_CRSDV,    
    input               [1:0]   PHY_RXD,
    output                      PHY_TXEN,
    output              [1:0]   PHY_TXD,
    inout                       PHY_MDIO,
    output                      PHY_MDC,
    
    input                       PHY_REFCLK2,
    input                       PHY_CRSDV2,    
    input               [1:0]   PHY_RXD2,
    output                      PHY_TXEN2,
    output              [1:0]   PHY_TXD2,
    inout                       PHY_MDIO2,
    output                      PHY_MDC2,
    
    //Slave=============================inner regs space interface
    //public channel
    output                      RDLWRH,
    output              [15:0]  ADDR,
    output              [15:0]  WRDATA,
    output                      DebugReserve_CS,//Debug Reserve Space
    input               [15:0]  DebugReserve_RDDATA,
    output                      CurrentSample_CS,//CurrentSample channel 
    input               [15:0]  CurrentSample_RDDATA,
    output                      PositionSample_CS,//PositioonSample channel 
    input               [15:0]  PositionSample_RDDATA,
    output                      AxisesCurrentCtrler_CS,//AxisesCurrentCtrler channel 
    input               [15:0]  AxisesCurrentCtrler_RDDATA,
    output                      CarrierModuleCtrler_CS,//CarrierModuleCtrler channel 
    input               [15:0]  CarrierModuleCtrler_RDDATA,
    output                      IndirectRelevantSig_CS,//IndirectRelevantSig channel 
    input               [15:0]  IndirectRelevantSig_RDDATA,
    output                      SafetyMonitorModule_CS,//SafetyMonitorModule channel 
    input               [15:0]  SafetyMonitorModule_RDDATA,
    output                      OverAllControl_CS,//OverAllControl channel 
    input               [15:0]  OverAllControl_RDDATA 
    );
    
    reg                 FPGA_RE;
    reg                 FPGA_WE;
    reg         [15:0]  FPGA_XA;
    reg         [15:0]  FPGA_XDout;
    wire                FPGA_XDinValid;
    wire        [15:0]  FPGA_XDin;
    
    wire                FPGA_RE1;
    wire                FPGA_WE1;
    wire        [15:0]  FPGA_XA1;
    wire        [15:0]  FPGA_XDout1;
    wire                FPGA_RE2;
    wire                FPGA_WE2;
    wire        [15:0]  FPGA_XA2;
    wire        [15:0]  FPGA_XDout2;
    wire                FPGA_RE3;
    wire                FPGA_WE3;
    wire        [15:0]  FPGA_XA3;
    wire        [15:0]  FPGA_XDout3;

    
    always @ (*)begin
        case(Master1Sel)
        4'd0:begin//disable
            FPGA_RE=1'b0;
            FPGA_WE=1'b0;
            FPGA_XA=16'd0;
            FPGA_XDout=16'd0;
        end
        4'd1:begin//Async Renesas
            FPGA_RE=FPGA_RE1;
            FPGA_WE=FPGA_WE1;
            FPGA_XA=FPGA_XA1;
            FPGA_XDout=FPGA_XDout1;
        end
        4'd2:begin//Async STM32 GD32, data addr Mux
            FPGA_RE=FPGA_RE2;
            FPGA_WE=FPGA_WE2;
            FPGA_XA=FPGA_XA2;
            FPGA_XDout=FPGA_XDout2;
        end
        4'd3:begin//SPI
            FPGA_RE=FPGA_RE3;
            FPGA_WE=FPGA_WE3;
            FPGA_XA=FPGA_XA3;
            FPGA_XDout=FPGA_XDout3;
        end
        default:begin
            FPGA_RE=1'b0;
            FPGA_WE=1'b0;
            FPGA_XA=16'd0;
            FPGA_XDout=16'd0;
        end
        endcase
    end
    
    wire    [15:0]  AsyncDATABus_out1;
    wire    [15:0]  AsyncDATABus_out2;
    assign AsyncDATABus_out = (Master1Sel==4'd1)?AsyncDATABus_out1:((Master1Sel==4'd2)?AsyncDATABus_out2:16'd0);
    
AsyncBusInterface_Renesas AsyncBusInterface_Renesas(
    .clk(clk),
    .rst(rst && (Master1Sel==4'd1)),
    
    .XCS(AsyncCS),
    .XRD(AsyncRD),
    .XWE(AsyncWE0),
    .XDin(AsyncDATABus_in),
    .XDout(AsyncDATABus_out1),
    .XA(AsyncADDRBus),

    .FPGA_RE(FPGA_RE1),
    .FPGA_WE(FPGA_WE1),
    .FPGA_XA(FPGA_XA1),
    .FPGA_XDout(FPGA_XDout1),
    .FPGA_XDinValid(FPGA_XDinValid),
    .FPGA_XDin(FPGA_XDin) 
    );
    
BusTimingConv_DataAddrMultiplex_Async AsyncBusInterface_STM32(
    .clk(clk),
    .rst(rst && (Master1Sel==4'd2)),
    
    .XCS(AsyncCS),
    .XRD(AsyncRD),
    .XWE(AsyncWE0),
    .XDin(AsyncDATABus_in),
    .XDout(AsyncDATABus_out2),
    .Nadv(AsyncNADV),

    .FPGA_RE(FPGA_RE2),
    .FPGA_WE(FPGA_WE2),
    .FPGA_XA(FPGA_XA2),
    .FPGA_XDout(FPGA_XDout2),
    .FPGA_XDinValid(FPGA_XDinValid),
    .FPGA_XDin(FPGA_XDin) 
    );
    
SlaveSPICtrl SlaveSPICtrl(    
    .SPI_SEL(SPI_SEL),
    .SPI_CLK(SPI_CLK),
    .SPI_MOSI(SPI_MOSI),
    .SPI_MISO(SPI_MISO),
    
    .clk(clk),
    .rst(rst && (Master1Sel==4'd3)),
    .WR(FPGA_WE3),
    .RD(FPGA_RE3),
    .ADDR(FPGA_XA3),
    .WRDATA(FPGA_XDout3),
    .RDDATA(FPGA_XDin),
    .RDDATAValid(FPGA_XDinValid)
    );
    
    
    
    reg                 UserSpace_RD;
    reg                 UserSpace_WR;
    reg     [15:0]      UserSpace_ADDR;
    reg     [15:0]      UserSpace_WRDATA;
    wire    [15:0]      UserSpace_RDDATA;
    wire                UserSpace_RDDATAVALID;
    wire                UserSpace_WRACK;
    
    wire                UserSpace_RD1;
    wire                UserSpace_WR1;
    wire    [15:0]      UserSpace_ADDR1;
    wire    [15:0]      UserSpace_WRDATA1;
    
    wire                UserSpace_RD2;
    wire                UserSpace_WR2;
    wire    [15:0]      UserSpace_ADDR2;
    wire    [15:0]      UserSpace_WRDATA2;
    
    wire                UserSpace_RD3;
    wire                UserSpace_WR3;
    wire    [15:0]      UserSpace_ADDR3;
    wire    [15:0]      UserSpace_WRDATA3;
    
    always @ (*)begin
        case(Master2Sel)
        4'd0:begin//disable
            UserSpace_RD=1'b0;
            UserSpace_WR=1'b0;
            UserSpace_ADDR=16'd0;
            UserSpace_WRDATA=16'd0;
        end
        4'd1:begin//UART
            UserSpace_RD=UserSpace_RD1;
            UserSpace_WR=UserSpace_WR1;
            UserSpace_ADDR=UserSpace_ADDR1;
            UserSpace_WRDATA=UserSpace_WRDATA1;
        end
        4'd2:begin//UDP
            UserSpace_RD=UserSpace_RD2;
            UserSpace_WR=UserSpace_WR2;
            UserSpace_ADDR=UserSpace_ADDR2;
            UserSpace_WRDATA=UserSpace_WRDATA2;
        end
        4'd3:begin//ZlinkSlaveStation
            UserSpace_RD=UserSpace_RD3;
            UserSpace_WR=UserSpace_WR3;
            UserSpace_ADDR=UserSpace_ADDR3;
            UserSpace_WRDATA=UserSpace_WRDATA3;
        end
        default:begin
            UserSpace_RD=1'b0;
            UserSpace_WR=1'b0;
            UserSpace_ADDR=16'd0;
            UserSpace_WRDATA=16'd0;
        end
        endcase
    end
 StandardDebugModule StandardDebugModule_inst(
    .clk(clk),
    .rst(rst && (Master2Sel==4'd1)),
    .FrameDealTrigSource(DealBaseTrig),//8khz,125us
    .FrameTXTrigActiveCNTSet(16'd7),//125us * 8 = 1000us TX once//16'd7
    
    //User Regs&RAM Space Access
    .UserSpace_RD(UserSpace_RD1),//next Access wait 'UserSpace_RDDATAVALID' ack
    .UserSpace_WR(UserSpace_WR1),//next Access wait 'UserSpace_WRACK' ack    
    .UserSpace_ADDR(UserSpace_ADDR1),
    .UserSpace_WRDATA(UserSpace_WRDATA1),    
    .UserSpace_RDDATA(UserSpace_RDDATA),
    .UserSpace_RDDATAVALID(UserSpace_RDDATAVALID),//at least delay 'UserSpace_RD' 1 clk
    .UserSpace_WRACK(UserSpace_WRACK),//at least delay 'UserSpace_WR' 1 clk
    //Hardware Interface
    .TXD(TXD),
    .RXD(RXD)
    );
UdpInteraction UdpInteraction(
    .clk100Mhz(clk),
    .clk50Mhz(clk50M),
    .rst(rst && (Master2Sel==4'd2)),
    
    .REFCLK(PHY_REFCLK),
    .CRSDV(PHY_CRSDV),    
    .RXD(PHY_RXD),
    .TXEN(PHY_TXEN),
    .TXD(PHY_TXD),
    .MDIO(PHY_MDIO),
    .MDC(PHY_MDC),
    
    .TXTrigBasePluse(DealBaseTrig),
    .UserSpace_RD(UserSpace_RD2),
    .UserSpace_WR(UserSpace_WR2),
    .UserSpace_ADDR(UserSpace_ADDR2),
    .UserSpace_WRDATA(UserSpace_WRDATA2),
    .UserSpace_RDDATA(UserSpace_RDDATA),
    .UserSpace_RDDATAVALID(UserSpace_RDDATAVALID)
    );   

ZlinkslavestationShell Zlinkslavestation(
    .clk(clk),
    .rst(rst && (Master2Sel==4'd3)),
    //Port0
/*     .PHY_REFCLK0(PHY_REFCLK),
    .PHY_CRSDV0(PHY_CRSDV),    
    .PHY_RXD0(PHY_RXD),
    .PHY_TXEN0(PHY_TXEN),
    .PHY_TXD0(PHY_TXD),
    .PHY_MDIO0(PHY_MDIO),
    .PHY_MDC0(PHY_MDC), */
    //Port1
    .PHY_REFCLK1(PHY_REFCLK2),
    .PHY_CRSDV1(PHY_CRSDV2),    
    .PHY_RXD1(PHY_RXD2),
    .PHY_TXEN1(PHY_TXEN2),
    .PHY_TXD1(PHY_TXD2),
    .PHY_MDIO1(PHY_MDIO2),
    .PHY_MDC1(PHY_MDC2),
    //==
    .UserSpace_RD(UserSpace_RD3),
    .UserSpace_WR(UserSpace_WR3),
    .UserSpace_ADDR(UserSpace_ADDR3),
    .UserSpace_WRDATA(UserSpace_WRDATA3),
    .UserSpace_RDDATA(UserSpace_RDDATA),
    .UserSpace_RDDATAVALID(UserSpace_RDDATAVALID)
);    
    
    
BusInterconnecterX BusInterconnecterX(
    .clk(clk),
    .rst(rst),
    //Master1===========================Async Bus
    .FPGA_RE(FPGA_RE),
    .FPGA_WE(FPGA_WE),
    .FPGA_XA(FPGA_XA),
    .FPGA_XDout(FPGA_XDout),
    .FPGA_XDinValid(FPGA_XDinValid),
    .FPGA_XDin(FPGA_XDin),
    //Master2===========================StandardDebugModule Interface
    .UserSpace_RD(UserSpace_RD),//next Access wait 'UserSpace_RDDATAVALID' ack
    .UserSpace_WR(UserSpace_WR),//next Access wait 'UserSpace_WRACK' ack
    .UserSpace_ADDR(UserSpace_ADDR),
    .UserSpace_WRDATA(UserSpace_WRDATA),
    .UserSpace_RDDATA(UserSpace_RDDATA),
    .UserSpace_RDDATAVALID(UserSpace_RDDATAVALID),//at least delay 'UserSpace_RD' 1 clk
    .UserSpace_WRACK(UserSpace_WRACK),//at least delay 'UserSpace_WR' 1 clk
    //Slave=============================inner regs space interface
    //public channel
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .DebugReserve_CS(DebugReserve_CS),//Debug Reserve Space
    .DebugReserve_RDDATA(DebugReserve_RDDATA),
    .CurrentSample_CS(CurrentSample_CS),//CurrentSample channel 
    .CurrentSample_RDDATA(CurrentSample_RDDATA),
    .PositionSample_CS(PositionSample_CS),//PositioonSample channel 
    .PositionSample_RDDATA(PositionSample_RDDATA),
    .AxisesCurrentCtrler_CS(AxisesCurrentCtrler_CS),//AxisesCurrentCtrler channel 
    .AxisesCurrentCtrler_RDDATA(AxisesCurrentCtrler_RDDATA),
    .CarrierModuleCtrler_CS(CarrierModuleCtrler_CS),//CarrierModuleCtrler channel 
    .CarrierModuleCtrler_RDDATA(CarrierModuleCtrler_RDDATA),
    .IndirectRelevantSig_CS(IndirectRelevantSig_CS),//IndirectRelevantSig channel 
    .IndirectRelevantSig_RDDATA(IndirectRelevantSig_RDDATA),
    .SafetyMonitorModule_CS(SafetyMonitorModule_CS),//SafetyMonitorModule channel 
    .SafetyMonitorModule_RDDATA(SafetyMonitorModule_RDDATA),
    .OverAllControl_CS(OverAllControl_CS),//OverAllControl channel 
    .OverAllControl_RDDATA(OverAllControl_RDDATA)   
    );

endmodule
