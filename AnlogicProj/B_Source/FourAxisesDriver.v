module FourAxisesDriver(
    //======Clks and Reset===============================
    input               clk,
    input               rstin,
    //======Access Interface=============================
    input       [3:0]   Master1Sel,
    input       [3:0]   Master2Sel,
    
    input               RXD,//Debug Module Interface
    output              TXD,   
    
    input               PHY_REFCLK,
    input               PHY_CRSDV,    
    input       [1:0]   PHY_RXD,
    output              PHY_TXEN,
    output      [1:0]   PHY_TXD,
    inout               PHY_MDIO,
    output              PHY_MDC,    
    
    input               PHY_REFCLK2,
    input               PHY_CRSDV2,    
    input       [1:0]   PHY_RXD2,
    output              PHY_TXEN2,
    output      [1:0]   PHY_TXD2,
    inout               PHY_MDIO2,
    output              PHY_MDC2,    

    input               SPI_SEL,
    input               SPI_CLK,
    input               SPI_MOSI,
    output              SPI_MISO,
    
    input       [15:0]  AsyncADDRBus,//Async Renesas
    input       [15:0]  AsyncDATABus_in,
    output      [15:0]  AsyncDATABus_out,
    input               AsyncCS,
    input               AsyncWE0,
    input               AsyncRD,
    input               AsyncNADV,
    
    output              INTOut,
    //======Current Sample===============================
    output              A_MCLKU,
    input               A_MDATU,
    output              A_MCLKV,
    input               A_MDATV,
    
    output              B_MCLKU,
    input               B_MDATU,
    output              B_MCLKV,
    input               B_MDATV,
    
    output              C_MCLKU,
    input               C_MDATU,
    output              C_MCLKV,
    input               C_MDATV,

    output              D_MCLKU,
    input               D_MDATU,
    output              D_MCLKV,
    input               D_MDATV,    
    //======Position Sample==============================
    input               A_PluseA,
    input               A_PluseB,
    input               A_PluseZ,    
    input               A_SD,//485_RX
    output              A_RQ,//485_TX
    output              A_DRCNT,//485_EN
    output              A_BISSCCLK,      
    input               B_SD,//485_RX
    output              B_RQ,//485_TX
    output              B_DRCNT,//485_EN
    output              B_BISSCCLK,     
    input               C_SD,//485_RX
    output              C_RQ,//485_TX
    output              C_DRCNT,//485_EN  
    output              C_BISSCCLK,     
    input               D_SD,//485_RX
    output              D_RQ,//485_TX
    output              D_DRCNT,//485_EN
    output              D_BISSCCLK,     
    //======PWM Drivers==================================
    output              STOout,
    
    output              A_PWMEN,
    output              A_PU,
    output              A_NU,
    output              A_PV,
    output              A_NV,
    output              A_PW,
    output              A_NW,
    input               A_IPMFo,
    
    output              B_PWMEN,
    output              B_PU,
    output              B_NU,
    output              B_PV,
    output              B_NV,
    output              B_PW,
    output              B_NW,   
    input               B_IPMFo,    

    output              C_PWMEN,
    output              C_PU,
    output              C_NU,
    output              C_PV,
    output              C_NV,
    output              C_PW,
    output              C_NW,  
    input               C_IPMFo,

    output              D_PWMEN,
    output              D_PU,
    output              D_NU,
    output              D_PV,
    output              D_NV,
    output              D_PW,
    output              D_NW,
    input               D_IPMFo,
    
    //======UnrelatedSigs==================================
    output              CLK_BUS,
    input               DAT_BUS,
    input       [15:0]  DigitalInputs,
    output      [15:0]  DigitalOutputs,
    
    input               ASide_SD,
    output              ASide_RQ,
    output              ASide_DRCNT,
    
    input               DSide_SD,
    output              DSide_RQ,
    output              DSide_DRCNT
    
    );
    wire        rst;//synthesis keep = 1;
    wire        clk100Mhz;//synthesis keep = 1;
    wire        clk50Mhz;//synthesis keep = 1;
    wire        clk20Mhz;//synthesis keep = 1;
    wire        SysResetSig;
SysPLL SysPLL_inst(
    .clk(clk), 
    .reset(rstin), 
    .reset_sync(rst),
    .Clk_50Mhz(clk50Mhz),
    .Clk_100Mhz(clk100Mhz),
    .Clk_20Mhz(clk20Mhz),
    .SysResetSig(SysResetSig)
    );    
    
    wire            EncoderTrig;//synthesis keep = 1;
    wire            ACRTrig;//synthesis keep = 1;
    wire            ZEROTrig;//synthesis keep = 1;
    wire            PeriodTrig;//synthesis keep = 1;
    
//================================================================================
    wire                RDLWRH;
    wire        [15:0]  ADDR;
    wire        [15:0]  WRDATA;
    wire                DebugReserve_CS;
    wire        [15:0]  DebugReserve_RDDATA;
    wire                CurrentSample_CS;
    wire        [15:0]  CurrentSample_RDDATA;
    wire                PositionSample_CS;
    wire        [15:0]  PositionSample_RDDATA;
    wire                AxisesCurrentCtrler_CS;
    wire        [15:0]  AxisesCurrentCtrler_RDDATA;
    wire                CarrierModuleCtrler_CS;
    wire        [15:0]  CarrierModuleCtrler_RDDATA;  
    wire                IndirectRelevantSig_CS;
    wire        [15:0]  IndirectRelevantSig_RDDATA;   
    wire                SafetyMonitorModule_CS;
    wire        [15:0]  SafetyMonitorModule_RDDATA;  
    wire                OverAllControl_CS;
    wire        [15:0]  OverAllControl_RDDATA;  
BusInterconnecter BusInterconnecter(
    .clk(clk100Mhz),
    .clk50M(clk50Mhz),
    .rst(rst),
    .Master1Sel(Master1Sel),
    .Master2Sel(Master2Sel),
    //Master1===========================
    .AsyncADDRBus(AsyncADDRBus),//Async Renesas
    .AsyncDATABus_in(AsyncDATABus_in),
    .AsyncDATABus_out(AsyncDATABus_out),
    .AsyncCS(AsyncCS),
    .AsyncWE0(AsyncWE0),
    .AsyncRD(AsyncRD),
    .AsyncNADV(AsyncNADV),
    //Master1_backup====================
    .SPI_SEL(SPI_SEL),
    .SPI_CLK(SPI_CLK),
    .SPI_MOSI(SPI_MOSI),
    .SPI_MISO(SPI_MISO),
    //Master2===========================
    .RXD(RXD),//Debug Module Interface
    .TXD(TXD),   
    .DealBaseTrig(ZEROTrig||PeriodTrig),
    //Master2_backup
    .PHY_REFCLK(PHY_REFCLK),
    .PHY_CRSDV(PHY_CRSDV),    
    .PHY_RXD(PHY_RXD),
    .PHY_TXEN(PHY_TXEN),
    .PHY_TXD(PHY_TXD),
    .PHY_MDIO(PHY_MDIO),
    .PHY_MDC(PHY_MDC),  
    .PHY_REFCLK2(PHY_REFCLK2),
    .PHY_CRSDV2(PHY_CRSDV2),    
    .PHY_RXD2(PHY_RXD2),
    .PHY_TXEN2(PHY_TXEN2),
    .PHY_TXD2(PHY_TXD2),
    .PHY_MDIO2(PHY_MDIO2),
    .PHY_MDC2(PHY_MDC2),  
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

Reservespace Reservespace(
    .clk(clk100Mhz),
    .rst(rst),
    //data & addr bus
    .CS(DebugReserve_CS),
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .RDDATA(DebugReserve_RDDATA)
    );

    
    wire    [15:0]  CounterPeriod;
    wire    [15:0]  Axis1_DutyA;
    wire    [15:0]  Axis1_DutyB;
    wire    [15:0]  Axis1_DutyC;
    wire            Axis1_CalEN;
    wire    [15:0]  Axis2_DutyA;
    wire    [15:0]  Axis2_DutyB;
    wire    [15:0]  Axis2_DutyC;
    wire            Axis2_CalEN;
    wire    [15:0]  Axis3_DutyA;
    wire    [15:0]  Axis3_DutyB;
    wire    [15:0]  Axis3_DutyC;
    wire            Axis3_CalEN;    
    wire    [15:0]  Axis4_DutyA;
    wire    [15:0]  Axis4_DutyB;
    wire    [15:0]  Axis4_DutyC;
    wire            Axis4_CalEN;    
    
    wire            Axis1_PWMUNLOCK;
    wire            Axis2_PWMUNLOCK;
    wire            Axis3_PWMUNLOCK;
    wire            Axis4_PWMUNLOCK;    
CarrierModule CarrierModule_inst(
    .clk(clk100Mhz),
    .rst(rst),
    
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),    
    .CS(CarrierModuleCtrler_CS),
    .RDDATA(CarrierModuleCtrler_RDDATA),   
    
    .EncoderTrig(EncoderTrig),
    .ACRTrig(ACRTrig),
    .ZEROTrig(ZEROTrig),
    .PeriodTrig(PeriodTrig),
    .INTOut(INTOut),
    .CounterPeriod(CounterPeriod),
    
    //==========Axis1
    //ctrl input
    .Axis1_PWMUNLOCK(Axis1_PWMUNLOCK),
    .Axis1_DutyA(Axis1_DutyA),
    .Axis1_DutyB(Axis1_DutyB),
    .Axis1_DutyC(Axis1_DutyC), 
    .Axis1_CalEN(Axis1_CalEN),
    //output
    .Axis1_PWMUP(A_PU),
    .Axis1_PWMUN(A_NU),
    .Axis1_PWMVP(A_PV),
    .Axis1_PWMVN(A_NV),
    .Axis1_PWMWP(A_PW),
    .Axis1_PWMWN(A_NW),
    //==========Axis2
    //ctrl input
    .Axis2_PWMUNLOCK(Axis2_PWMUNLOCK),
    .Axis2_DutyA(Axis2_DutyA),
    .Axis2_DutyB(Axis2_DutyB),
    .Axis2_DutyC(Axis2_DutyC),
    .Axis2_CalEN(Axis2_CalEN),    
    //output
    .Axis2_PWMUP(B_PU),
    .Axis2_PWMUN(B_NU),
    .Axis2_PWMVP(B_PV),
    .Axis2_PWMVN(B_NV),
    .Axis2_PWMWP(B_PW),
    .Axis2_PWMWN(B_NW),
    //==========Axis3
    //ctrl input
    .Axis3_PWMUNLOCK(Axis3_PWMUNLOCK),
    .Axis3_DutyA(Axis3_DutyA),
    .Axis3_DutyB(Axis3_DutyB),
    .Axis3_DutyC(Axis3_DutyC),  
    .Axis3_CalEN(Axis3_CalEN),
    //output
    .Axis3_PWMUP(C_PU),
    .Axis3_PWMUN(C_NU),
    .Axis3_PWMVP(C_PV),
    .Axis3_PWMVN(C_NV),
    .Axis3_PWMWP(C_PW),
    .Axis3_PWMWN(C_NW),
    //==========Axis4
    //ctrl input
    .Axis4_PWMUNLOCK(Axis4_PWMUNLOCK),
    .Axis4_DutyA(Axis4_DutyA),
    .Axis4_DutyB(Axis4_DutyB),
    .Axis4_DutyC(Axis4_DutyC),
    .Axis4_CalEN(Axis4_CalEN),
    //output
    .Axis4_PWMUP(D_PU),
    .Axis4_PWMUN(D_NU),
    .Axis4_PWMVP(D_PV),
    .Axis4_PWMVN(D_NV),
    .Axis4_PWMWP(D_PW),
    .Axis4_PWMWN(D_NW)
	);

//==================================================================================
    wire    [15:0]  AXIS1_COSVal;
    wire    [15:0]  AXIS1_SINVal;   
    wire    [15:0]  AXIS1_InvCOSVal;
    wire    [15:0]  AXIS1_InvSINVal;    
    wire    [15:0]  AXIS2_COSVal;
    wire    [15:0]  AXIS2_SINVal;   
    wire    [15:0]  AXIS2_InvCOSVal;
    wire    [15:0]  AXIS2_InvSINVal; 
    wire    [15:0]  AXIS3_COSVal;
    wire    [15:0]  AXIS3_SINVal;   
    wire    [15:0]  AXIS3_InvCOSVal;
    wire    [15:0]  AXIS3_InvSINVal; 
    wire    [15:0]  AXIS4_COSVal;
    wire    [15:0]  AXIS4_SINVal;   
    wire    [15:0]  AXIS4_InvCOSVal;
    wire    [15:0]  AXIS4_InvSINVal;
PositionDetection PositionDetection_inst(
    .clk100Mhz(clk100Mhz),
    .clk20Mhz(clk20Mhz),
    .rst(rst),
    //hardware interface
    .AXIS1_PluseA(A_PluseA),
    .AXIS1_PluseB(A_PluseB),
    .AXIS1_PluseZ(A_PluseZ),  
    .AXIS1_SD(A_SD),
    .AXIS1_RQ(A_RQ),
    .AXIS1_DRCNT(A_DRCNT),
    .AXIS1_BISSCCLK(A_BISSCCLK),
    .AXIS2_SD(B_SD),
    .AXIS2_RQ(B_RQ),
    .AXIS2_DRCNT(B_DRCNT),  
    .AXIS2_BISSCCLK(B_BISSCCLK),
    .AXIS3_SD(C_SD),
    .AXIS3_RQ(C_RQ),
    .AXIS3_DRCNT(C_DRCNT),  
    .AXIS3_BISSCCLK(C_BISSCCLK),
    .AXIS4_SD(D_SD),
    .AXIS4_RQ(D_RQ),
    .AXIS4_DRCNT(D_DRCNT),    
    .AXIS4_BISSCCLK(D_BISSCCLK), 
    //data & addr bus
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),    
    .CS(PositionSample_CS),
    .RDDATA(PositionSample_RDDATA),   
    //internal sigs
    .RequestTrig(EncoderTrig),
    .TimeCriticalPluse(ACRTrig),
    .AXIS1_COSVal(AXIS1_COSVal),
    .AXIS1_SINVal(AXIS1_SINVal),   
    .AXIS1_InvCOSVal(AXIS1_InvCOSVal),
    .AXIS1_InvSINVal(AXIS1_InvSINVal),    
    .AXIS2_COSVal(AXIS2_COSVal),
    .AXIS2_SINVal(AXIS2_SINVal),   
    .AXIS2_InvCOSVal(AXIS2_InvCOSVal),
    .AXIS2_InvSINVal(AXIS2_InvSINVal), 
    .AXIS3_COSVal(AXIS3_COSVal),
    .AXIS3_SINVal(AXIS3_SINVal),   
    .AXIS3_InvCOSVal(AXIS3_InvCOSVal),
    .AXIS3_InvSINVal(AXIS3_InvSINVal), 
    .AXIS4_COSVal(AXIS4_COSVal),
    .AXIS4_SINVal(AXIS4_SINVal),   
    .AXIS4_InvCOSVal(AXIS4_InvCOSVal),
    .AXIS4_InvSINVal(AXIS4_InvSINVal)
    );
    

    wire            DSASCCLK;
    assign A_MCLKU = DSASCCLK;
    assign A_MCLKV = DSASCCLK;
    assign B_MCLKU = DSASCCLK;
    assign B_MCLKV = DSASCCLK;
    assign C_MCLKU = DSASCCLK;
    assign C_MCLKV = DSASCCLK;
    assign D_MCLKU = DSASCCLK;
    assign D_MCLKV = DSASCCLK;
    
    wire            Axis1_OC;
    wire            Axis2_OC;
    wire            Axis3_OC;
    wire            Axis4_OC;
    wire    [15:0]  Axis1_IU;
    wire    [15:0]  Axis1_IV;
    wire    [15:0]  Axis2_IU;
    wire    [15:0]  Axis2_IV;
    wire    [15:0]  Axis3_IU;
    wire    [15:0]  Axis3_IV;
    wire    [15:0]  Axis4_IU;
    wire    [15:0]  Axis4_IV;    
    wire            DataLockedPluse;
CurrentSample CurrentSample_inst(
    .clk100Mhz(clk100Mhz),
    .clk20Mhz(clk20Mhz),
    .rst(rst),
    //hardware interface
    .DSASCCLK(DSASCCLK),
    .Axis1_IUBitin(A_MDATU),
    .Axis1_IVBitin(A_MDATV),
    .Axis2_IUBitin(B_MDATU),
    .Axis2_IVBitin(B_MDATV),
    .Axis3_IUBitin(C_MDATU),
    .Axis3_IVBitin(C_MDATV),
    .Axis4_IUBitin(D_MDATU),
    .Axis4_IVBitin(D_MDATV),  
    //data & addr bus
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .CS(CurrentSample_CS),
    .RDDATA(CurrentSample_RDDATA),  
    //for safety module
    .Axis1_OC(Axis1_OC),
    .Axis2_OC(Axis2_OC),
    .Axis3_OC(Axis3_OC),
    .Axis4_OC(Axis4_OC),           
    //For ACR
    .ACRLockTrig(ACRTrig),
    .Axis1_IU_Locked(Axis1_IU),
    .Axis1_IV_Locked(Axis1_IV),
    .Axis2_IU_Locked(Axis2_IU),
    .Axis2_IV_Locked(Axis2_IV),
    .Axis3_IU_Locked(Axis3_IU),
    .Axis3_IV_Locked(Axis3_IV),
    .Axis4_IU_Locked(Axis4_IU),
    .Axis4_IV_Locked(Axis4_IV),
    .DataLockedPluse(DataLockedPluse)
    );    
    

AxisesCurrentCtrler AxisesCurrentCtrler_inst(
    .clk(clk100Mhz),
    .rst(rst),
    .trig(DataLockedPluse),
    .finish(),
    //data & addr bus
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .CS(AxisesCurrentCtrler_CS),
    .RDDATA(AxisesCurrentCtrler_RDDATA),   
    
    .Axises_CalEN({Axis4_CalEN,Axis3_CalEN,Axis2_CalEN,Axis1_CalEN}),
    
    .Axis1_IU(Axis1_IU),//16bit 
    .Axis1_IV(Axis1_IV),//16bit
    .Axis1_SINval(AXIS1_SINVal),
    .Axis1_COSval(AXIS1_COSVal),
    .Axis1_ISINval(AXIS1_InvSINVal),
    .Axis1_ICOSval(AXIS1_InvCOSVal),
    .Axis2_IU(Axis2_IU),//16bit 
    .Axis2_IV(Axis2_IV),//16bit
    .Axis2_SINval(AXIS2_SINVal),
    .Axis2_COSval(AXIS2_COSVal),
    .Axis2_ISINval(AXIS2_InvSINVal),
    .Axis2_ICOSval(AXIS2_InvCOSVal),
    .Axis3_IU(Axis3_IU),//16bit 
    .Axis3_IV(Axis3_IV),//16bit
    .Axis3_SINval(AXIS3_SINVal),
    .Axis3_COSval(AXIS3_COSVal),
    .Axis3_ISINval(AXIS3_InvSINVal),
    .Axis3_ICOSval(AXIS3_InvCOSVal),
    .Axis4_IU(Axis4_IU),//16bit 
    .Axis4_IV(Axis4_IV),//16bit
    .Axis4_SINval(AXIS4_SINVal),
    .Axis4_COSval(AXIS4_COSVal),
    .Axis4_ISINval(AXIS4_InvSINVal),
    .Axis4_ICOSval(AXIS4_InvCOSVal),//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    .PreiodCNT(CounterPeriod),
    .Axis1_DutyA(Axis1_DutyA),//=PhaseA Duty cycle*PreiodCNT
    .Axis1_DutyB(Axis1_DutyB),//=PhaseB Duty cycle*PreiodCNT
    .Axis1_DutyC(Axis1_DutyC),//=PhaseC Duty cycle*PreiodCNT
    .Axis2_DutyA(Axis2_DutyA),//=PhaseA Duty cycle*PreiodCNT
    .Axis2_DutyB(Axis2_DutyB),//=PhaseB Duty cycle*PreiodCNT
    .Axis2_DutyC(Axis2_DutyC),//=PhaseC Duty cycle*PreiodCNT
    .Axis3_DutyA(Axis3_DutyA),//=PhaseA Duty cycle*PreiodCNT
    .Axis3_DutyB(Axis3_DutyB),//=PhaseB Duty cycle*PreiodCNT
    .Axis3_DutyC(Axis3_DutyC),//=PhaseC Duty cycle*PreiodCNT
    .Axis4_DutyA(Axis4_DutyA),//=PhaseA Duty cycle*PreiodCNT
    .Axis4_DutyB(Axis4_DutyB),//=PhaseB Duty cycle*PreiodCNT
    .Axis4_DutyC(Axis4_DutyC)//=PhaseC Duty cycle*PreiodCNT    
    );

SafetyMonitor SafetyMonitor(
    .clk(clk100Mhz),
    .rst(rst),
    //hardware interface
    .Axis1_IPMFault(A_IPMFo),
    .Axis2_IPMFault(B_IPMFo),
    .Axis3_IPMFault(C_IPMFo),
    .Axis4_IPMFault(D_IPMFo),
    .Axis1_OC(Axis1_OC),
    .Axis2_OC(Axis2_OC),
    .Axis3_OC(Axis3_OC),
    .Axis4_OC(Axis4_OC),
    //Unlock carrier module
    .Axis1_PWMUNLOCK(Axis1_PWMUNLOCK),
    .Axis2_PWMUNLOCK(Axis2_PWMUNLOCK),
    .Axis3_PWMUNLOCK(Axis3_PWMUNLOCK),
    .Axis4_PWMUNLOCK(Axis4_PWMUNLOCK),
    //pwm output channel enbale
    .Axis1_PWMEN(A_PWMEN),
    .Axis2_PWMEN(B_PWMEN),
    .Axis3_PWMEN(C_PWMEN),
    .Axis4_PWMEN(D_PWMEN),  
    //sto
    .STOout(STOout),
    //SysResetSig
    .SysResetSig(SysResetSig),
    //data & addr bus
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),    
    .CS(SafetyMonitorModule_CS),
    .RDDATA(SafetyMonitorModule_RDDATA)   
    );



UnrelatedSigSample UnrelatedSigSample(
    .clk100Mhz(clk100Mhz),
    .clk20Mhz(clk20Mhz),
    .rst(rst),
    //hardware interface
    .VBUSClk(CLK_BUS),
    .VBUSDataIn(DAT_BUS),
    .DigitalInput(DigitalInputs),
    .DigitalOutput(DigitalOutputs),
    
    .ASide_SD(ASide_SD),
    .ASide_RQ(ASide_RQ),
    .ASide_DRCNT(ASide_DRCNT),
    
    .DSide_SD(DSide_SD),
    .DSide_RQ(DSide_RQ),
    .DSide_DRCNT(DSide_DRCNT),
    //data & addr bus
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),   
    .CS(IndirectRelevantSig_CS),
    .RDDATA(IndirectRelevantSig_RDDATA)   
    ); 
    

    

endmodule
