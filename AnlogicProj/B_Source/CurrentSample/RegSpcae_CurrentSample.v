module RegSpcae_CurrentSample(
    input                       clk,
    input                       rst,
    //data & addr bus
    input                       CS,
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,
    output  reg         [15:0]  RDDATA,
    
    //inner reg interface
    output  reg         [1:0]   Axis1_polarity,//define Driver to Motor is positive, value is 1;Motor to Driver is negetive, value is 0
    output  reg         [1:0]   Axis2_polarity,
    output  reg         [1:0]   Axis3_polarity,
    output  reg         [1:0]   Axis4_polarity,
    output  reg         [15:0]  Axis1_IU_Offset,
    output  reg         [15:0]  Axis1_IV_Offset,
    output  reg         [15:0]  Axis2_IU_Offset,
    output  reg         [15:0]  Axis2_IV_Offset,
    output  reg         [15:0]  Axis3_IU_Offset,
    output  reg         [15:0]  Axis3_IV_Offset,
    output  reg         [15:0]  Axis4_IU_Offset,
    output  reg         [15:0]  Axis4_IV_Offset,
    
    output  reg         [15:0]  Axis1_IMax,
    output  reg         [15:0]  Axis1_IMin,
    output  reg         [15:0]  Axis2_IMax,
    output  reg         [15:0]  Axis2_IMin,
    output  reg         [15:0]  Axis3_IMax,
    output  reg         [15:0]  Axis3_IMin,
    output  reg         [15:0]  Axis4_IMax,
    output  reg         [15:0]  Axis4_IMin,
    
    input               [15:0]  Axis1_IU,
    input               [15:0]  Axis1_IV,
    input               [15:0]  Axis2_IU,
    input               [15:0]  Axis2_IV,
    input               [15:0]  Axis3_IU,
    input               [15:0]  Axis3_IV,
    input               [15:0]  Axis4_IU,
    input               [15:0]  Axis4_IV,
    
    input               [15:0]  Axis1_IU_Locked,
    input               [15:0]  Axis1_IV_Locked,
    input               [15:0]  Axis2_IU_Locked,
    input               [15:0]  Axis2_IV_Locked,
    input               [15:0]  Axis3_IU_Locked,
    input               [15:0]  Axis3_IV_Locked,
    input               [15:0]  Axis4_IU_Locked,
    input               [15:0]  Axis4_IV_Locked
    );
    
    wire            RD;
    wire            WR;
    assign  RD = CS&&(RDLWRH==1'b0);
    assign  WR = CS&&(RDLWRH==1'b1);
    
    //regs Write===========================================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            Axis1_IU_Offset<=16'd0;
            Axis1_IV_Offset<=16'd0;
            Axis1_polarity<=2'b00;
            Axis1_IMax<=$signed(16'd32767);
            Axis1_IMin<=$signed(-16'd32767);
            Axis2_IU_Offset<=16'd0;
            Axis2_IV_Offset<=16'd0;
            Axis2_polarity<=2'b00;
            Axis2_IMax<=$signed(16'd32767);
            Axis2_IMin<=$signed(-16'd32767);
            Axis3_IU_Offset<=16'd0;
            Axis3_IV_Offset<=16'd0;
            Axis3_polarity<=2'b00;
            Axis3_IMax<=$signed(16'd32767);
            Axis3_IMin<=$signed(-16'd32767);
            Axis4_IU_Offset<=16'd0;
            Axis4_IV_Offset<=16'd0;
            Axis4_polarity<=2'b00;
            Axis4_IMax<=$signed(16'd32767);
            Axis4_IMin<=$signed(-16'd32767);            
        end
        else begin
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0000:Axis1_IU_Offset<=WRDATA;
                16'h0001:Axis1_IV_Offset<=WRDATA;
                16'h0002:Axis1_polarity<=WRDATA[1:0];
                16'h0005:Axis1_IMax<=WRDATA;
                16'h0006:Axis1_IMin<=WRDATA;
                16'h0020:Axis2_IU_Offset<=WRDATA;
                16'h0021:Axis2_IV_Offset<=WRDATA;
                16'h0022:Axis2_polarity<=WRDATA[1:0];
                16'h0025:Axis2_IMax<=WRDATA;
                16'h0026:Axis2_IMin<=WRDATA;
                16'h0040:Axis3_IU_Offset<=WRDATA;
                16'h0041:Axis3_IV_Offset<=WRDATA;
                16'h0042:Axis3_polarity<=WRDATA[1:0];
                16'h0045:Axis3_IMax<=WRDATA;
                16'h0046:Axis3_IMin<=WRDATA;
                16'h0060:Axis4_IU_Offset<=WRDATA;
                16'h0061:Axis4_IV_Offset<=WRDATA;
                16'h0062:Axis4_polarity<=WRDATA[1:0];
                16'h0065:Axis4_IMax<=WRDATA;
                16'h0066:Axis4_IMin<=WRDATA;                
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
                16'h0000:RDDATA<=Axis1_IU_Offset;
                16'h0001:RDDATA<=Axis1_IV_Offset;
                16'h0002:RDDATA<={14'd0,Axis1_polarity};
                16'h0003:RDDATA<=Axis1_IU;
                16'h0004:RDDATA<=Axis1_IV;
                16'h0005:RDDATA<=Axis1_IMax;
                16'h0006:RDDATA<=Axis1_IMin;
                16'h0007:RDDATA<=Axis1_IU_Locked;
                16'h0008:RDDATA<=Axis1_IV_Locked;
                16'h0020:RDDATA<=Axis2_IU_Offset;
                16'h0021:RDDATA<=Axis2_IV_Offset;
                16'h0022:RDDATA<={14'd0,Axis2_polarity};
                16'h0023:RDDATA<=Axis2_IU;
                16'h0024:RDDATA<=Axis2_IV;
                16'h0025:RDDATA<=Axis2_IMax;
                16'h0026:RDDATA<=Axis2_IMin;
                16'h0027:RDDATA<=Axis2_IU_Locked;
                16'h0028:RDDATA<=Axis2_IV_Locked;
                16'h0040:RDDATA<=Axis3_IU_Offset;
                16'h0041:RDDATA<=Axis3_IV_Offset;
                16'h0042:RDDATA<={14'd0,Axis3_polarity};
                16'h0043:RDDATA<=Axis3_IU;
                16'h0044:RDDATA<=Axis3_IV;
                16'h0045:RDDATA<=Axis3_IMax;
                16'h0046:RDDATA<=Axis3_IMin;
                16'h0047:RDDATA<=Axis3_IU_Locked;
                16'h0048:RDDATA<=Axis3_IV_Locked;
                16'h0060:RDDATA<=Axis4_IU_Offset;
                16'h0061:RDDATA<=Axis4_IV_Offset;
                16'h0062:RDDATA<={14'd0,Axis4_polarity};
                16'h0063:RDDATA<=Axis4_IU;
                16'h0064:RDDATA<=Axis4_IV;
                16'h0065:RDDATA<=Axis4_IMax;
                16'h0066:RDDATA<=Axis4_IMin;
                16'h0067:RDDATA<=Axis4_IU_Locked;
                16'h0068:RDDATA<=Axis4_IV_Locked;                
           
                default:RDDATA<=16'd0;
                endcase
            end
        end
    end 
endmodule
