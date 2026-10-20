/*
InputCurrentMonitor InputCurrentMonitor_inst(
    .IU(),
    .IV(),
    .OutOFRange()
    );
*/
module InputCurrentMonitor(
    input       signed  [15:0]  IU,//16bit 
    input       signed  [15:0]  IV,//16bit
    output                      OutOFRange//means that IW need 17 bit to deal
    );

    
    wire    signed  [16:0]  IU_extend;
    wire    signed  [16:0]  IV_extend;
    wire    signed  [16:0]  IW_extend;
    
    assign IU_extend = {IU[15],IU};
    assign IV_extend = {IV[15],IV};
    
    assign IW_extend = -(IU_extend + IV_extend);
    
    assign OutOFRange = IW_extend[16] != IW_extend[15];
    
endmodule
