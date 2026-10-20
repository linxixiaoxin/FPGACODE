module EncoderDrivers(
    input                       clk_20Mhz,//20Mhz
    input                       clk_100Mhz,//20Mhz
    input                       rst,
    //hardware interface
    input       [3:0]           AXIS1_AngleDriverSel,
    input                       AXIS1_CalibrationEN,
    output      [3:0]           AXIS1_CalibrationState,
    output                      AXIS1_ENCNoResponsPluse,
    output                      AXIS1_ENCCRCERRPluse, 
    input                       AXIS1_PluseA,
    input                       AXIS1_PluseB,
    input                       AXIS1_PluseZ,                     
    input                       AXIS1_SD,
    output                      AXIS1_RQ,
    output                      AXIS1_DRCNT,
    output                      AXIS1_BISSCCLK,
    
    input       [3:0]           AXIS2_AngleDriverSel,
    input                       AXIS2_CalibrationEN,
    output      [3:0]           AXIS2_CalibrationState,
    output                      AXIS2_ENCNoResponsPluse,
    output                      AXIS2_ENCCRCERRPluse,
    input                       AXIS2_SD,
    output                      AXIS2_RQ,
    output                      AXIS2_DRCNT,  
    output                      AXIS2_BISSCCLK,
    
    input       [3:0]           AXIS3_AngleDriverSel, 
    input                       AXIS3_CalibrationEN,
    output      [3:0]           AXIS3_CalibrationState,
    output                      AXIS3_ENCNoResponsPluse,
    output                      AXIS3_ENCCRCERRPluse,
    input                       AXIS3_SD,
    output                      AXIS3_RQ,
    output                      AXIS3_DRCNT, 
    output                      AXIS3_BISSCCLK,    
    
    input       [3:0]           AXIS4_AngleDriverSel,
    input                       AXIS4_CalibrationEN,
    output      [3:0]           AXIS4_CalibrationState,
    output                      AXIS4_ENCNoResponsPluse,
    output                      AXIS4_ENCCRCERRPluse,
    input                       AXIS4_SD,
    output                      AXIS4_RQ,
    output                      AXIS4_DRCNT,
    output                      AXIS4_BISSCCLK,
    //internal sigs
    input                       RequestTrig,
    output      [31:0]          AXIS1_MechanicalPosition,
    output                      AXIS1_DataValid,
    output      [31:0]          AXIS2_MechanicalPosition,
    output                      AXIS2_DataValid,
    output      [31:0]          AXIS3_MechanicalPosition,
    output                      AXIS3_DataValid,
    output      [31:0]          AXIS4_MechanicalPosition,
    output                      AXIS4_DataValid
    );
    

EncoderSelect AXIS1_EncoderSelect(
    .clk_20Mhz(clk_20Mhz),//20Mhz
    .clk(clk_100Mhz),//100Mhz
    .rst(rst),
    .RequestTrig(RequestTrig),
    
    .AngleDriverSel(AXIS1_AngleDriverSel),
    
    .CalibrationEN(AXIS1_CalibrationEN),
    .CalibrationState(AXIS1_CalibrationState),
    .ENCNoResponsPluse(AXIS1_ENCNoResponsPluse),
    .ENCCRCERRPluse(AXIS1_ENCCRCERRPluse),
    
    .DMC_IN(AXIS1_SD),//485 TX
    .DMC_OUT(AXIS1_RQ),//485 RX
    .DMC_DE(AXIS1_DRCNT),//485 EN
    .BISSCCLK(AXIS1_BISSCCLK),
    
    .PluseA(AXIS1_PluseA),
    .PluseB(AXIS1_PluseB),
    .PluseZ(AXIS1_PluseZ),
    
    .MechanicalPosition(AXIS1_MechanicalPosition),
    .PositionValid(AXIS1_DataValid)
    );
    
EncoderSelect AXIS2_EncoderSelect(
    .clk_20Mhz(clk_20Mhz),//20Mhz
    .clk(clk_100Mhz),//100Mhz
    .rst(rst),
    .RequestTrig(RequestTrig),
    
    .AngleDriverSel(AXIS2_AngleDriverSel),
    
    .CalibrationEN(AXIS2_CalibrationEN),
    .CalibrationState(AXIS2_CalibrationState),
    .ENCNoResponsPluse(AXIS2_ENCNoResponsPluse),
    .ENCCRCERRPluse(AXIS2_ENCCRCERRPluse),
    
    .DMC_IN(AXIS2_SD),//485 TX
    .DMC_OUT(AXIS2_RQ),//485 RX
    .DMC_DE(AXIS2_DRCNT),//485 EN
    .BISSCCLK(AXIS2_BISSCCLK),
    
    .PluseA(1'b0),
    .PluseB(1'b0),
    .PluseZ(1'b0),
    
    .MechanicalPosition(AXIS2_MechanicalPosition),
    .PositionValid(AXIS2_DataValid)
    );

EncoderSelect AXIS3_EncoderSelect(
    .clk_20Mhz(clk_20Mhz),//20Mhz
    .clk(clk_100Mhz),//100Mhz
    .rst(rst),
    .RequestTrig(RequestTrig),
    
    .AngleDriverSel(AXIS3_AngleDriverSel),
    
    .CalibrationEN(AXIS3_CalibrationEN),
    .CalibrationState(AXIS3_CalibrationState),
    .ENCNoResponsPluse(AXIS3_ENCNoResponsPluse),
    .ENCCRCERRPluse(AXIS3_ENCCRCERRPluse),
    
    .DMC_IN(AXIS3_SD),//485 TX
    .DMC_OUT(AXIS3_RQ),//485 RX
    .DMC_DE(AXIS3_DRCNT),//485 EN
    .BISSCCLK(AXIS3_BISSCCLK),
    
    .PluseA(1'b0),
    .PluseB(1'b0),
    .PluseZ(1'b0),
    
    .MechanicalPosition(AXIS3_MechanicalPosition),
    .PositionValid(AXIS3_DataValid)
    );

EncoderSelect AXIS4_EncoderSelect(
    .clk_20Mhz(clk_20Mhz),//20Mhz
    .clk(clk_100Mhz),//100Mhz
    .rst(rst),
    .RequestTrig(RequestTrig),
    
    .AngleDriverSel(AXIS4_AngleDriverSel),
    
    .CalibrationEN(AXIS4_CalibrationEN),
    .CalibrationState(AXIS4_CalibrationState),
    .ENCNoResponsPluse(AXIS4_ENCNoResponsPluse),
    .ENCCRCERRPluse(AXIS4_ENCCRCERRPluse),
    
    .DMC_IN(AXIS4_SD),//485 TX
    .DMC_OUT(AXIS4_RQ),//485 RX
    .DMC_DE(AXIS4_DRCNT),//485 EN
    .BISSCCLK(AXIS4_BISSCCLK),
    
    .PluseA(1'b0),
    .PluseB(1'b0),
    .PluseZ(1'b0),
    
    .MechanicalPosition(AXIS4_MechanicalPosition),
    .PositionValid(AXIS4_DataValid)
    );
  
endmodule

