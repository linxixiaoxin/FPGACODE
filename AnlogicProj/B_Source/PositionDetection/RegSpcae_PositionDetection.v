module RegSpcae_PositionDetection(
    input                       clk,
    input                       rst,
    //data & addr bus
    input                       CS,
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,
    output  reg         [15:0]  RDDATA,
    //inner reg interface
    output  reg         [31:0]  AXIS1_TransCoeff,
    output  reg         [15:0]  AXIS1_ZeroSet,
    output  reg         [15:0]  AXIS1_InvTransAngleComp,
    output                      AXIS1_Polarity,
    output              [3:0]   AXIS1_EthetaSourceSel,
    output  reg                 AXIS1_CalibrationEN,
    input               [3:0]   AXIS1_CalibrationState,
    input                       AXIS1_ENCNoResponsPluse,
    input                       AXIS1_ENCCRCERRPluse, 
    output  reg         [15:0]  AXIS1_VirtualTheta, 
    output  reg                 AXIS1_VirtualTheta_UpdatePluse,
    output                      AXIS1_VirtualThetaEnable,
    input               [31:0]  AXIS1_MechanicalPosition,
    input               [15:0]  AXIS1_Etheta,
    input                       AXIS1_CALOvertime,      
    
    output  reg         [31:0]  AXIS2_TransCoeff,
    output  reg         [15:0]  AXIS2_ZeroSet,
    output  reg         [15:0]  AXIS2_InvTransAngleComp,
    output                      AXIS2_Polarity,
    output              [3:0]   AXIS2_EthetaSourceSel, 
    output  reg                 AXIS2_CalibrationEN,
    input               [3:0]   AXIS2_CalibrationState,
    input                       AXIS2_ENCNoResponsPluse,
    input                       AXIS2_ENCCRCERRPluse, 
    output  reg         [15:0]  AXIS2_VirtualTheta,
    output  reg                 AXIS2_VirtualTheta_UpdatePluse,
    output                      AXIS2_VirtualThetaEnable,
    input               [31:0]  AXIS2_MechanicalPosition,
    input               [15:0]  AXIS2_Etheta,
    input                       AXIS2_CALOvertime, 

    output  reg         [31:0]  AXIS3_TransCoeff,
    output  reg         [15:0]  AXIS3_ZeroSet,
    output  reg         [15:0]  AXIS3_InvTransAngleComp,
    output                      AXIS3_Polarity,
    output              [3:0]   AXIS3_EthetaSourceSel,  
    output  reg                 AXIS3_CalibrationEN,
    input               [3:0]   AXIS3_CalibrationState,
    input                       AXIS3_ENCNoResponsPluse,
    input                       AXIS3_ENCCRCERRPluse, 
    output  reg         [15:0]  AXIS3_VirtualTheta,    
    output  reg                 AXIS3_VirtualTheta_UpdatePluse,
    output                      AXIS3_VirtualThetaEnable,
    input               [31:0]  AXIS3_MechanicalPosition,
    input               [15:0]  AXIS3_Etheta,
    input                       AXIS3_CALOvertime, 

    output  reg         [31:0]  AXIS4_TransCoeff,
    output  reg         [15:0]  AXIS4_ZeroSet,
    output  reg         [15:0]  AXIS4_InvTransAngleComp,
    output                      AXIS4_Polarity,
    output              [3:0]   AXIS4_EthetaSourceSel,
    output  reg                 AXIS4_CalibrationEN,
    input               [3:0]   AXIS4_CalibrationState,
    input                       AXIS4_ENCNoResponsPluse,
    input                       AXIS4_ENCCRCERRPluse, 
    output  reg         [15:0]  AXIS4_VirtualTheta,
    output  reg                 AXIS4_VirtualTheta_UpdatePluse,
    output                      AXIS4_VirtualThetaEnable,
    input               [31:0]  AXIS4_MechanicalPosition,
    input               [15:0]  AXIS4_Etheta,
    input                       AXIS4_CALOvertime
    );
    
    wire            RD;
    wire            WR;
    assign  RD = CS&&(RDLWRH==1'b0);
    assign  WR = CS&&(RDLWRH==1'b1);

    reg     [15:0]  AXIS1_CtrlReg;
    wire    [15:0]  AXIS1_Status;
    reg             AXIS1_Status_Overtime;
    assign AXIS1_EthetaSourceSel = AXIS1_CtrlReg[3:0];
    assign AXIS1_VirtualThetaEnable = AXIS1_CtrlReg[14];
    assign AXIS1_Polarity = AXIS1_CtrlReg[15];
    assign AXIS1_Status = {15'd0,AXIS1_Status_Overtime};
    reg     [15:0]  AXIS1_ENCCRCERRCNT;
    reg     [15:0]  AXIS1_ENCNoResponseCNT;
  
    
    reg     [15:0]  AXIS2_CtrlReg;
    wire    [15:0]  AXIS2_Status;
    reg             AXIS2_Status_Overtime;
    assign AXIS2_EthetaSourceSel = AXIS2_CtrlReg[3:0];
    assign AXIS2_VirtualThetaEnable = AXIS2_CtrlReg[14];
    assign AXIS2_Polarity = AXIS2_CtrlReg[15];
    assign AXIS2_Status = {15'd0,AXIS2_Status_Overtime};
    reg     [15:0]  AXIS2_ENCCRCERRCNT;
    reg     [15:0]  AXIS2_ENCNoResponseCNT;
    

    reg     [15:0]  AXIS3_CtrlReg;
    wire    [15:0]  AXIS3_Status;
    reg             AXIS3_Status_Overtime;
    assign AXIS3_EthetaSourceSel = AXIS3_CtrlReg[3:0];
    assign AXIS3_VirtualThetaEnable = AXIS3_CtrlReg[14];
    assign AXIS3_Polarity = AXIS3_CtrlReg[15];
    assign AXIS3_Status = {15'd0,AXIS3_Status_Overtime};
    reg     [15:0]  AXIS3_ENCCRCERRCNT;
    reg     [15:0]  AXIS3_ENCNoResponseCNT;
    

    reg     [15:0]  AXIS4_CtrlReg;
    wire    [15:0]  AXIS4_Status;
    reg             AXIS4_Status_Overtime;
    assign AXIS4_EthetaSourceSel = AXIS4_CtrlReg[3:0];
    assign AXIS4_VirtualThetaEnable = AXIS4_CtrlReg[14];
    assign AXIS4_Polarity = AXIS4_CtrlReg[15];
    assign AXIS4_Status = {15'd0,AXIS4_Status_Overtime};    
    reg     [15:0]  AXIS4_ENCCRCERRCNT;
    reg     [15:0]  AXIS4_ENCNoResponseCNT;
    
    
    reg     [15:0]  AXIS1_MechanicalPosition_LowHalfLock;
    reg     [15:0]  AXIS2_MechanicalPosition_LowHalfLock;
    reg     [15:0]  AXIS3_MechanicalPosition_LowHalfLock;
    reg     [15:0]  AXIS4_MechanicalPosition_LowHalfLock;

    //regs Write===========================================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            AXIS1_TransCoeff<=32'd65536;
            AXIS1_ZeroSet<=16'd0;
            AXIS1_InvTransAngleComp<=16'd0;
            AXIS1_VirtualTheta<=16'd0;
            AXIS1_CtrlReg<=16'd0;
            AXIS1_CalibrationEN<=1'b0;
            
            AXIS2_TransCoeff<=32'd65536;
            AXIS2_ZeroSet<=16'd0;
            AXIS2_InvTransAngleComp<=16'd0;
            AXIS2_VirtualTheta<=16'd0;
            AXIS2_CtrlReg<=16'd0;
            AXIS2_CalibrationEN<=1'b0;

            AXIS3_TransCoeff<=32'd65536;
            AXIS3_ZeroSet<=16'd0;
            AXIS3_InvTransAngleComp<=16'd0;
            AXIS3_VirtualTheta<=16'd0;
            AXIS3_CtrlReg<=16'd0;
            AXIS3_CalibrationEN<=1'b0;

            AXIS4_TransCoeff<=32'd65536;
            AXIS4_ZeroSet<=16'd0;
            AXIS4_InvTransAngleComp<=16'd0;
            AXIS4_VirtualTheta<=16'd0;
            AXIS4_CtrlReg<=16'd0;  
            AXIS4_CalibrationEN<=1'b0;
        end
        else begin
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0002:AXIS1_TransCoeff[31:16]<=WRDATA;   
                16'h0003:AXIS1_TransCoeff[15:0]<=WRDATA;
                16'h0004:AXIS1_ZeroSet<=WRDATA;
                16'h0006:AXIS1_InvTransAngleComp<=WRDATA;
                16'h0008:AXIS1_VirtualTheta<=WRDATA;
                16'h0009:AXIS1_CtrlReg<=WRDATA;
                16'h000C:AXIS1_CalibrationEN<=WRDATA[15];
                
                16'h0022:AXIS2_TransCoeff[31:16]<=WRDATA;   
                16'h0023:AXIS2_TransCoeff[15:0]<=WRDATA;
                16'h0024:AXIS2_ZeroSet<=WRDATA;
                16'h0026:AXIS2_InvTransAngleComp<=WRDATA;
                16'h0028:AXIS2_VirtualTheta<=WRDATA;
                16'h0029:AXIS2_CtrlReg<=WRDATA;   
                16'h002C:AXIS2_CalibrationEN<=WRDATA[15];

                16'h0042:AXIS3_TransCoeff[31:16]<=WRDATA;   
                16'h0043:AXIS3_TransCoeff[15:0]<=WRDATA;
                16'h0044:AXIS3_ZeroSet<=WRDATA;
                16'h0046:AXIS3_InvTransAngleComp<=WRDATA;
                16'h0048:AXIS3_VirtualTheta<=WRDATA;
                16'h0049:AXIS3_CtrlReg<=WRDATA;  
                16'h004C:AXIS3_CalibrationEN<=WRDATA[15];

                16'h0062:AXIS4_TransCoeff[31:16]<=WRDATA;   
                16'h0063:AXIS4_TransCoeff[15:0]<=WRDATA;
                16'h0064:AXIS4_ZeroSet<=WRDATA;
                16'h0066:AXIS4_InvTransAngleComp<=WRDATA;
                16'h0068:AXIS4_VirtualTheta<=WRDATA;
                16'h0069:AXIS4_CtrlReg<=WRDATA; 
                16'h006C:AXIS4_CalibrationEN<=WRDATA[15];
                
                endcase
            end
        end
    end 

    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            AXIS1_Status_Overtime<=1'b0;
            AXIS2_Status_Overtime<=1'b0;
            AXIS3_Status_Overtime<=1'b0;
            AXIS4_Status_Overtime<=1'b0;
        end
        else begin
            if(AXIS1_CALOvertime)
                AXIS1_Status_Overtime<=1'b1;
            else begin
                if((WR==1'b1)&&(ADDR==16'h0007)&&WRDATA[0]==1'b1)begin
                    AXIS1_Status_Overtime<=1'b0;
                end
            end
            
            if(AXIS2_CALOvertime)
                AXIS2_Status_Overtime<=1'b1;
            else begin
                if((WR==1'b1)&&(ADDR==16'h0027)&&WRDATA[0]==1'b1)begin
                    AXIS2_Status_Overtime<=1'b0;
                end
            end
            
            if(AXIS3_CALOvertime)
                AXIS3_Status_Overtime<=1'b1;
            else begin
                if((WR==1'b1)&&(ADDR==16'h0047)&&WRDATA[0]==1'b1)begin
                    AXIS3_Status_Overtime<=1'b0;
                end
            end
            
            if(AXIS4_CALOvertime)
                AXIS4_Status_Overtime<=1'b1;
            else begin
                if((WR==1'b1)&&(ADDR==16'h0067)&&WRDATA[0]==1'b1)begin
                    AXIS4_Status_Overtime<=1'b0;
                end
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
                16'h0000:RDDATA<=AXIS1_MechanicalPosition[31:16];
                16'h0001:RDDATA<=AXIS1_MechanicalPosition_LowHalfLock;
                16'h0002:RDDATA<=AXIS1_TransCoeff[31:16];
                16'h0003:RDDATA<=AXIS1_TransCoeff[15:0];
                16'h0004:RDDATA<=AXIS1_ZeroSet;
                16'h0005:RDDATA<=AXIS1_Etheta;
                16'h0006:RDDATA<=AXIS1_InvTransAngleComp;
                16'h0007:RDDATA<=AXIS1_Status;
                16'h0008:RDDATA<=AXIS1_VirtualTheta;
                16'h0009:RDDATA<=AXIS1_CtrlReg;
                16'h000A:RDDATA<=AXIS1_ENCCRCERRCNT;
                16'h000B:RDDATA<=AXIS1_ENCNoResponseCNT;
                16'h000C:RDDATA<={AXIS1_CalibrationEN,11'd0,AXIS1_CalibrationState};
                
                16'h0020:RDDATA<=AXIS2_MechanicalPosition[31:16];
                16'h0021:RDDATA<=AXIS2_MechanicalPosition_LowHalfLock;
                16'h0022:RDDATA<=AXIS2_TransCoeff[31:16];
                16'h0023:RDDATA<=AXIS2_TransCoeff[15:0];
                16'h0024:RDDATA<=AXIS2_ZeroSet;
                16'h0025:RDDATA<=AXIS2_Etheta;
                16'h0026:RDDATA<=AXIS2_InvTransAngleComp;
                16'h0027:RDDATA<=AXIS2_Status;
                16'h0028:RDDATA<=AXIS2_VirtualTheta;
                16'h0029:RDDATA<=AXIS2_CtrlReg;
                16'h002A:RDDATA<=AXIS2_ENCCRCERRCNT;
                16'h002B:RDDATA<=AXIS2_ENCNoResponseCNT;
                16'h002C:RDDATA<={AXIS2_CalibrationEN,11'd0,AXIS2_CalibrationState};
                
                16'h0040:RDDATA<=AXIS3_MechanicalPosition[31:16];
                16'h0041:RDDATA<=AXIS3_MechanicalPosition_LowHalfLock;
                16'h0042:RDDATA<=AXIS3_TransCoeff[31:16];
                16'h0043:RDDATA<=AXIS3_TransCoeff[15:0];
                16'h0044:RDDATA<=AXIS3_ZeroSet;
                16'h0045:RDDATA<=AXIS3_Etheta;
                16'h0046:RDDATA<=AXIS3_InvTransAngleComp;
                16'h0047:RDDATA<=AXIS3_Status;
                16'h0048:RDDATA<=AXIS3_VirtualTheta;
                16'h0049:RDDATA<=AXIS3_CtrlReg;
                16'h004A:RDDATA<=AXIS3_ENCCRCERRCNT;
                16'h004B:RDDATA<=AXIS3_ENCNoResponseCNT;
                16'h004C:RDDATA<={AXIS3_CalibrationEN,11'd0,AXIS3_CalibrationState};

                16'h0060:RDDATA<=AXIS4_MechanicalPosition[31:16];
                16'h0061:RDDATA<=AXIS4_MechanicalPosition_LowHalfLock;
                16'h0062:RDDATA<=AXIS4_TransCoeff[31:16];
                16'h0063:RDDATA<=AXIS4_TransCoeff[15:0];
                16'h0064:RDDATA<=AXIS4_ZeroSet;
                16'h0065:RDDATA<=AXIS4_Etheta;
                16'h0066:RDDATA<=AXIS4_InvTransAngleComp;
                16'h0067:RDDATA<=AXIS4_Status;
                16'h0068:RDDATA<=AXIS4_VirtualTheta;
                16'h0069:RDDATA<=AXIS4_CtrlReg;    
                16'h006A:RDDATA<=AXIS4_ENCCRCERRCNT;
                16'h006B:RDDATA<=AXIS4_ENCNoResponseCNT;
                16'h006C:RDDATA<={AXIS4_CalibrationEN,11'd0,AXIS4_CalibrationState};                

                default:RDDATA<=16'd0;
                endcase
            end
        end
    end 
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            AXIS1_MechanicalPosition_LowHalfLock<=16'd0;
            AXIS2_MechanicalPosition_LowHalfLock<=16'd0;
            AXIS3_MechanicalPosition_LowHalfLock<=16'd0;
            AXIS4_MechanicalPosition_LowHalfLock<=16'd0;
        end
        else begin
            if(RD==1'b1)begin
                case(ADDR) 
                16'h0000:AXIS1_MechanicalPosition_LowHalfLock<=AXIS1_MechanicalPosition[15:0];
                16'h0020:AXIS2_MechanicalPosition_LowHalfLock<=AXIS2_MechanicalPosition[15:0];
                16'h0040:AXIS3_MechanicalPosition_LowHalfLock<=AXIS3_MechanicalPosition[15:0];
                16'h0060:AXIS4_MechanicalPosition_LowHalfLock<=AXIS4_MechanicalPosition[15:0];
                endcase
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            AXIS1_VirtualTheta_UpdatePluse<=1'b0;
            AXIS2_VirtualTheta_UpdatePluse<=1'b0;
            AXIS3_VirtualTheta_UpdatePluse<=1'b0;
            AXIS4_VirtualTheta_UpdatePluse<=1'b0;
        end
        else begin
            AXIS1_VirtualTheta_UpdatePluse<=((WR==1'b1)&&(ADDR==16'h0008));
            AXIS2_VirtualTheta_UpdatePluse<=((WR==1'b1)&&(ADDR==16'h0028));
            AXIS3_VirtualTheta_UpdatePluse<=((WR==1'b1)&&(ADDR==16'h0048));
            AXIS4_VirtualTheta_UpdatePluse<=((WR==1'b1)&&(ADDR==16'h0068));
        end
    end
    
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            AXIS1_ENCCRCERRCNT<=16'd0;
            AXIS1_ENCNoResponseCNT<=16'd0;
            
            AXIS2_ENCCRCERRCNT<=16'd0;
            AXIS2_ENCNoResponseCNT<=16'd0;
            
            AXIS3_ENCCRCERRCNT<=16'd0;
            AXIS3_ENCNoResponseCNT<=16'd0;
            
            AXIS4_ENCCRCERRCNT<=16'd0;
            AXIS4_ENCNoResponseCNT<=16'd0;
        end
        else begin
            if((WR==1'b1)&&(ADDR==16'h000A)&&(WRDATA==16'h005A))
                AXIS1_ENCCRCERRCNT<=16'd0;
            else begin
                if(AXIS1_ENCCRCERRPluse)
                    AXIS1_ENCCRCERRCNT<=AXIS1_ENCCRCERRCNT+1'b1;
            end
            if((WR==1'b1)&&(ADDR==16'h000B)&&(WRDATA==16'h005A))
                AXIS1_ENCNoResponseCNT<=16'd0;
            else begin
                if(AXIS1_ENCNoResponsPluse)
                    AXIS1_ENCNoResponseCNT<=AXIS1_ENCNoResponseCNT+1'b1;
            end
            
            
            if((WR==1'b1)&&(ADDR==16'h002A)&&(WRDATA==16'h005A))
                AXIS2_ENCCRCERRCNT<=16'd0;
            else begin
                if(AXIS2_ENCCRCERRPluse)
                    AXIS2_ENCCRCERRCNT<=AXIS2_ENCCRCERRCNT+1'b1;
            end
            if((WR==1'b1)&&(ADDR==16'h002B)&&(WRDATA==16'h005A))
                AXIS2_ENCNoResponseCNT<=16'd0;
            else begin
                if(AXIS2_ENCNoResponsPluse)
                    AXIS2_ENCNoResponseCNT<=AXIS2_ENCNoResponseCNT+1'b1;
            end
            
            
            if((WR==1'b1)&&(ADDR==16'h004A)&&(WRDATA==16'h005A))
                AXIS3_ENCCRCERRCNT<=16'd0;
            else begin
                if(AXIS3_ENCCRCERRPluse)
                    AXIS3_ENCCRCERRCNT<=AXIS3_ENCCRCERRCNT+1'b1;
            end
            if((WR==1'b1)&&(ADDR==16'h004B)&&(WRDATA==16'h005A))
                AXIS3_ENCNoResponseCNT<=16'd0;
            else begin
                if(AXIS3_ENCNoResponsPluse)
                    AXIS3_ENCNoResponseCNT<=AXIS3_ENCNoResponseCNT+1'b1;
            end
            
            
            if((WR==1'b1)&&(ADDR==16'h006A)&&(WRDATA==16'h005A))
                AXIS4_ENCCRCERRCNT<=16'd0;
            else begin
                if(AXIS4_ENCCRCERRPluse)
                    AXIS4_ENCCRCERRCNT<=AXIS4_ENCCRCERRCNT+1'b1;
            end
            if((WR==1'b1)&&(ADDR==16'h006B)&&(WRDATA==16'h005A))
                AXIS4_ENCNoResponseCNT<=16'd0;
            else begin
                if(AXIS4_ENCNoResponsPluse)
                    AXIS4_ENCNoResponseCNT<=AXIS4_ENCNoResponseCNT+1'b1;
            end
        end
    end
    

    
endmodule
