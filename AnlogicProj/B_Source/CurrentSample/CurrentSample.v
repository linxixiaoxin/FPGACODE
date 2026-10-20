module CurrentSample(
    input                       clk100Mhz,
    input                       clk20Mhz,
    input                       rst,
    //hardware interface
    output                      DSASCCLK,
    input                       Axis1_IUBitin,
    input                       Axis1_IVBitin,
    input                       Axis2_IUBitin,
    input                       Axis2_IVBitin,
    input                       Axis3_IUBitin,
    input                       Axis3_IVBitin,
    input                       Axis4_IUBitin,
    input                       Axis4_IVBitin,
    //data & addr bus
    input                       RDLWRH,
    input           [15:0]      ADDR,
    input           [15:0]      WRDATA,    
    input                       CS,
    output          [15:0]      RDDATA,    
    //for safety module
    output                      Axis1_OC,
    output                      Axis2_OC,
    output                      Axis3_OC,
    output                      Axis4_OC,           
    //For ACR
    input                       ACRLockTrig,
    output          [15:0]      Axis1_IU_Locked,
    output          [15:0]      Axis1_IV_Locked,
    output          [15:0]      Axis2_IU_Locked,
    output          [15:0]      Axis2_IV_Locked,
    output          [15:0]      Axis3_IU_Locked,
    output          [15:0]      Axis3_IV_Locked,
    output          [15:0]      Axis4_IU_Locked,
    output          [15:0]      Axis4_IV_Locked,
    output                      DataLockedPluse
    );
    
    wire            [1:0]   Axis1_polarity;
    wire            [1:0]   Axis2_polarity;
    wire            [1:0]   Axis3_polarity;
    wire            [1:0]   Axis4_polarity;
    wire            [15:0]  Axis1_IU_Offset;
    wire            [15:0]  Axis1_IV_Offset;
    wire            [15:0]  Axis2_IU_Offset;
    wire            [15:0]  Axis2_IV_Offset;
    wire            [15:0]  Axis3_IU_Offset;
    wire            [15:0]  Axis3_IV_Offset;
    wire            [15:0]  Axis4_IU_Offset;
    wire            [15:0]  Axis4_IV_Offset;
    wire            [15:0]  Axis1_IMax;
    wire            [15:0]  Axis1_IMin;
    wire            [15:0]  Axis2_IMax;
    wire            [15:0]  Axis2_IMin;
    wire            [15:0]  Axis3_IMax;
    wire            [15:0]  Axis3_IMin;
    wire            [15:0]  Axis4_IMax;
    wire            [15:0]  Axis4_IMin;  
    
    wire    signed  [15:0]  Axis1_IU;
    wire    signed  [15:0]  Axis1_IV;
    wire    signed  [15:0]  Axis2_IU;
    wire    signed  [15:0]  Axis2_IV;
    wire    signed  [15:0]  Axis3_IU;
    wire    signed  [15:0]  Axis3_IV;
    wire    signed  [15:0]  Axis4_IU;
    wire    signed  [15:0]  Axis4_IV;
    
RegSpcae_CurrentSample RegSpcae_CurrentSample_inst(
    .clk(clk100Mhz),
    .rst(rst),
    //data & addr bus
    .CS(CS),
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .RDDATA(RDDATA),
    
    //inner reg interface
    .Axis1_polarity(Axis1_polarity),
    .Axis2_polarity(Axis2_polarity),
    .Axis3_polarity(Axis3_polarity),
    .Axis4_polarity(Axis4_polarity),
    .Axis1_IU_Offset(Axis1_IU_Offset),
    .Axis1_IV_Offset(Axis1_IV_Offset),
    .Axis2_IU_Offset(Axis2_IU_Offset),
    .Axis2_IV_Offset(Axis2_IV_Offset),
    .Axis3_IU_Offset(Axis3_IU_Offset),
    .Axis3_IV_Offset(Axis3_IV_Offset),
    .Axis4_IU_Offset(Axis4_IU_Offset),
    .Axis4_IV_Offset(Axis4_IV_Offset),
    
    .Axis1_IMax(Axis1_IMax),
    .Axis1_IMin(Axis1_IMin),
    .Axis2_IMax(Axis2_IMax),
    .Axis2_IMin(Axis2_IMin),
    .Axis3_IMax(Axis3_IMax),
    .Axis3_IMin(Axis3_IMin),
    .Axis4_IMax(Axis4_IMax),
    .Axis4_IMin(Axis4_IMin),
    
    .Axis1_IU(Axis1_IU),
    .Axis1_IV(Axis1_IV),
    .Axis2_IU(Axis2_IU),
    .Axis2_IV(Axis2_IV),
    .Axis3_IU(Axis3_IU),
    .Axis3_IV(Axis3_IV),
    .Axis4_IU(Axis4_IU),
    .Axis4_IV(Axis4_IV),
    
    .Axis1_IU_Locked(Axis1_IU_Locked),
    .Axis1_IV_Locked(Axis1_IV_Locked),
    .Axis2_IU_Locked(Axis2_IU_Locked),
    .Axis2_IV_Locked(Axis2_IV_Locked),
    .Axis3_IU_Locked(Axis3_IU_Locked),
    .Axis3_IV_Locked(Axis3_IV_Locked),
    .Axis4_IU_Locked(Axis4_IU_Locked),
    .Axis4_IV_Locked(Axis4_IV_Locked)
    );


ADCsDriver ADCsDriver_inst(
    .clk100Mhz(clk100Mhz),
    .clk20Mhz(clk20Mhz),
    .rst(rst),
    //hardware interface
    .DSASCCLK(DSASCCLK),
    .Axis1_IUBitin(Axis1_IUBitin),
    .Axis1_IVBitin(Axis1_IVBitin),
    .Axis2_IUBitin(Axis2_IUBitin),
    .Axis2_IVBitin(Axis2_IVBitin),
    .Axis3_IUBitin(Axis3_IUBitin),
    .Axis3_IVBitin(Axis3_IVBitin),
    .Axis4_IUBitin(Axis4_IUBitin),
    .Axis4_IVBitin(Axis4_IVBitin), 
    //user set paras
    .Axis1_polarity(Axis1_polarity),
    .Axis2_polarity(Axis2_polarity),
    .Axis3_polarity(Axis3_polarity),
    .Axis4_polarity(Axis4_polarity),
    .Axis1_IU_Offset(Axis1_IU_Offset),
    .Axis1_IV_Offset(Axis1_IV_Offset),
    .Axis2_IU_Offset(Axis2_IU_Offset),
    .Axis2_IV_Offset(Axis2_IV_Offset),
    .Axis3_IU_Offset(Axis3_IU_Offset),
    .Axis3_IV_Offset(Axis3_IV_Offset),
    .Axis4_IU_Offset(Axis4_IU_Offset),
    .Axis4_IV_Offset(Axis4_IV_Offset), 
    //output data
    .Axis1_IU(Axis1_IU),
    .Axis1_IV(Axis1_IV),
    .Axis2_IU(Axis2_IU),
    .Axis2_IV(Axis2_IV),
    .Axis3_IU(Axis3_IU),
    .Axis3_IV(Axis3_IV),
    .Axis4_IU(Axis4_IU),
    .Axis4_IV(Axis4_IV)
    );
    

AllCurrentMonitor AllCurrentMonitor_inst(
    .clk(clk100Mhz),
    .rst(rst),
    //inner interface
    .Axis1_IU(Axis1_IU),
    .Axis1_IV(Axis1_IV),
    .Axis2_IU(Axis2_IU),
    .Axis2_IV(Axis2_IV),
    .Axis3_IU(Axis3_IU),
    .Axis3_IV(Axis3_IV),
    .Axis4_IU(Axis4_IU),
    .Axis4_IV(Axis4_IV),
    //user set paras
    .Axis1_IMax(Axis1_IMax),
    .Axis1_IMin(Axis1_IMin),
    .Axis2_IMax(Axis2_IMax),
    .Axis2_IMin(Axis2_IMin),
    .Axis3_IMax(Axis3_IMax),
    .Axis3_IMin(Axis3_IMin),
    .Axis4_IMax(Axis4_IMax),
    .Axis4_IMin(Axis4_IMin),   
    //outputs
    .Axis1_OC(Axis1_OC),
    .Axis2_OC(Axis2_OC),
    .Axis3_OC(Axis3_OC),
    .Axis4_OC(Axis4_OC)
    );
    
CurrentForACR CurrentForACR_inst(
    .clk(clk100Mhz),
    .rst(rst),
    //inner interface
    .Axis1_IU(Axis1_IU),
    .Axis1_IV(Axis1_IV),
    .Axis2_IU(Axis2_IU),
    .Axis2_IV(Axis2_IV),
    .Axis3_IU(Axis3_IU),
    .Axis3_IV(Axis3_IV),
    .Axis4_IU(Axis4_IU),
    .Axis4_IV(Axis4_IV),
    .ACRLockTrig(ACRLockTrig),
    //outputs
    .Axis1_IU_Locked(Axis1_IU_Locked),
    .Axis1_IV_Locked(Axis1_IV_Locked),
    .Axis2_IU_Locked(Axis2_IU_Locked),
    .Axis2_IV_Locked(Axis2_IV_Locked),
    .Axis3_IU_Locked(Axis3_IU_Locked),
    .Axis3_IV_Locked(Axis3_IV_Locked),
    .Axis4_IU_Locked(Axis4_IU_Locked),
    .Axis4_IV_Locked(Axis4_IV_Locked),
    .DataLockedPluse(DataLockedPluse)
    ); 

endmodule
