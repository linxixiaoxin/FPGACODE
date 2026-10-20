module PositionDetection(
    input                       clk20Mhz,//20Mhz
    input                       clk100Mhz,//20Mhz
    input                       rst,
    //hardware interface
    input                       AXIS1_PluseA,
    input                       AXIS1_PluseB,
    input                       AXIS1_PluseZ,  
    input                       AXIS1_SD,
    output                      AXIS1_RQ,
    output                      AXIS1_DRCNT,
    output                      AXIS1_BISSCCLK,    
    input                       AXIS2_SD,
    output                      AXIS2_RQ,
    output                      AXIS2_DRCNT, 
    output                      AXIS2_BISSCCLK,    
    input                       AXIS3_SD,
    output                      AXIS3_RQ,
    output                      AXIS3_DRCNT, 
    output                      AXIS3_BISSCCLK,
    input                       AXIS4_SD,
    output                      AXIS4_RQ,
    output                      AXIS4_DRCNT, 
    output                      AXIS4_BISSCCLK,    
    //data & addr bus
    input                       RDLWRH,
    input           [15:0]      ADDR,
    input           [15:0]      WRDATA,    
    input                       CS,
    output          [15:0]      RDDATA,   
    //internal sigs
    input                       RequestTrig,
    input                       TimeCriticalPluse,
    output      [15:0]          AXIS1_COSVal,
    output      [15:0]          AXIS1_SINVal,   
    output      [15:0]          AXIS1_InvCOSVal,
    output      [15:0]          AXIS1_InvSINVal,    
    output      [15:0]          AXIS2_COSVal,
    output      [15:0]          AXIS2_SINVal,   
    output      [15:0]          AXIS2_InvCOSVal,
    output      [15:0]          AXIS2_InvSINVal, 
    output      [15:0]          AXIS3_COSVal,
    output      [15:0]          AXIS3_SINVal,   
    output      [15:0]          AXIS3_InvCOSVal,
    output      [15:0]          AXIS3_InvSINVal, 
    output      [15:0]          AXIS4_COSVal,
    output      [15:0]          AXIS4_SINVal,   
    output      [15:0]          AXIS4_InvCOSVal,
    output      [15:0]          AXIS4_InvSINVal
    );
    
    
    wire    [3:0]   AXIS1_EthetaSourceSel;
    wire            AXIS1_CalibrationEN;
    wire    [3:0]   AXIS1_CalibrationState;
    wire            AXIS1_ENCNoResponsPluse;
    wire            AXIS1_ENCCRCERRPluse;
    wire    [15:0]  AXIS1_VirtualTheta;
    wire            AXIS1_VirtualTheta_UpdatePluse;  
    wire            AXIS1_VirtualThetaEnable;
    wire    [31:0]  AXIS1_MechanicalPosition;
    wire            AXIS1_DataValid;
    
    wire    [3:0]   AXIS2_EthetaSourceSel;
    wire            AXIS2_CalibrationEN;
    wire    [3:0]   AXIS2_CalibrationState;
    wire            AXIS2_ENCNoResponsPluse;
    wire            AXIS2_ENCCRCERRPluse;
    wire    [15:0]  AXIS2_VirtualTheta;    
    wire            AXIS2_VirtualTheta_UpdatePluse; 
    wire            AXIS2_VirtualThetaEnable;
    wire    [31:0]  AXIS2_MechanicalPosition;
    wire            AXIS2_DataValid;
    
    wire    [3:0]   AXIS3_EthetaSourceSel;
    wire            AXIS3_CalibrationEN;
    wire    [3:0]   AXIS3_CalibrationState;
    wire            AXIS3_ENCNoResponsPluse;
    wire            AXIS3_ENCCRCERRPluse;
    wire    [15:0]  AXIS3_VirtualTheta;
    wire            AXIS3_VirtualTheta_UpdatePluse; 
    wire            AXIS3_VirtualThetaEnable;    
    wire    [31:0]  AXIS3_MechanicalPosition;
    wire            AXIS3_DataValid;
    
    wire    [3:0]   AXIS4_EthetaSourceSel;
    wire            AXIS4_CalibrationEN;
    wire    [3:0]   AXIS4_CalibrationState;
    wire            AXIS4_ENCNoResponsPluse;
    wire            AXIS4_ENCCRCERRPluse;
    wire    [15:0]  AXIS4_VirtualTheta;
    wire            AXIS4_VirtualTheta_UpdatePluse; 
    wire            AXIS4_VirtualThetaEnable;
    wire    [31:0]  AXIS4_MechanicalPosition;
    wire            AXIS4_DataValid;    
    
    
    
    wire    [31:0]  AXIS1_TransCoeff;
    wire    [15:0]  AXIS1_ZeroSet;
    wire    [15:0]  AXIS1_InvTransAngleComp;
    wire            AXIS1_Polarity;
    wire    [15:0]  AXIS1_Etheta;
    wire            AXIS1_CALOvertime;    

    wire    [31:0]  AXIS2_TransCoeff;
    wire    [15:0]  AXIS2_ZeroSet;
    wire    [15:0]  AXIS2_InvTransAngleComp;
    wire            AXIS2_Polarity;      
    wire    [15:0]  AXIS2_Etheta;
    wire            AXIS2_CALOvertime;

    wire    [31:0]  AXIS3_TransCoeff;
    wire    [15:0]  AXIS3_ZeroSet;
    wire    [15:0]  AXIS3_InvTransAngleComp;
    wire            AXIS3_Polarity;    
    wire    [15:0]  AXIS3_Etheta;
    wire            AXIS3_CALOvertime;
    
    wire    [31:0]  AXIS4_TransCoeff;
    wire    [15:0]  AXIS4_ZeroSet;
    wire    [15:0]  AXIS4_InvTransAngleComp;
    wire            AXIS4_Polarity;    
    wire    [15:0]  AXIS4_Etheta;
    wire            AXIS4_CALOvertime;
    
RegSpcae_PositionDetection RegSpcae_PositionDetection(
    .clk(clk100Mhz),//20Mhz
    .rst(rst),
    //data & addr bus
    .CS(CS),
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .RDDATA(RDDATA),
    //inner reg interface
    .AXIS1_TransCoeff(AXIS1_TransCoeff),
    .AXIS1_ZeroSet(AXIS1_ZeroSet),
    .AXIS1_InvTransAngleComp(AXIS1_InvTransAngleComp),
    .AXIS1_Polarity(AXIS1_Polarity),
    .AXIS1_EthetaSourceSel(AXIS1_EthetaSourceSel),
    .AXIS1_CalibrationEN(AXIS1_CalibrationEN),
    .AXIS1_CalibrationState(AXIS1_CalibrationState),
    .AXIS1_ENCNoResponsPluse(AXIS1_ENCNoResponsPluse),
    .AXIS1_ENCCRCERRPluse(AXIS1_ENCCRCERRPluse),
    .AXIS1_VirtualTheta(AXIS1_VirtualTheta), 
    .AXIS1_VirtualTheta_UpdatePluse(AXIS1_VirtualTheta_UpdatePluse),
    .AXIS1_VirtualThetaEnable(AXIS1_VirtualThetaEnable),
    .AXIS1_MechanicalPosition(AXIS1_MechanicalPosition),
    .AXIS1_Etheta(AXIS1_Etheta),
    .AXIS1_CALOvertime(AXIS1_CALOvertime),      
    
    .AXIS2_TransCoeff(AXIS2_TransCoeff),
    .AXIS2_ZeroSet(AXIS2_ZeroSet),
    .AXIS2_InvTransAngleComp(AXIS2_InvTransAngleComp),
    .AXIS2_Polarity(AXIS2_Polarity),
    .AXIS2_EthetaSourceSel(AXIS2_EthetaSourceSel),
    .AXIS2_CalibrationEN(AXIS2_CalibrationEN),
    .AXIS2_CalibrationState(AXIS2_CalibrationState),
    .AXIS2_ENCNoResponsPluse(AXIS2_ENCNoResponsPluse),
    .AXIS2_ENCCRCERRPluse(AXIS2_ENCCRCERRPluse),
    .AXIS2_VirtualTheta(AXIS2_VirtualTheta),    
    .AXIS2_VirtualTheta_UpdatePluse(AXIS2_VirtualTheta_UpdatePluse),
    .AXIS2_VirtualThetaEnable(AXIS2_VirtualThetaEnable),
    .AXIS2_MechanicalPosition(AXIS2_MechanicalPosition),
    .AXIS2_Etheta(AXIS2_Etheta),
    .AXIS2_CALOvertime(AXIS2_CALOvertime), 

    .AXIS3_TransCoeff(AXIS3_TransCoeff),
    .AXIS3_ZeroSet(AXIS3_ZeroSet),
    .AXIS3_InvTransAngleComp(AXIS3_InvTransAngleComp),
    .AXIS3_Polarity(AXIS3_Polarity),
    .AXIS3_EthetaSourceSel(AXIS3_EthetaSourceSel),
    .AXIS3_CalibrationEN(AXIS3_CalibrationEN),
    .AXIS3_CalibrationState(AXIS3_CalibrationState),
    .AXIS3_ENCNoResponsPluse(AXIS3_ENCNoResponsPluse),
    .AXIS3_ENCCRCERRPluse(AXIS3_ENCCRCERRPluse),
    .AXIS3_VirtualTheta(AXIS3_VirtualTheta),
    .AXIS3_VirtualTheta_UpdatePluse(AXIS3_VirtualTheta_UpdatePluse),
    .AXIS3_VirtualThetaEnable(AXIS3_VirtualThetaEnable),    
    .AXIS3_MechanicalPosition(AXIS3_MechanicalPosition),
    .AXIS3_Etheta(AXIS3_Etheta),
    .AXIS3_CALOvertime(AXIS3_CALOvertime), 

    .AXIS4_TransCoeff(AXIS4_TransCoeff),
    .AXIS4_ZeroSet(AXIS4_ZeroSet),
    .AXIS4_InvTransAngleComp(AXIS4_InvTransAngleComp),
    .AXIS4_Polarity(AXIS4_Polarity),
    .AXIS4_EthetaSourceSel(AXIS4_EthetaSourceSel),
    .AXIS4_CalibrationEN(AXIS4_CalibrationEN),
    .AXIS4_CalibrationState(AXIS4_CalibrationState),
    .AXIS4_ENCNoResponsPluse(AXIS4_ENCNoResponsPluse),
    .AXIS4_ENCCRCERRPluse(AXIS4_ENCCRCERRPluse),
    .AXIS4_VirtualTheta(AXIS4_VirtualTheta),
    .AXIS4_VirtualTheta_UpdatePluse(AXIS4_VirtualTheta_UpdatePluse),  
    .AXIS4_VirtualThetaEnable(AXIS4_VirtualThetaEnable),    
    .AXIS4_MechanicalPosition(AXIS4_MechanicalPosition),
    .AXIS4_Etheta(AXIS4_Etheta),
    .AXIS4_CALOvertime(AXIS4_CALOvertime)
    );   
    
EncoderDrivers EncoderDrivers(
    .clk_20Mhz(clk20Mhz),//20Mhz
    .clk_100Mhz(clk100Mhz),//20Mhz
    .rst(rst),
    //hardware interface
    .AXIS1_AngleDriverSel(AXIS1_EthetaSourceSel),
    .AXIS1_CalibrationEN(AXIS1_CalibrationEN),
    .AXIS1_CalibrationState(AXIS1_CalibrationState),
    .AXIS1_ENCNoResponsPluse(AXIS1_ENCNoResponsPluse),
    .AXIS1_ENCCRCERRPluse(AXIS1_ENCCRCERRPluse), 
    .AXIS1_PluseA(AXIS1_PluseA),
    .AXIS1_PluseB(AXIS1_PluseB),
    .AXIS1_PluseZ(AXIS1_PluseZ),       
    .AXIS1_SD(AXIS1_SD),
    .AXIS1_RQ(AXIS1_RQ),
    .AXIS1_DRCNT(AXIS1_DRCNT),
    .AXIS1_BISSCCLK(AXIS1_BISSCCLK),
    .AXIS2_AngleDriverSel(AXIS2_EthetaSourceSel),
    .AXIS2_CalibrationEN(AXIS2_CalibrationEN),
    .AXIS2_CalibrationState(AXIS2_CalibrationState),
    .AXIS2_ENCNoResponsPluse(AXIS2_ENCNoResponsPluse),
    .AXIS2_ENCCRCERRPluse(AXIS2_ENCCRCERRPluse), 
    .AXIS2_SD(AXIS2_SD),
    .AXIS2_RQ(AXIS2_RQ),
    .AXIS2_BISSCCLK(AXIS2_BISSCCLK),
    .AXIS2_DRCNT(AXIS2_DRCNT),  
    .AXIS3_AngleDriverSel(AXIS3_EthetaSourceSel),
    .AXIS3_CalibrationEN(AXIS3_CalibrationEN),
    .AXIS3_CalibrationState(AXIS3_CalibrationState),
    .AXIS3_ENCNoResponsPluse(AXIS3_ENCNoResponsPluse),
    .AXIS3_ENCCRCERRPluse(AXIS3_ENCCRCERRPluse), 
    .AXIS3_SD(AXIS3_SD),
    .AXIS3_RQ(AXIS3_RQ),
    .AXIS3_DRCNT(AXIS3_DRCNT),
    .AXIS3_BISSCCLK(AXIS3_BISSCCLK),
    .AXIS4_AngleDriverSel(AXIS4_EthetaSourceSel),
    .AXIS4_CalibrationEN(AXIS4_CalibrationEN),
    .AXIS4_CalibrationState(AXIS4_CalibrationState),
    .AXIS4_ENCNoResponsPluse(AXIS4_ENCNoResponsPluse),
    .AXIS4_ENCCRCERRPluse(AXIS4_ENCCRCERRPluse), 
    .AXIS4_SD(AXIS4_SD),
    .AXIS4_RQ(AXIS4_RQ),
    .AXIS4_DRCNT(AXIS4_DRCNT),   
    .AXIS4_BISSCCLK(AXIS4_BISSCCLK),    
    //internal sigs
    .RequestTrig(RequestTrig),
    .AXIS1_MechanicalPosition(AXIS1_MechanicalPosition),
    .AXIS1_DataValid(AXIS1_DataValid),
    .AXIS2_MechanicalPosition(AXIS2_MechanicalPosition),
    .AXIS2_DataValid(AXIS2_DataValid),
    .AXIS3_MechanicalPosition(AXIS3_MechanicalPosition),
    .AXIS3_DataValid(AXIS3_DataValid),
    .AXIS4_MechanicalPosition(AXIS4_MechanicalPosition),
    .AXIS4_DataValid(AXIS4_DataValid)
    );

    

EAnglesCalScheduler EAnglesCalScheduler(
    .clk(clk100Mhz),//20Mhz
    .rst(rst),
    //==Encoder driver input
    .RequestTrig(RequestTrig),
    .TimeCriticalPluse(TimeCriticalPluse),
    .AXIS1_MechanicalPosition(AXIS1_MechanicalPosition),
    .AXIS1_DataValid(AXIS1_DataValid),
    .AXIS2_MechanicalPosition(AXIS2_MechanicalPosition),
    .AXIS2_DataValid(AXIS2_DataValid),
    .AXIS3_MechanicalPosition(AXIS3_MechanicalPosition),
    .AXIS3_DataValid(AXIS3_DataValid),
    .AXIS4_MechanicalPosition(AXIS4_MechanicalPosition),
    .AXIS4_DataValid(AXIS4_DataValid),
    //==paras
    .AXIS1_TransCoeff(AXIS1_TransCoeff),
    .AXIS1_ZeroSet(AXIS1_ZeroSet),
    .AXIS1_InvTransAngleComp(AXIS1_InvTransAngleComp),
    .AXIS1_Polarity(AXIS1_Polarity),
    .AXIS2_TransCoeff(AXIS2_TransCoeff),
    .AXIS2_ZeroSet(AXIS2_ZeroSet),
    .AXIS2_InvTransAngleComp(AXIS2_InvTransAngleComp),
    .AXIS2_Polarity(AXIS2_Polarity),
    .AXIS3_TransCoeff(AXIS3_TransCoeff),
    .AXIS3_ZeroSet(AXIS3_ZeroSet),
    .AXIS3_InvTransAngleComp(AXIS3_InvTransAngleComp),
    .AXIS3_Polarity(AXIS3_Polarity),
    .AXIS4_TransCoeff(AXIS4_TransCoeff),
    .AXIS4_ZeroSet(AXIS4_ZeroSet),
    .AXIS4_InvTransAngleComp(AXIS4_InvTransAngleComp),
    .AXIS4_Polarity(AXIS4_Polarity),
    //==VirtualTheta input
    .AXIS1_VirtualTheta(AXIS1_VirtualTheta), 
    .AXIS1_VirtualTheta_UpdatePluse(AXIS1_VirtualTheta_UpdatePluse),
    .AXIS1_VirtualThetaEnable(AXIS1_VirtualThetaEnable),
    .AXIS2_VirtualTheta(AXIS2_VirtualTheta), 
    .AXIS2_VirtualTheta_UpdatePluse(AXIS2_VirtualTheta_UpdatePluse),
    .AXIS2_VirtualThetaEnable(AXIS2_VirtualThetaEnable),
    .AXIS3_VirtualTheta(AXIS3_VirtualTheta), 
    .AXIS3_VirtualTheta_UpdatePluse(AXIS3_VirtualTheta_UpdatePluse),
    .AXIS3_VirtualThetaEnable(AXIS3_VirtualThetaEnable),
    .AXIS4_VirtualTheta(AXIS4_VirtualTheta), 
    .AXIS4_VirtualTheta_UpdatePluse(AXIS4_VirtualTheta_UpdatePluse),
    .AXIS4_VirtualThetaEnable(AXIS4_VirtualThetaEnable),
    //==output
    .AXIS1_Etheta(AXIS1_Etheta),
    .AXIS1_COSVal(AXIS1_COSVal),
    .AXIS1_SINVal(AXIS1_SINVal),
    .AXIS1_InvCOSVal(AXIS1_InvCOSVal),
    .AXIS1_InvSINVal(AXIS1_InvSINVal),
    .AXIS1_CALOvertime(AXIS1_CALOvertime),
    .AXIS2_Etheta(AXIS2_Etheta),
    .AXIS2_COSVal(AXIS2_COSVal),
    .AXIS2_SINVal(AXIS2_SINVal),
    .AXIS2_InvCOSVal(AXIS2_InvCOSVal),
    .AXIS2_InvSINVal(AXIS2_InvSINVal),
    .AXIS2_CALOvertime(AXIS2_CALOvertime),
    .AXIS3_Etheta(AXIS3_Etheta),
    .AXIS3_COSVal(AXIS3_COSVal),
    .AXIS3_SINVal(AXIS3_SINVal),
    .AXIS3_InvCOSVal(AXIS3_InvCOSVal),
    .AXIS3_InvSINVal(AXIS3_InvSINVal),
    .AXIS3_CALOvertime(AXIS3_CALOvertime),
    .AXIS4_Etheta(AXIS4_Etheta),
    .AXIS4_COSVal(AXIS4_COSVal),
    .AXIS4_SINVal(AXIS4_SINVal),
    .AXIS4_InvCOSVal(AXIS4_InvCOSVal),
    .AXIS4_InvSINVal(AXIS4_InvSINVal),
    .AXIS4_CALOvertime(AXIS4_CALOvertime)
    );
    
    

endmodule

