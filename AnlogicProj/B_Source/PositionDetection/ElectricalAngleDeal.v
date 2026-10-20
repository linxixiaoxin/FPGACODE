module ElectricalAngleDeal(
    input                       clk,
    input                       rst,
    
    input                       trig,
    input       [31:0]          MechanicalPosition,
    input       [31:0]          TransCoeff,//32bit,Q16, mechanical postion to electrical angle
    input       [15:0]          ZeroSet,//16bit,Q16
    input       [15:0]          InvTransAngleComp,//16bit,Q16
    input                       Polarity,//0: electrical angle direction same as mechanical 1: inverse
    
    input       [15:0]          VirtualTheta, 
    input                       VirtualThetaEnable,                    
    
    output  reg [15:0]          Etheta,
    output  reg [15:0]          COSVal,
    output  reg [15:0]          SINVal,
    output  reg [15:0]          InvCOSVal,
    output  reg [15:0]          InvSINVal,
    output                      finish
    );
    reg     [15:0]  ThetaIn;
    wire    [15:0]  COS;
    wire    [15:0]  SIN;
    wire            caltrig;
    wire            calfinish;
SinCosCal SinCosCal_inst(
    .clk(clk),
    .rst(rst),
    .trig(caltrig),
    .busy(),
    .finish(calfinish),

    .ThetaIn(ThetaIn),
    .SINval(SIN),
    .COSval(COS)
    );
    
    localparam  Idel            = 4'd0;
    localparam  GetTransedAngle = 4'd1;
    localparam  PolarityZeroSet = 4'd2;
    localparam  Angle1Input     = 4'd3;
    localparam  Angle1Cal       = 4'd4;
    localparam  Angle2Input     = 4'd5;
    localparam  Angle2Cal       = 4'd6;
    localparam  AllCalFinish    = 4'd7;
    
    reg     [3:0]   CNT;
    reg     [3:0]   CNT_dly;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            CNT<=4'd0;
        else begin
            case(CNT)
            Idel:begin
                if(trig)
                    CNT<=GetTransedAngle;
                else
                    CNT<=Idel;
            end
            GetTransedAngle:CNT<=PolarityZeroSet;
            PolarityZeroSet:CNT<=Angle1Input;
            Angle1Input:CNT<=Angle1Cal;
            Angle1Cal:begin
                if(calfinish)
                    CNT<=Angle2Input;
                else
                    CNT<=Angle1Cal;
            end
            Angle2Input:CNT<=Angle2Cal;
            Angle2Cal:begin
                if(calfinish)
                    CNT<=AllCalFinish;
                else
                    CNT<=Angle2Cal;
            end
            AllCalFinish:CNT<=Idel;
            default:CNT<=Idel;
            endcase
        end
    end
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            CNT_dly<=4'd0;
        else
            CNT_dly<=CNT;
    end
    
    wire    [63:0]  Result;
HW_MULT_U3232 HW_MULT_U3232(         
    .MultA(MechanicalPosition),//32bit Q0
    .MultB(TransCoeff),//32bit Q16
    .Result(Result)//64bit Q16
    );
    
    reg     [15:0]  Etheta_pre;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            Etheta_pre<=16'd0;
        else begin
            if(CNT==GetTransedAngle)
                Etheta_pre<=Result[31:16];
        end
    end

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            Etheta<=16'd0;
        else begin
            if(CNT==PolarityZeroSet)begin
                if(VirtualThetaEnable==1'b1)
                    Etheta<=VirtualTheta;
                else begin
                    if(Polarity==1'b0)
                        Etheta <= Etheta_pre - ZeroSet;
                    else
                        Etheta <= ZeroSet - Etheta_pre;
                end
            end
        end
    end
    
    wire    [15:0]  Etheta_Comp;
    assign Etheta_Comp = Etheta + InvTransAngleComp;
    

    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            ThetaIn<=16'd0;
        else begin
            if(CNT==Angle1Input)
                ThetaIn<=Etheta;
            else if(CNT==Angle2Input)
                ThetaIn<=Etheta_Comp;
        end
    end
    assign caltrig = ((CNT_dly==Angle1Input)&&(CNT==Angle1Cal))||
                        ((CNT_dly==Angle2Input)&&(CNT==Angle2Cal));
                        
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            COSVal<=16'd0;
            SINVal<=16'd0;
            InvCOSVal<=16'd0;
            InvSINVal<=16'd0;
        end
        else begin
            if(CNT==Angle1Cal)begin
                if(calfinish)begin
                    COSVal<=COS;
                    SINVal<=SIN;
                end
            end
            else if(CNT==Angle2Cal)begin
                if(calfinish)begin
                    InvCOSVal<=COS;
                    InvSINVal<=SIN;
                end
            end
        end
    end
    
    assign finish = (CNT==AllCalFinish);
    
endmodule

