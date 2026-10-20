module SafetyMonitor(
    input                       clk,
    input                       rst,
    //hardware interface
    input                       Axis1_IPMFault,
    input                       Axis2_IPMFault,
    input                       Axis3_IPMFault,
    input                       Axis4_IPMFault,
    input                       Axis1_OC,
    input                       Axis2_OC,
    input                       Axis3_OC,
    input                       Axis4_OC,
    //Unlock carrier module
    output                      Axis1_PWMUNLOCK,
    output                      Axis2_PWMUNLOCK,
    output                      Axis3_PWMUNLOCK,
    output                      Axis4_PWMUNLOCK,
    //pwm output channel enbale
    output                      Axis1_PWMEN,
    output                      Axis2_PWMEN,
    output                      Axis3_PWMEN,
    output                      Axis4_PWMEN,  
    //sto
    output                      STOout,
    //SysResetSig
    output                      SysResetSig,
    //data & addr bus
    input                       RDLWRH,
    input           [15:0]      ADDR,
    input           [15:0]      WRDATA,    
    input                       CS,
    output          [15:0]      RDDATA   
    );
    
RegSpcae_SafetyMonitor RegSpcae_SafetyMonitor(
    .clk(clk),
    .rst(rst),
    //data & addr bus
    .CS(CS),
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .RDDATA(RDDATA),
    //inner reg interface
    .Axis1_IPMFault(Axis1_IPMFault),
    .Axis2_IPMFault(Axis2_IPMFault),
    .Axis3_IPMFault(Axis3_IPMFault),
    .Axis4_IPMFault(Axis4_IPMFault),
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
    .Axis1_PWMEN(Axis1_PWMEN),
    .Axis2_PWMEN(Axis2_PWMEN),
    .Axis3_PWMEN(Axis3_PWMEN),
    .Axis4_PWMEN(Axis4_PWMEN),  
    
    .STOout(STOout),
    .SysResetSig(SysResetSig)
    );
    
endmodule
