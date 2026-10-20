/*
VectorCtrler VectorCtrler_inst(    
    .clk(),
    .rst(),
    .trig(),
    .busy(),
    .finish(),
    .DKp(),
    .DKi(),
    .DCompensate(),
    .QKp(),
    .QKi(),
    .QCompensate(),   
    .LimitCircleRadiusHW(), 
    .LimitCircleRadius(),
    .LimitMode_HDLQ(),
    .DRef(),
    .DFeedback(),
    .DUiAcc(),
    .QRef(),
    .QFeedback(),
    .QUiAcc(),
    .SINval(),
    .COSval(),
    .DUiAcc_new(),
    .QUiAcc_new(),
    .UD(),
    .UQ(),
    .UALPHA(),
    .UBETA()
    ); 
*/
module VectorCtrler(    
    input                       clk,
    input                       rst,
    input                       trig,//input pluse, active high
    output                      busy,//output level, active high
    output  reg                 finish,//output pluse, active high
    //paras
    input       signed  [31:0]  DKp,//D axis Kp,32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [31:0]  DKi,//D axis Ki,32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [15:0]  DCompensate,//D axis DCompensate,16bit,Q15, pu , base = Ubase,(-1,1)
    
    input       signed  [31:0]  QKp,//Q axis Kp,32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [31:0]  QKi,//Q axis Ki,32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [15:0]  QCompensate,//Q axis DCompensate,16bit,Q15, pu , base = Ubase,(-1,1)    
    //hardware LimitCircleRadius
    input       signed  [15:0]  LimitCircleRadiusHW,//Voltage Circle limit,limit from SVPWM,16bit,Q15, pu , base = Ubase,(-1,1) 
    //user input & output
    input       signed  [15:0]  LimitCircleRadius,//Voltage Circle limit,limit from user, 16bit,Q15, pu , base = Ubase,(-1,1)    
    input                       LimitMode_HDLQ,//Limit Mode, 1:Limit D aixs output,Q axis cal first; 0:limit Q axis mode,D axis cal first
    
    input       signed  [15:0]  DRef,//D axis reference,16bit,Q15, pu , base = Ibase,(-1,1)
    input       signed  [15:0]  DFeedback,//D axis feedback,16bit,Q15, pu , base = Ibase,(-1,1)
    input       signed  [31:0]  DUiAcc,//D axis intergral part
    input       signed  [15:0]  QRef,//Q axis reference,16bit,Q15, pu , base = Ibase,(-1,1)
    input       signed  [15:0]  QFeedback,//Q axis feedback,16bit,Q15, pu , base = Ibase,(-1,1)
    input       signed  [31:0]  QUiAcc,//D axis intergral part
    
    input       signed  [15:0]  SINval,//IPARK sin value,range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  COSval,//IPARK cos value,range(-1,1), Base 1, 16bit Q15 signed
    
    output  reg signed  [31:0]  DUiAcc_new,//D axis intergral part output
    output  reg signed  [31:0]  QUiAcc_new,//Q axis intergral part output
    output  reg signed  [15:0]  UD,//output D axis voltage, 16bit,Q15, pu , base = Ubase,(-1,1)  
    output  reg signed  [15:0]  UQ,//output Q axis voltage, 16bit,Q15, pu , base = Ubase,(-1,1)  
    output  reg signed  [15:0]  UALPHA,//output Alpha axis voltage,16bit,Q15, pu , base = Ubase,(-1,1)  
    output  reg signed  [15:0]  UBETA//output Beta axis voltage,16bit,Q15, pu , base = Ubase,(-1,1)
    );    
    
    localparam  Idel            =   8'd0;
    localparam  FirstPICAL      =   8'd1;
    localparam  CircleLimitPRE  =   8'd2;
    localparam  CircleLimitCAL  =   8'd3;
    localparam  SecondPICAL     =   8'd4;
    localparam  SecondPICAL_NOP =   8'd5;
    localparam  IPARKCAL_Ualpha =   8'd6;
    localparam  IPARKCAL_Ubeta  =   8'd7;
    localparam  Calfinish       =   8'd8;
    
    reg             [7:0]   CalCNT;
    reg             [7:0]   CalCNT_dly;
    
    wire    signed  [15:0]  LimitCircleRadius_Act;
    wire    signed  [15:0]  LimitCircleRadius_SecondAct;
    
    wire                    PI_trig;
    wire                    PI_finish;
    reg     signed  [31:0]  Kp;
    reg     signed  [31:0]  Ki;
    reg     signed  [15:0]  Compensate;
    reg     signed  [15:0]  Limit;
    reg     signed  [15:0]  reference;
    reg     signed  [15:0]  feedback;
    reg     signed  [31:0]  UiAcc;
    wire    signed  [31:0]  UiAcc_new;
    wire    signed  [15:0]  PIResult;    
    
    reg     signed  [15:0]  MultA1;
    reg     signed  [15:0]  MultB1;
    wire    signed  [31:0]  MultResult1;
    reg     signed  [15:0]  MultA2;
    reg     signed  [15:0]  MultB2;
    wire    signed  [31:0]  MultResult2;    
    
    reg     signed  [31:0]  SquareDiff;
    
    wire                    Sqrt32_trig;
    wire                    Sqrt32_finish;
    
    wire    signed  [15:0]  MultResult1_c;
    wire    signed  [15:0]  MultResult2_c;
    
    
PICtrler PICtrler_inst(    
    .clk(clk),
    .rst(rst),
    .trig(PI_trig),
    .busy(),
    .finish(PI_finish),
    .Kp(Kp),
    .Ki(Ki),
    .Compensate(Compensate),
    .Limit(Limit),
    .reference(reference),
    .feedback(feedback),
    .UiAcc(UiAcc),
    .UiAcc_new(UiAcc_new),
    .PIResult(PIResult)
    );
    
HW_MULT_S1616 mult0(
    .MultA(MultA1),
    .MultB(MultB1),
    .Result(MultResult1)
    );
    
HW_MULT_S1616 mult1(
    .MultA(MultA2),
    .MultB(MultB2),
    .Result(MultResult2)
    );      
    
Sqrt32 Sqrt32_inst(
    .clk(clk),
    .rst(rst),
    .trig(Sqrt32_trig),
    .busy(),
    .finish(Sqrt32_finish),
    .DataIn(SquareDiff),
    .Result(LimitCircleRadius_SecondAct)
    );
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CalCNT<=Idel;
        end
        else begin
            case(CalCNT)
            Idel:begin
                if(trig==1'b1)
                    CalCNT<=FirstPICAL;
                else
                    CalCNT<=Idel;
            end
            FirstPICAL:begin
                if(PI_finish==1'b1)
                    CalCNT<=CircleLimitPRE;
                else
                    CalCNT<=FirstPICAL;
            end
            CircleLimitPRE:CalCNT<=CircleLimitCAL;
            CircleLimitCAL:begin
                if(Sqrt32_finish==1'b1)
                    CalCNT<=SecondPICAL;
                else
                    CalCNT<=CircleLimitCAL;
            end
            SecondPICAL:begin
                if(PI_finish==1'b1)
                    CalCNT<=SecondPICAL_NOP;
                else
                    CalCNT<=SecondPICAL;
            end
            SecondPICAL_NOP:
                CalCNT<=IPARKCAL_Ualpha;
            IPARKCAL_Ualpha:
                CalCNT<=IPARKCAL_Ubeta;
            IPARKCAL_Ubeta:
                CalCNT<=Calfinish;
            Calfinish:
                CalCNT<=Idel;
            default:CalCNT<=Idel;
            endcase
        end
    end
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CalCNT_dly<=Idel;
        end
        else begin
            CalCNT_dly<=CalCNT;
        end
    end
    
    
    assign LimitCircleRadius_Act = 
        (LimitCircleRadius<LimitCircleRadiusHW)?LimitCircleRadius:LimitCircleRadiusHW;
        
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Kp<=32'd0;
            Ki<=32'd0;
            Compensate<=16'd0;
            Limit<=16'd0;
            reference<=16'd0;
            feedback<=16'd0;
            UiAcc<=32'd0;
        end
        else begin
            if(CalCNT==Idel)begin
                if(trig==1'b1)begin
                    if(LimitMode_HDLQ==1'b0)begin
                        Kp<=DKp;
                        Ki<=DKi;
                        Compensate<=DCompensate;
                        Limit<=LimitCircleRadius_Act;
                        reference<=DRef;
                        feedback<=DFeedback;
                        UiAcc<=DUiAcc;
                    end
                    else begin
                        Kp<=QKp;
                        Ki<=QKi;
                        Compensate<=QCompensate;
                        Limit<=LimitCircleRadius_Act;
                        reference<=QRef;
                        feedback<=QFeedback;
                        UiAcc<=QUiAcc;
                    end
                end
            end
            else if(CalCNT==CircleLimitCAL)begin
                if(Sqrt32_finish==1'b1)begin
                    if(LimitMode_HDLQ==1'b1)begin
                        Kp<=DKp;
                        Ki<=DKi;
                        Compensate<=DCompensate;
                        Limit<=LimitCircleRadius_SecondAct;
                        reference<=DRef;
                        feedback<=DFeedback;
                        UiAcc<=DUiAcc;
                    end
                    else begin
                        Kp<=QKp;
                        Ki<=QKi;
                        Compensate<=QCompensate;
                        Limit<=LimitCircleRadius_SecondAct;
                        reference<=QRef;
                        feedback<=QFeedback;
                        UiAcc<=QUiAcc;
                    end
                end
            end
        end
    end
    
    assign PI_trig = ((CalCNT_dly==Idel)&&(CalCNT==FirstPICAL))||
                     ((CalCNT_dly==CircleLimitCAL)&&(CalCNT==SecondPICAL));
                     
    assign Sqrt32_trig = (CalCNT_dly==CircleLimitPRE)&&(CalCNT==CircleLimitCAL);
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            MultA1<=16'd0;
            MultB1<=16'd0;
            MultA2<=16'd0;
            MultB2<=16'd0;
        end
        else begin
            if(CalCNT==FirstPICAL)begin
                if(PI_finish)begin
                    MultA1<=LimitCircleRadius_Act;
                    MultB1<=LimitCircleRadius_Act;
                    MultA2<=PIResult;
                    MultB2<=PIResult;
                end
            end
            else if(CalCNT==SecondPICAL_NOP)begin
                MultA1<=COSval;
                MultB1<=UD;
                MultA2<=SINval;
                MultB2<=UQ;
            end
            else if(CalCNT==IPARKCAL_Ualpha)begin
                MultA1<=COSval;
                MultB1<=UQ;
                MultA2<=SINval;
                MultB2<=UD;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            SquareDiff<=32'd0;
        end
        else begin
            if(CalCNT==CircleLimitPRE)begin
                SquareDiff<= MultResult1 - MultResult2;
            end
        end
    end

    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DUiAcc_new<=32'd0;
            QUiAcc_new<=32'd0;
            UD<=16'd0;
            UQ=16'd0;
        end
        else begin
            if(LimitMode_HDLQ==1'b0)begin//Limit Q
                if(CalCNT==FirstPICAL)begin
                    if(PI_finish==1'b1)begin
                        DUiAcc_new<=UiAcc_new;
                        UD<=PIResult;
                    end
                end
                
                if(CalCNT==SecondPICAL)begin
                    if(PI_finish==1'b1)begin
                        QUiAcc_new<=UiAcc_new;
                        UQ<=PIResult;
                    end
                end                
            end
            else begin//limit D
                if(CalCNT==FirstPICAL)begin
                    if(PI_finish==1'b1)begin
                        QUiAcc_new<=UiAcc_new;
                        UQ<=PIResult;                        
                    end
                end
                
                if(CalCNT==SecondPICAL)begin
                    if(PI_finish==1'b1)begin
                        DUiAcc_new<=UiAcc_new;
                        UD<=PIResult;                    
                    end
                end  
            end
        end
    end
    
    assign MultResult1_c = MultResult1[30:15];
    assign MultResult2_c = MultResult2[30:15];
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            UALPHA<=16'd0;
            UBETA=16'd0;
        end
        else begin
            if(CalCNT==IPARKCAL_Ualpha)begin
                UALPHA<=MultResult1_c-MultResult2_c;
            end
            if(CalCNT==IPARKCAL_Ubeta)begin
                UBETA<=MultResult1_c+MultResult2_c;
            end            
        end
    end
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            finish<=1'b0;
        end
        else begin
            finish<=(CalCNT==Calfinish);
        end
    end
    
    assign busy   = trig || (CalCNT!=Idel);
    
endmodule         



























