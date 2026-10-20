module RegSpcae_UnrelatedSigSample(
    input                       clk,
    input                       rst,
    //data & addr bus
    input                       CS,
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,
    output  reg         [15:0]  RDDATA,
    
    //inner reg interface
    input               [15:0]  Vbus,
    input               [15:0]  DIs,
    output  reg         [15:0]  DOs,

    input               [31:0]  PositionFB_Aside,
    input               [31:0]  PositionFB_Dside
    );
    
    wire            RD;
    wire            WR;
    assign  RD = CS&&(RDLWRH==1'b0);
    assign  WR = CS&&(RDLWRH==1'b1);
    
    
    reg     [15:0]  PositionFB_Aside_LowHalfLock;
    reg     [15:0]  PositionFB_Dside_LowHalfLock;
    //regs Write===========================================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            DOs<=16'd0;
        end
        else begin
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0002:DOs<=WRDATA;
                endcase
            end
        end
    end
   
    
    //regs Read===========================================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            RDDATA<=16'd0;
        end
        else begin
            if(RD==1'b1)begin
                case(ADDR) 
                16'h0000:RDDATA<=Vbus;
                16'h0001:RDDATA<=DIs;
                16'h0002:RDDATA<=DOs;
                
                16'h0004:RDDATA<=PositionFB_Aside[31:16];
                16'h0005:RDDATA<=PositionFB_Aside_LowHalfLock;
                16'h0006:RDDATA<=PositionFB_Dside[31:16];
                16'h0007:RDDATA<=PositionFB_Dside_LowHalfLock;
                default:RDDATA<=16'd0;
                endcase
            end
        end
    end 
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            PositionFB_Aside_LowHalfLock<=16'd0;
            PositionFB_Dside_LowHalfLock<=16'd0;
        end
        else begin
            if(RD==1'b1)begin
                case(ADDR) 
                16'h0004:PositionFB_Aside_LowHalfLock<=PositionFB_Aside[15:0];
                16'h0006:PositionFB_Dside_LowHalfLock<=PositionFB_Dside[15:0];
                endcase
            end
        end
    end
endmodule
