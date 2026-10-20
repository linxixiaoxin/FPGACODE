module CurrentForACR(
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
    input                       ACRLockTrig,
    //outputs
    output  reg         [15:0]  Axis1_IU_Locked,
    output  reg         [15:0]  Axis1_IV_Locked,
    output  reg         [15:0]  Axis2_IU_Locked,
    output  reg         [15:0]  Axis2_IV_Locked,
    output  reg         [15:0]  Axis3_IU_Locked,
    output  reg         [15:0]  Axis3_IV_Locked,
    output  reg         [15:0]  Axis4_IU_Locked,
    output  reg         [15:0]  Axis4_IV_Locked,
    output  reg                 DataLockedPluse
    );

    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Axis1_IU_Locked<=16'd0;
            Axis1_IV_Locked<=16'd0;
            Axis2_IU_Locked<=16'd0;
            Axis2_IV_Locked<=16'd0;
            Axis3_IU_Locked<=16'd0;
            Axis3_IV_Locked<=16'd0;
            Axis4_IU_Locked<=16'd0;
            Axis4_IV_Locked<=16'd0;
            
        end
        else begin
            if(ACRLockTrig==1'b1)begin
                Axis1_IU_Locked<=Axis1_IU;
                Axis1_IV_Locked<=Axis1_IV;
                Axis2_IU_Locked<=Axis2_IU;
                Axis2_IV_Locked<=Axis2_IV;
                Axis3_IU_Locked<=Axis3_IU;
                Axis3_IV_Locked<=Axis3_IV;
                Axis4_IU_Locked<=Axis4_IU;
                Axis4_IV_Locked<=Axis4_IV;
            end
            
            if(ACRLockTrig==1'b1)
                DataLockedPluse<=1'b1;
            else
                DataLockedPluse<=1'b0;
        end
    end


endmodule
