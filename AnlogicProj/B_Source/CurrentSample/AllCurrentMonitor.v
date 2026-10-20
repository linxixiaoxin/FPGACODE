module AllCurrentMonitor(
    input                       clk,
    input                       rst,
    //inner interface
    input       signed  [15:0]  Axis1_IU,
    input       signed  [15:0]  Axis1_IV,
    input       signed  [15:0]  Axis2_IU,
    input       signed  [15:0]  Axis2_IV,
    input       signed  [15:0]  Axis3_IU,
    input       signed  [15:0]  Axis3_IV,
    input       signed  [15:0]  Axis4_IU,
    input       signed  [15:0]  Axis4_IV,
    //user set paras
    input       signed  [15:0]  Axis1_IMax,
    input       signed  [15:0]  Axis1_IMin,
    input       signed  [15:0]  Axis2_IMax,
    input       signed  [15:0]  Axis2_IMin,
    input       signed  [15:0]  Axis3_IMax,
    input       signed  [15:0]  Axis3_IMin,
    input       signed  [15:0]  Axis4_IMax,
    input       signed  [15:0]  Axis4_IMin,   
    //outputs
    output                      Axis1_OC,
    output                      Axis2_OC,
    output                      Axis3_OC,
    output                      Axis4_OC
    );

    
MotorCurrentMonitor Axis1(
    .clk(clk),
    .rst(rst),
    .IU(Axis1_IU),
    .IV(Axis1_IV),
    .IMax(Axis1_IMax),
    .IMin(Axis1_IMin),   
    .OC(Axis1_OC)
    );
    
MotorCurrentMonitor Axis2(
    .clk(clk),
    .rst(rst),
    .IU(Axis2_IU),
    .IV(Axis2_IV),
    .IMax(Axis2_IMax),
    .IMin(Axis2_IMin),   
    .OC(Axis2_OC)
    );

MotorCurrentMonitor Axis3(
    .clk(clk),
    .rst(rst),
    .IU(Axis3_IU),
    .IV(Axis3_IV),
    .IMax(Axis3_IMax),
    .IMin(Axis3_IMin),   
    .OC(Axis3_OC)
    );

MotorCurrentMonitor Axis4(
    .clk(clk),
    .rst(rst),
    .IU(Axis4_IU),
    .IV(Axis4_IV),
    .IMax(Axis4_IMax),
    .IMin(Axis4_IMin),   
    .OC(Axis4_OC)
    );    
    
    
endmodule
