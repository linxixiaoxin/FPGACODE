module MotorCurrentMonitor(
    input                       clk,
    input                       rst,
    input       signed  [15:0]  IU,
    input       signed  [15:0]  IV,
    input       signed  [15:0]  IMax,
    input       signed  [15:0]  IMin,   
    output  reg                 OC
    );

    wire    signed  [16:0]  IW_expand;
    wire    signed  [16:0]  IU_expand;
    wire    signed  [16:0]  IV_expand;
    wire    signed  [16:0]  IMax_expand;
    wire    signed  [16:0]  IMin_expand;
    assign IU_expand = {IU[15],IU};
    assign IV_expand = {IV[15],IV};
    assign IMax_expand = {IMax[15],IMax};
    assign IMin_expand = {IMin[15],IMin};
    
    assign IW_expand = -IU_expand - IV_expand;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            OC<=1'b0;
        else begin
            if((IU_expand>IMax_expand)||(IU_expand<IMin_expand)||
                (IV_expand>IMax_expand)||(IV_expand<IMin_expand)||
                (IW_expand>IMax_expand)||(IW_expand<IMin_expand)
                )
                OC<=1'b1;
            else
                OC<=1'b0;
        end
    end
    


endmodule
