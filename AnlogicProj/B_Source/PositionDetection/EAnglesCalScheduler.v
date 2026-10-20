module EAnglesCalScheduler(
    input                       clk,//20Mhz
    input                       rst,
    //==Encoder driver input
    input                       RequestTrig,
    input                       TimeCriticalPluse,
    input       [31:0]          AXIS1_MechanicalPosition,
    input                       AXIS1_DataValid,
    input       [31:0]          AXIS2_MechanicalPosition,
    input                       AXIS2_DataValid,
    input       [31:0]          AXIS3_MechanicalPosition,
    input                       AXIS3_DataValid,
    input       [31:0]          AXIS4_MechanicalPosition,
    input                       AXIS4_DataValid,
    //==paras
    input       [31:0]          AXIS1_TransCoeff,
    input       [15:0]          AXIS1_ZeroSet,
    input       [15:0]          AXIS1_InvTransAngleComp,
    input                       AXIS1_Polarity,
    input       [31:0]          AXIS2_TransCoeff,
    input       [15:0]          AXIS2_ZeroSet,
    input       [15:0]          AXIS2_InvTransAngleComp,
    input                       AXIS2_Polarity,
    input       [31:0]          AXIS3_TransCoeff,
    input       [15:0]          AXIS3_ZeroSet,
    input       [15:0]          AXIS3_InvTransAngleComp,
    input                       AXIS3_Polarity,
    input       [31:0]          AXIS4_TransCoeff,
    input       [15:0]          AXIS4_ZeroSet,
    input       [15:0]          AXIS4_InvTransAngleComp,
    input                       AXIS4_Polarity,
    //==VirtualTheta input
    input       [15:0]          AXIS1_VirtualTheta, 
    input                       AXIS1_VirtualTheta_UpdatePluse,
    input                       AXIS1_VirtualThetaEnable,
    input       [15:0]          AXIS2_VirtualTheta, 
    input                       AXIS2_VirtualTheta_UpdatePluse,
    input                       AXIS2_VirtualThetaEnable,
    input       [15:0]          AXIS3_VirtualTheta, 
    input                       AXIS3_VirtualTheta_UpdatePluse,
    input                       AXIS3_VirtualThetaEnable,
    input       [15:0]          AXIS4_VirtualTheta, 
    input                       AXIS4_VirtualTheta_UpdatePluse,
    input                       AXIS4_VirtualThetaEnable,
    //==output
    output  reg [15:0]          AXIS1_Etheta,
    output  reg [15:0]          AXIS1_COSVal,
    output  reg [15:0]          AXIS1_SINVal,
    output  reg [15:0]          AXIS1_InvCOSVal,
    output  reg [15:0]          AXIS1_InvSINVal,
    output  reg                 AXIS1_CALOvertime,
    output  reg [15:0]          AXIS2_Etheta,
    output  reg [15:0]          AXIS2_COSVal,
    output  reg [15:0]          AXIS2_SINVal,
    output  reg [15:0]          AXIS2_InvCOSVal,
    output  reg [15:0]          AXIS2_InvSINVal,
    output  reg                 AXIS2_CALOvertime,
    output  reg [15:0]          AXIS3_Etheta,
    output  reg [15:0]          AXIS3_COSVal,
    output  reg [15:0]          AXIS3_SINVal,
    output  reg [15:0]          AXIS3_InvCOSVal,
    output  reg [15:0]          AXIS3_InvSINVal,
    output  reg                 AXIS3_CALOvertime,
    output  reg [15:0]          AXIS4_Etheta,
    output  reg [15:0]          AXIS4_COSVal,
    output  reg [15:0]          AXIS4_SINVal,
    output  reg [15:0]          AXIS4_InvCOSVal,
    output  reg [15:0]          AXIS4_InvSINVal,
    output  reg                 AXIS4_CALOvertime
    );

    reg             trig;
    reg     [31:0]  MechanicalPosition;
    reg     [31:0]  TransCoeff;
    reg     [15:0]  ZeroSet;
    reg     [15:0]  InvTransAngleComp;
    reg             Polarity;
    reg     [15:0]  VirtualTheta;
    reg             VirtualThetaEnable;
    
    wire    [15:0]  Etheta;
    wire    [15:0]  COSVal;
    wire    [15:0]  SINVal;
    wire    [15:0]  InvCOSVal;
    wire    [15:0]  InvSINVal;
    wire            finish;
ElectricalAngleDeal ElectricalAngleDeal(
    .clk(clk),
    .rst(rst),
    .trig(trig),
    .MechanicalPosition(MechanicalPosition),
    .TransCoeff(TransCoeff),//32bit,Q16, mechanical postion to electrical angle
    .ZeroSet(ZeroSet),//16bit,Q16
    .InvTransAngleComp(InvTransAngleComp),//16bit,Q16
    .Polarity(Polarity),//0: electrical angle direction same as mechanical 1: inverse
    
    .VirtualTheta(VirtualTheta), 
    .VirtualThetaEnable(VirtualThetaEnable),  
    
    .Etheta(Etheta),
    .COSVal(COSVal),
    .SINVal(SINVal),
    .InvCOSVal(InvCOSVal),
    .InvSINVal(InvSINVal),
    .finish(finish)
    );
    
    wire    AXIS1_DataValidSel;
    wire    AXIS2_DataValidSel;
    wire    AXIS3_DataValidSel;
    wire    AXIS4_DataValidSel;
    assign AXIS1_DataValidSel = AXIS1_VirtualThetaEnable?AXIS1_VirtualTheta_UpdatePluse:AXIS1_DataValid;
    assign AXIS2_DataValidSel = AXIS2_VirtualThetaEnable?AXIS2_VirtualTheta_UpdatePluse:AXIS2_DataValid;
    assign AXIS3_DataValidSel = AXIS3_VirtualThetaEnable?AXIS3_VirtualTheta_UpdatePluse:AXIS3_DataValid;
    assign AXIS4_DataValidSel = AXIS4_VirtualThetaEnable?AXIS4_VirtualTheta_UpdatePluse:AXIS4_DataValid;
    
    
    reg     [3:0]   DataValidRec;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DataValidRec<=4'd0;
        end
        else begin
            if(RequestTrig)begin
                DataValidRec<=4'd0;
            end
            else begin
                if(AXIS1_DataValidSel)
                    DataValidRec[0]<=1'b1;
                if(AXIS2_DataValidSel)
                    DataValidRec[1]<=1'b1;
                if(AXIS3_DataValidSel)
                    DataValidRec[2]<=1'b1;
                if(AXIS4_DataValidSel)
                    DataValidRec[3]<=1'b1;   
            end
        end
    end
    
    wire    [3:0]   ValidNum;
    assign ValidNum = DataValidRec[0] + DataValidRec[1] +
                        DataValidRec[2] + DataValidRec[3];
    
    reg [3:0]   DealCNT;
    reg [3:0]   DealCNT_dly;
    reg         trigflag;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DealCNT<=4'd0;
            DealCNT_dly<=4'd0;
        end
        else begin
            if(RequestTrig)
                DealCNT<=4'd0;
            else begin
                if(trigflag==1'b1)begin
                    if(finish)
                        DealCNT<=DealCNT+1'b1;
                end
                else
                    DealCNT<=DealCNT;
            end
            
            DealCNT_dly<=DealCNT;
        end
    end
    
    wire trig_pre;
    reg  trig_pre1;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            trigflag<=1'b0;
        end
        else begin
            if(DealCNT!=DealCNT_dly)
                trigflag<=1'b0;
            else begin
                if(trig_pre)
                    trigflag<=1'b1;
            end
        end
    end
    
    assign trig_pre = (trigflag==1'b0)&&(DealCNT<ValidNum);
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            trig_pre1<=1'b0;
            trig<=1'b0;
        end
        else begin
            trig_pre1<=trig_pre;
            trig<=trig_pre1;        
        end
    end
    
    
    reg [3:0]   Sel;
    reg [3:0]   DealedRec;
    wire [3:0]  TobeDeal;
    
    assign TobeDeal = DataValidRec & (~DealedRec);
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Sel<=4'd0;
        end
        else begin
            if(trig_pre)begin
                if(TobeDeal[0]==1'b1)
                    Sel<=4'd0;
                else if(TobeDeal[1]==1'b1)
                    Sel<=4'd1;
                else if(TobeDeal[2]==1'b1)
                    Sel<=4'd2;
                else if(TobeDeal[3]==1'b1)
                    Sel<=4'd3; 
                else
                    Sel<=4'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DealedRec<=4'd0;
        end
        else begin
            if(RequestTrig)
                DealedRec<=4'd0;
            else begin
                if(trigflag&&finish)begin
                    case(Sel)
                    4'd0:DealedRec[0]<=1'b1;
                    4'd1:DealedRec[1]<=1'b1;
                    4'd2:DealedRec[2]<=1'b1;
                    4'd3:DealedRec[3]<=1'b1;
                    endcase
                end
            end
        end
    end
    
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            MechanicalPosition<=32'd0;
            TransCoeff<=32'd0;
            ZeroSet<=16'd0;
            InvTransAngleComp<=16'd0;
            Polarity<=1'b0;
            VirtualTheta<=16'd0;
            VirtualThetaEnable<=1'b0;
        end
        else begin
            if(trig_pre1)begin
            case(Sel)
            4'd0:begin
            MechanicalPosition<=AXIS1_MechanicalPosition;
            TransCoeff<=AXIS1_TransCoeff;
            ZeroSet<=AXIS1_ZeroSet;
            InvTransAngleComp<=AXIS1_InvTransAngleComp;
            Polarity<=AXIS1_Polarity;
            VirtualTheta<=AXIS1_VirtualTheta;
            VirtualThetaEnable<=AXIS1_VirtualThetaEnable;
            end
            4'd1:begin
            MechanicalPosition<=AXIS2_MechanicalPosition;
            TransCoeff<=AXIS2_TransCoeff;
            ZeroSet<=AXIS2_ZeroSet;
            InvTransAngleComp<=AXIS2_InvTransAngleComp;
            Polarity<=AXIS2_Polarity;
            VirtualTheta<=AXIS2_VirtualTheta;
            VirtualThetaEnable<=AXIS2_VirtualThetaEnable;
            end
            4'd2:begin
            MechanicalPosition<=AXIS3_MechanicalPosition;
            TransCoeff<=AXIS3_TransCoeff;
            ZeroSet<=AXIS3_ZeroSet;
            InvTransAngleComp<=AXIS3_InvTransAngleComp;
            Polarity<=AXIS3_Polarity;
            VirtualTheta<=AXIS3_VirtualTheta;
            VirtualThetaEnable<=AXIS3_VirtualThetaEnable;
            end
            4'd3:begin
            MechanicalPosition<=AXIS4_MechanicalPosition;
            TransCoeff<=AXIS4_TransCoeff;
            ZeroSet<=AXIS4_ZeroSet;
            InvTransAngleComp<=AXIS4_InvTransAngleComp;
            Polarity<=AXIS4_Polarity;
            VirtualTheta<=AXIS4_VirtualTheta;
            VirtualThetaEnable<=AXIS4_VirtualThetaEnable;
            end
            endcase
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            AXIS1_Etheta<=16'd0;
            AXIS1_COSVal<=16'd0;
            AXIS1_SINVal<=16'd0;
            AXIS1_InvCOSVal<=16'd0;
            AXIS1_InvSINVal<=16'd0;

            AXIS2_Etheta<=16'd0;
            AXIS2_COSVal<=16'd0;
            AXIS2_SINVal<=16'd0;
            AXIS2_InvCOSVal<=16'd0;
            AXIS2_InvSINVal<=16'd0;

            AXIS3_Etheta<=16'd0;
            AXIS3_COSVal<=16'd0;
            AXIS3_SINVal<=16'd0;
            AXIS3_InvCOSVal<=16'd0;
            AXIS3_InvSINVal<=16'd0;

            AXIS4_Etheta<=16'd0;
            AXIS4_COSVal<=16'd0;
            AXIS4_SINVal<=16'd0;
            AXIS4_InvCOSVal<=16'd0;
            AXIS4_InvSINVal<=16'd0;
        end
        else begin
            if(finish)begin
                case(Sel)
                4'd0:begin
                AXIS1_Etheta<=Etheta;
                AXIS1_COSVal<=COSVal;
                AXIS1_SINVal<=SINVal;
                AXIS1_InvCOSVal<=InvCOSVal;
                AXIS1_InvSINVal<=InvSINVal;
                end
                4'd1:begin
                AXIS2_Etheta<=Etheta;
                AXIS2_COSVal<=COSVal;
                AXIS2_SINVal<=SINVal;
                AXIS2_InvCOSVal<=InvCOSVal;
                AXIS2_InvSINVal<=InvSINVal;
                end
                4'd2:begin
                AXIS3_Etheta<=Etheta;
                AXIS3_COSVal<=COSVal;
                AXIS3_SINVal<=SINVal;
                AXIS3_InvCOSVal<=InvCOSVal;
                AXIS3_InvSINVal<=InvSINVal;
                end
                4'd3:begin
                AXIS4_Etheta<=Etheta;
                AXIS4_COSVal<=COSVal;
                AXIS4_SINVal<=SINVal;
                AXIS4_InvCOSVal<=InvCOSVal;
                AXIS4_InvSINVal<=InvSINVal;
                end
                endcase
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            AXIS1_CALOvertime <= 1'b0;
            AXIS2_CALOvertime <= 1'b0;
            AXIS3_CALOvertime <= 1'b0;
            AXIS4_CALOvertime <= 1'b0;
        end
        else begin
            AXIS1_CALOvertime <= AXIS1_DataValidSel?1'b0:(TimeCriticalPluse && (DealedRec[0]==1'b0));
            AXIS2_CALOvertime <= AXIS2_DataValidSel?1'b0:(TimeCriticalPluse && (DealedRec[1]==1'b0));
            AXIS3_CALOvertime <= AXIS3_DataValidSel?1'b0:(TimeCriticalPluse && (DealedRec[2]==1'b0));
            AXIS4_CALOvertime <= AXIS4_DataValidSel?1'b0:(TimeCriticalPluse && (DealedRec[3]==1'b0));
        end
    end    

    
        
    
endmodule

