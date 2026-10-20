module BusInterconnecterX(
    input                       clk,
    input                       rst,
    //Master1===========================Async Bus
    input                       FPGA_RE,
    input                       FPGA_WE,
    input               [15:0]  FPGA_XA,
    input               [15:0]  FPGA_XDout,
    output                      FPGA_XDinValid,
    output              [15:0]  FPGA_XDin,
    //Master2===========================StandardDebugModule Interface
    input                       UserSpace_RD,//next Access wait 'UserSpace_RDDATAVALID' ack
    input                       UserSpace_WR,//next Access wait 'UserSpace_WRACK' ack
    input               [15:0]  UserSpace_ADDR,
    input               [15:0]  UserSpace_WRDATA,
    output              [15:0]  UserSpace_RDDATA,
    output                      UserSpace_RDDATAVALID,//at least delay 'UserSpace_RD' 1 clk
    output                      UserSpace_WRACK,//at least delay 'UserSpace_WR' 1 clk
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
    
    
    wire                        D_AccessSource;
    wire                        D_CS;
    wire                        D_RDLWRH;
    wire                [15:0]  D_ADDR;
    wire                [15:0]  D_WRDATA;
    wire                [15:0]  D_RDDATA;
    wire                        D_FPGA_XDinValid;
    wire                        D_UserSpace_RDDATAVALID;
    wire                        D_UserSpace_WRACK;
MultiAccessPreDeal MultiAccessPreDeal(
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
    
    //Active port
    .D_AccessSource(D_AccessSource),
    .D_CS(D_CS),
    .D_RDLWRH(D_RDLWRH),
    .D_ADDR(D_ADDR),
    .D_WRDATA(D_WRDATA),
    .D_RDDATA(D_RDDATA),
    .D_FPGA_XDinValid(D_FPGA_XDinValid),
    .D_UserSpace_RDDATAVALID(D_UserSpace_RDDATAVALID),
    .D_UserSpace_WRACK(D_UserSpace_WRACK)
    );
    

AccessLocalspcae AccessLocalspcae(
    .clk(clk),
    .rst(rst),
    
    .D_AccessSource(D_AccessSource),
    .D_CS(D_CS),
    .D_RDLWRH(D_RDLWRH),
    .D_ADDR(D_ADDR),
    .D_WRDATA(D_WRDATA),
    
    .D_RDDATA(D_RDDATA),
    .D_FPGA_XDinValid(D_FPGA_XDinValid),
    .D_UserSpace_RDDATAVALID(D_UserSpace_RDDATAVALID),
    .D_UserSpace_WRACK(D_UserSpace_WRACK),
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
