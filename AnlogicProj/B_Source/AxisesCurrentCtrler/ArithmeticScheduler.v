module ArithmeticScheduler(    
    input                       clk,
    input                       rst,
    input                       trig,
    output  reg                 finish,   
    output  reg         [3:0]   Axises_CurrentCtrlFinsih,
    //MotorCurrentCtrler interface==========================================================
    //inner input data
    input               [15:0]  Axis1_IU,//16bit 
    input               [15:0]  Axis1_IV,//16bit
    input               [15:0]  Axis1_SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis1_COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis1_ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis1_ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    input               [15:0]  Axis2_IU,//16bit 
    input               [15:0]  Axis2_IV,//16bit
    input               [15:0]  Axis2_SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis2_COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis2_ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis2_ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    input               [15:0]  Axis3_IU,//16bit 
    input               [15:0]  Axis3_IV,//16bit
    input               [15:0]  Axis3_SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis3_COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis3_ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis3_ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    input               [15:0]  Axis4_IU,//16bit 
    input               [15:0]  Axis4_IV,//16bit
    input               [15:0]  Axis4_SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis4_COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis4_ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input               [15:0]  Axis4_ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed    
    
    input               [31:0]  Axis1_DUiAcc,
    input               [31:0]  Axis1_QUiAcc,
    input               [31:0]  Axis2_DUiAcc,
    input               [31:0]  Axis2_QUiAcc,
    input               [31:0]  Axis3_DUiAcc,
    input               [31:0]  Axis3_QUiAcc,
    input               [31:0]  Axis4_DUiAcc,
    input               [31:0]  Axis4_QUiAcc,    
    //paras input
    input               [15:0]  Axis1_DRef,
    input               [31:0]  Axis1_DKp,
    input               [31:0]  Axis1_DKi,
    input               [15:0]  Axis1_DCompensate,
    input               [15:0]  Axis1_QRef,
    input               [31:0]  Axis1_QKp,
    input               [31:0]  Axis1_QKi,
    input               [15:0]  Axis1_QCompensate,
    input               [15:0]  Axis1_LimitCircleRadius,
    input                       Axis1_LimitMode_HDLQ,
    
    input               [15:0]  Axis2_DRef,
    input               [31:0]  Axis2_DKp,
    input               [31:0]  Axis2_DKi,
    input               [15:0]  Axis2_DCompensate,
    input               [15:0]  Axis2_QRef,
    input               [31:0]  Axis2_QKp,
    input               [31:0]  Axis2_QKi,
    input               [15:0]  Axis2_QCompensate,
    input               [15:0]  Axis2_LimitCircleRadius,
    input                       Axis2_LimitMode_HDLQ,

    input               [15:0]  Axis3_DRef,
    input               [31:0]  Axis3_DKp,
    input               [31:0]  Axis3_DKi,
    input               [15:0]  Axis3_DCompensate,
    input               [15:0]  Axis3_QRef,
    input               [31:0]  Axis3_QKp,
    input               [31:0]  Axis3_QKi,
    input               [15:0]  Axis3_QCompensate,
    input               [15:0]  Axis3_LimitCircleRadius,
    input                       Axis3_LimitMode_HDLQ,

    input               [15:0]  Axis4_DRef,
    input               [31:0]  Axis4_DKp,
    input               [31:0]  Axis4_DKi,
    input               [15:0]  Axis4_DCompensate,
    input               [15:0]  Axis4_QRef,
    input               [31:0]  Axis4_QKp,
    input               [31:0]  Axis4_QKi,
    input               [15:0]  Axis4_QCompensate,
    input               [15:0]  Axis4_LimitCircleRadius,
    input                       Axis4_LimitMode_HDLQ,
    
    //cal ctrl
    output  reg                 MotorCurrentCtrler_trig,         
    input                       MotorCurrentCtrler_finish,
    
    output  reg         [15:0]  IU_Active,//16bit 
    output  reg         [15:0]  IV_Active,//16bit
    output  reg         [15:0]  SINval_Active,//pu, range(-1,1), Base 1, 16bit Q15 signed
    output  reg         [15:0]  COSval_Active,//pu, range(-1,1), Base 1, 16bit Q15 signed
    output  reg         [15:0]  ISINval_Active,//pu, range(-1,1), Base 1, 16bit Q15 signed
    output  reg         [15:0]  ICOSval_Active,//pu, range(-1,1), Base 1, 16bit Q15 signed

    output  reg         [31:0]  DUiAcc_Active,
    output  reg         [31:0]  QUiAcc_Active,
    
    output  reg         [15:0]  DRef_Active,//D axis reference,16bit,Q15, pu , base = Ibase,(-1,1)
    output  reg         [31:0]  DKp_Active,//D axis Kp,32bit,Q15, pu , base = Ubase/Ibase
    output  reg         [31:0]  DKi_Active,//D axis Ki,32bit,Q15, pu , base = Ubase/Ibase
    output  reg         [15:0]  DCompensate_Active,//D axis DCompensate,16bit,Q15, pu , base = Ubase,(-1,1)
    output  reg         [15:0]  QRef_Active,//Q axis reference,16bit,Q15, pu , base = Ibase,(-1,1)
    output  reg         [31:0]  QKp_Active,//Q axis Kp,32bit,Q15, pu , base = Ubase/Ibase
    output  reg         [31:0]  QKi_Active,//Q axis Ki,32bit,Q15, pu , base = Ubase/Ibase
    output  reg         [15:0]  QCompensate_Active,//Q axis DCompensate,16bit,Q15, pu , base = Ubase,(-1,1)  
    output  reg         [15:0]  LimitCircleRadius_Active,//Voltage Circle limit,limit from user, 16bit,Q15, pu , base = Ubase,(-1,1)    
    output  reg                 LimitMode_HDLQ_Active,//Limit Mode, 1:Limit D aixs output,Q axis cal first, 0:limit Q axis mode,D axis cal first

    input               [15:0]  IALPHA_Active,
    input               [15:0]  IBETA_Active,
    input               [15:0]  ID_Active,
    input               [15:0]  IQ_Active,
    input               [15:0]  UD_Active, 
    input               [15:0]  UQ_Active,
    input               [15:0]  UALPHA_Active, 
    input               [15:0]  UBETA_Active,    
    
    //cal results
    output  reg         [15:0]  Axis1_IALPHA,
    output  reg         [15:0]  Axis1_IBETA,
    output  reg         [15:0]  Axis1_ID,
    output  reg         [15:0]  Axis1_IQ,
    output  reg         [15:0]  Axis1_UD, 
    output  reg         [15:0]  Axis1_UQ,
    output  reg         [15:0]  Axis1_UALPHA, 
    output  reg         [15:0]  Axis1_UBETA,
    
    output  reg         [15:0]  Axis2_IALPHA,
    output  reg         [15:0]  Axis2_IBETA,
    output  reg         [15:0]  Axis2_ID,
    output  reg         [15:0]  Axis2_IQ,  
    output  reg         [15:0]  Axis2_UD, 
    output  reg         [15:0]  Axis2_UQ,
    output  reg         [15:0]  Axis2_UALPHA, 
    output  reg         [15:0]  Axis2_UBETA,    
    
    output  reg         [15:0]  Axis3_IALPHA,
    output  reg         [15:0]  Axis3_IBETA,
    output  reg         [15:0]  Axis3_ID,
    output  reg         [15:0]  Axis3_IQ,  
    output  reg         [15:0]  Axis3_UD, 
    output  reg         [15:0]  Axis3_UQ,
    output  reg         [15:0]  Axis3_UALPHA, 
    output  reg         [15:0]  Axis3_UBETA,

    output  reg         [15:0]  Axis4_IALPHA,
    output  reg         [15:0]  Axis4_IBETA,
    output  reg         [15:0]  Axis4_ID,
    output  reg         [15:0]  Axis4_IQ,  
    output  reg         [15:0]  Axis4_UD, 
    output  reg         [15:0]  Axis4_UQ,
    output  reg         [15:0]  Axis4_UALPHA, 
    output  reg         [15:0]  Axis4_UBETA,

    //SvpwmModulate  interface==========================================================
    input               [3:0]   Axises_CalEN,
    input                       Axis1_SvpwmInputSel,
    input               [15:0]  Axis1_UALPHA_selfdef,
    input               [15:0]  Axis1_UBETA_selfdef, 
    input                       Axis2_SvpwmInputSel,
    input               [15:0]  Axis2_UALPHA_selfdef,
    input               [15:0]  Axis2_UBETA_selfdef, 
    input                       Axis3_SvpwmInputSel,
    input               [15:0]  Axis3_UALPHA_selfdef,
    input               [15:0]  Axis3_UBETA_selfdef, 
    input                       Axis4_SvpwmInputSel,
    input               [15:0]  Axis4_UALPHA_selfdef,
    input               [15:0]  Axis4_UBETA_selfdef,     
    
    output  reg                 SvpwmModulate_trig,         
    input                       SvpwmModulate_finish, 
    output  reg         [15:0]  UALPHA_SV_Active, 
    output  reg         [15:0]  UBETA_SV_Active,
    input               [15:0]  DutyA_Active,//=PhaseA Duty cycle*PreiodCNT
    input               [15:0]  DutyB_Active,//=PhaseB Duty cycle*PreiodCNT
    input               [15:0]  DutyC_Active,//=PhaseC Duty cycle*PreiodCNT 
    output  reg         [15:0]  Axis1_DutyA,//=PhaseA Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis1_DutyB,//=PhaseB Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis1_DutyC,//=PhaseC Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis2_DutyA,//=PhaseA Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis2_DutyB,//=PhaseB Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis2_DutyC,//=PhaseC Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis3_DutyA,//=PhaseA Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis3_DutyB,//=PhaseB Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis3_DutyC,//=PhaseC Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis4_DutyA,//=PhaseA Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis4_DutyB,//=PhaseB Duty cycle*PreiodCNT
    output  reg         [15:0]  Axis4_DutyC//=PhaseC Duty cycle*PreiodCNT
    );    
    
    reg         [3:0]   MotorCurrentCtrler_AxisesCalStep;
    reg         [3:0]   MotorCurrentCtrler_AxisesCalStep_dly;
    reg         [3:0]   SvpwmModulate_AxisesCalStep;
    reg         [3:0]   SvpwmModulate_AxisesCalStep_dly;
    reg         [3:0]   SvpwmModulate_CalFinishCNT;
    wire                MotorCurrentCtrler_DataInputLoad;
    wire                SvpwmModulate_DataInputLoad;
    
    wire                MotorCurrentCtrler_finish_aixs1;
    wire                MotorCurrentCtrler_finish_aixs2;
    wire                MotorCurrentCtrler_finish_aixs3;
    wire                MotorCurrentCtrler_finish_aixs4;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            MotorCurrentCtrler_AxisesCalStep<=4'd0;
            MotorCurrentCtrler_AxisesCalStep_dly<=4'd0;
        end
        else begin
            case(MotorCurrentCtrler_AxisesCalStep)
            4'd0:begin
                if(trig==1'b1)
                    MotorCurrentCtrler_AxisesCalStep<=4'd1;
            end
            4'd1,4'd2,4'd3,4'd4:begin
                if(MotorCurrentCtrler_finish==1'b1)
                    MotorCurrentCtrler_AxisesCalStep<=MotorCurrentCtrler_AxisesCalStep+1'b1;
            end
            4'd5:begin
                if(SvpwmModulate_CalFinishCNT==4'd4)
                    MotorCurrentCtrler_AxisesCalStep<=4'd0;
            end
            default:MotorCurrentCtrler_AxisesCalStep<=4'd0;
            endcase
            MotorCurrentCtrler_AxisesCalStep_dly<=MotorCurrentCtrler_AxisesCalStep;
        end
    end
    
    assign MotorCurrentCtrler_DataInputLoad = ((MotorCurrentCtrler_AxisesCalStep!=MotorCurrentCtrler_AxisesCalStep_dly)&&
                                                (MotorCurrentCtrler_AxisesCalStep>=4'd1)&&
                                                (MotorCurrentCtrler_AxisesCalStep<=4'd4));
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            SvpwmModulate_CalFinishCNT<=4'd0;

        end
        else begin
            if(trig==1'b1)
                SvpwmModulate_CalFinishCNT<=4'd0;
            else begin
                if(SvpwmModulate_finish==1'b1)  
                    SvpwmModulate_CalFinishCNT<=SvpwmModulate_CalFinishCNT+1'b1;
            end
        end
    end    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            SvpwmModulate_AxisesCalStep<=4'd0;
            SvpwmModulate_AxisesCalStep_dly<=4'd0;
        end
        else begin
            case(SvpwmModulate_AxisesCalStep)
            4'd0:begin
                if((MotorCurrentCtrler_AxisesCalStep>=4'd2)&&(SvpwmModulate_CalFinishCNT==4'd0))
                    SvpwmModulate_AxisesCalStep<=4'd1;
            end
            4'd1:begin
                if((MotorCurrentCtrler_AxisesCalStep>=4'd3)&&(SvpwmModulate_CalFinishCNT==4'd1))
                    SvpwmModulate_AxisesCalStep<=4'd2;
            end
            4'd2:begin
                if((MotorCurrentCtrler_AxisesCalStep>=4'd4)&&(SvpwmModulate_CalFinishCNT==4'd2))
                    SvpwmModulate_AxisesCalStep<=4'd3;
            end
            4'd3:begin
                if((MotorCurrentCtrler_AxisesCalStep>=4'd5)&&(SvpwmModulate_CalFinishCNT==4'd3))
                    SvpwmModulate_AxisesCalStep<=4'd4;
            end 
            4'd4:begin
                if(SvpwmModulate_CalFinishCNT==4'd4)
                    SvpwmModulate_AxisesCalStep<=4'd0;
            end            
            default:SvpwmModulate_AxisesCalStep<=4'd0;
            endcase
            SvpwmModulate_AxisesCalStep_dly<=SvpwmModulate_AxisesCalStep;
        end
    end
    
    assign SvpwmModulate_DataInputLoad = ((SvpwmModulate_AxisesCalStep!=SvpwmModulate_AxisesCalStep_dly)&&
                                            (SvpwmModulate_AxisesCalStep>=4'd1)&&
                                            (SvpwmModulate_AxisesCalStep<=4'd4));
    //=============================================================================================
    
    
/*     always @ (*)begin
        IU_Active=Axis2_IU;
        IV_Active=Axis2_IV;
        SINval_Active=Axis2_SINval;
        COSval_Active=Axis2_COSval;
        ISINval_Active=Axis2_ISINval;
        ICOSval_Active=Axis2_ICOSval;
        DUiAcc_Active=Axis2_DUiAcc;
        QUiAcc_Active=Axis2_QUiAcc;
    
        DRef_Active=Axis2_DRef;
        DKp_Active=Axis2_DKp;
        DKi_Active=Axis2_DKi;
        DCompensate_Active=Axis2_DCompensate;
        QRef_Active=Axis2_QRef;
        QKp_Active=Axis2_QKp;
        QKi_Active=Axis2_QKi;
        QCompensate_Active=Axis2_QCompensate;
        LimitCircleRadius_Active=Axis2_LimitCircleRadius;
        LimitMode_HDLQ_Active=Axis2_LimitMode_HDLQ; 
        
        Axis2_IALPHA=IALPHA_Active;
        Axis2_IBETA=IBETA_Active;
        Axis2_ID=ID_Active;
        Axis2_IQ=IQ_Active;
        Axis2_UD=UD_Active;
        Axis2_UQ=UQ_Active;
        Axis2_UALPHA=UALPHA_Active;
        Axis2_UBETA=UBETA_Active;
        
        UALPHA_SV_Active = UALPHA_Active;
        UBETA_SV_Active = UBETA_Active;
        Axis2_DutyA = DutyA_Active;
        Axis2_DutyB = DutyB_Active;
        Axis2_DutyC = DutyC_Active;
        
    end */
    
        reg     MotorCurrentCtrler_trig_pre;
     always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            MotorCurrentCtrler_trig<=1'b0;
            MotorCurrentCtrler_trig_pre<=1'b0;
            SvpwmModulate_trig<=1'b0;
        end
        else begin
            MotorCurrentCtrler_trig_pre<=(MotorCurrentCtrler_DataInputLoad);
            MotorCurrentCtrler_trig<=MotorCurrentCtrler_trig_pre;
            SvpwmModulate_trig<=(SvpwmModulate_DataInputLoad);
        end
    end
    
   always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            IU_Active<=16'd0;
            IV_Active<=16'd0;
            SINval_Active<=16'd0;
            COSval_Active<=16'd0;
            ISINval_Active<=16'd0;
            ICOSval_Active<=16'd0;
            DUiAcc_Active<=32'd0;
            QUiAcc_Active<=32'd0;
        
            DRef_Active<=16'd0;
            DKp_Active<=32'd0;
            DKi_Active<=32'd0;
            DCompensate_Active<=16'd0;
            QRef_Active<=16'd0;
            QKp_Active<=32'd0;
            QKi_Active<=32'd0;
            QCompensate_Active<=16'd0;
            LimitCircleRadius_Active<=16'd0;
            LimitMode_HDLQ_Active<=1'b0;
        end
        else begin
            if(MotorCurrentCtrler_DataInputLoad)begin
                case(MotorCurrentCtrler_AxisesCalStep)
                4'd1:begin
                IU_Active<=Axis1_IU;
                IV_Active<=Axis1_IV;
                SINval_Active<=Axis1_SINval;
                COSval_Active<=Axis1_COSval;
                ISINval_Active<=Axis1_ISINval;
                ICOSval_Active<=Axis1_ICOSval;
                DUiAcc_Active<=Axis1_DUiAcc;
                QUiAcc_Active<=Axis1_QUiAcc;
            
                DRef_Active<=Axis1_DRef;
                DKp_Active<=Axis1_DKp;
                DKi_Active<=Axis1_DKi;
                DCompensate_Active<=Axis1_DCompensate;
                QRef_Active<=Axis1_QRef;
                QKp_Active<=Axis1_QKp;
                QKi_Active<=Axis1_QKi;
                QCompensate_Active<=Axis1_QCompensate;
                LimitCircleRadius_Active<=Axis1_LimitCircleRadius;
                LimitMode_HDLQ_Active<=Axis1_LimitMode_HDLQ; 
                end
                4'd2:begin
                IU_Active<=Axis2_IU;
                IV_Active<=Axis2_IV;
                SINval_Active<=Axis2_SINval;
                COSval_Active<=Axis2_COSval;
                ISINval_Active<=Axis2_ISINval;
                ICOSval_Active<=Axis2_ICOSval;
                DUiAcc_Active<=Axis2_DUiAcc;
                QUiAcc_Active<=Axis2_QUiAcc;
            
                DRef_Active<=Axis2_DRef;
                DKp_Active<=Axis2_DKp;
                DKi_Active<=Axis2_DKi;
                DCompensate_Active<=Axis2_DCompensate;
                QRef_Active<=Axis2_QRef;
                QKp_Active<=Axis2_QKp;
                QKi_Active<=Axis2_QKi;
                QCompensate_Active<=Axis2_QCompensate;
                LimitCircleRadius_Active<=Axis2_LimitCircleRadius;
                LimitMode_HDLQ_Active<=Axis2_LimitMode_HDLQ; 
                end
                4'd3:begin
                IU_Active<=Axis3_IU;
                IV_Active<=Axis3_IV;
                SINval_Active<=Axis3_SINval;
                COSval_Active<=Axis3_COSval;
                ISINval_Active<=Axis3_ISINval;
                ICOSval_Active<=Axis3_ICOSval;
                DUiAcc_Active<=Axis3_DUiAcc;
                QUiAcc_Active<=Axis3_QUiAcc;
            
                DRef_Active<=Axis3_DRef;
                DKp_Active<=Axis3_DKp;
                DKi_Active<=Axis3_DKi;
                DCompensate_Active<=Axis3_DCompensate;
                QRef_Active<=Axis3_QRef;
                QKp_Active<=Axis3_QKp;
                QKi_Active<=Axis3_QKi;
                QCompensate_Active<=Axis3_QCompensate;
                LimitCircleRadius_Active<=Axis3_LimitCircleRadius;
                LimitMode_HDLQ_Active<=Axis3_LimitMode_HDLQ; 
                end
              4'd4:begin
                IU_Active<=Axis4_IU;
                IV_Active<=Axis4_IV;
                SINval_Active<=Axis4_SINval; 
                COSval_Active<=Axis4_COSval;
                ISINval_Active<=Axis4_ISINval;
                ICOSval_Active<=Axis4_ICOSval;
                DUiAcc_Active<=Axis4_DUiAcc;
                QUiAcc_Active<=Axis4_QUiAcc;
            
                DRef_Active<=Axis4_DRef;
                DKp_Active<=Axis4_DKp;
                DKi_Active<=Axis4_DKi;
                DCompensate_Active<=Axis4_DCompensate;
                QRef_Active<=Axis4_QRef;
                QKp_Active<=Axis4_QKp;
                QKi_Active<=Axis4_QKi;
                QCompensate_Active<=Axis4_QCompensate;
                LimitCircleRadius_Active<=Axis4_LimitCircleRadius;
                LimitMode_HDLQ_Active<=Axis4_LimitMode_HDLQ; 
                end
                default:begin
                IU_Active<=16'd0;
                IV_Active<=16'd0;
                SINval_Active<=16'd0;
                COSval_Active<=16'd0;
                ISINval_Active<=16'd0;
                ICOSval_Active<=16'd0;
                DUiAcc_Active<=32'd0;
                QUiAcc_Active<=32'd0;
            
                DRef_Active<=16'd0;
                DKp_Active<=32'd0;
                DKi_Active<=32'd0;
                DCompensate_Active<=16'd0;
                QRef_Active<=16'd0;
                QKp_Active<=32'd0;
                QKi_Active<=32'd0;
                QCompensate_Active<=16'd0;
                LimitCircleRadius_Active<=16'd0;
                LimitMode_HDLQ_Active<=1'b0;
                end
                endcase
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Axis1_IALPHA<=16'd0;
            Axis1_IBETA<=16'd0;
            Axis1_ID<=16'd0;
            Axis1_IQ<=16'd0;
            Axis1_UD<=16'd0;
            Axis1_UQ<=16'd0;
            Axis1_UALPHA<=16'd0;
            Axis1_UBETA<=16'd0;
            
            Axis2_IALPHA<=16'd0;
            Axis2_IBETA<=16'd0;
            Axis2_ID<=16'd0;
            Axis2_IQ<=16'd0;
            Axis2_UD<=16'd0;
            Axis2_UQ<=16'd0;
            Axis2_UALPHA<=16'd0;
            Axis2_UBETA<=16'd0;   

            Axis3_IALPHA<=16'd0;
            Axis3_IBETA<=16'd0;
            Axis3_ID<=16'd0;
            Axis3_IQ<=16'd0;
            Axis3_UD<=16'd0;
            Axis3_UQ<=16'd0;
            Axis3_UALPHA<=16'd0;
            Axis3_UBETA<=16'd0;

            Axis4_IALPHA<=16'd0;
            Axis4_IBETA<=16'd0;
            Axis4_ID<=16'd0;
            Axis4_IQ<=16'd0;
            Axis4_UD<=16'd0;
            Axis4_UQ<=16'd0;
            Axis4_UALPHA<=16'd0;
            Axis4_UBETA<=16'd0;            
        end
        else begin
            if(MotorCurrentCtrler_finish)begin
                case(MotorCurrentCtrler_AxisesCalStep)
                4'd1:begin
                Axis1_IALPHA<=IALPHA_Active;
                Axis1_IBETA<=IBETA_Active;
                Axis1_ID<=ID_Active;
                Axis1_IQ<=IQ_Active;
                Axis1_UD<=UD_Active;
                Axis1_UQ<=UQ_Active;
                Axis1_UALPHA<=UALPHA_Active;
                Axis1_UBETA<=UBETA_Active;
                end
                4'd2:begin
                Axis2_IALPHA<=IALPHA_Active;
                Axis2_IBETA<=IBETA_Active;
                Axis2_ID<=ID_Active;
                Axis2_IQ<=IQ_Active;
                Axis2_UD<=UD_Active;
                Axis2_UQ<=UQ_Active;
                Axis2_UALPHA<=UALPHA_Active;
                Axis2_UBETA<=UBETA_Active;
                end
                4'd3:begin
                Axis3_IALPHA<=IALPHA_Active;
                Axis3_IBETA<=IBETA_Active;
                Axis3_ID<=ID_Active;
                Axis3_IQ<=IQ_Active;
                Axis3_UD<=UD_Active;
                Axis3_UQ<=UQ_Active;
                Axis3_UALPHA<=UALPHA_Active;
                Axis3_UBETA<=UBETA_Active;
                end
                4'd4:begin
                Axis4_IALPHA<=IALPHA_Active;
                Axis4_IBETA<=IBETA_Active;
                Axis4_ID<=ID_Active;
                Axis4_IQ<=IQ_Active;
                Axis4_UD<=UD_Active;
                Axis4_UQ<=UQ_Active;
                Axis4_UALPHA<=UALPHA_Active;
                Axis4_UBETA<=UBETA_Active;
                end
                endcase
            end
        end
    end
    

    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            UALPHA_SV_Active<=16'd0;
            UBETA_SV_Active<=16'd0;
        end
        else begin
            if(SvpwmModulate_DataInputLoad)begin
                case(SvpwmModulate_AxisesCalStep)
                4'd1:begin
                    if(Axis1_SvpwmInputSel==1'b0)begin
                        UALPHA_SV_Active<=Axis1_UALPHA;
                        UBETA_SV_Active<=Axis1_UBETA;
                    end
                    else begin
                        UALPHA_SV_Active<=Axis1_UALPHA_selfdef;
                        UBETA_SV_Active<=Axis1_UBETA_selfdef;
                    end
                end
                4'd2:begin
                    if(Axis2_SvpwmInputSel==1'b0)begin
                        UALPHA_SV_Active<=Axis2_UALPHA;
                        UBETA_SV_Active<=Axis2_UBETA;
                    end
                    else begin
                        UALPHA_SV_Active<=Axis2_UALPHA_selfdef;
                        UBETA_SV_Active<=Axis2_UBETA_selfdef;
                    end
                end
                4'd3:begin
                    if(Axis3_SvpwmInputSel==1'b0)begin
                        UALPHA_SV_Active<=Axis3_UALPHA;
                        UBETA_SV_Active<=Axis3_UBETA;
                    end
                    else begin
                        UALPHA_SV_Active<=Axis3_UALPHA_selfdef;
                        UBETA_SV_Active<=Axis3_UBETA_selfdef;
                    end
                end
                4'd4:begin
                    if(Axis4_SvpwmInputSel==1'b0)begin
                        UALPHA_SV_Active<=Axis4_UALPHA;
                        UBETA_SV_Active<=Axis4_UBETA;
                    end
                    else begin
                        UALPHA_SV_Active<=Axis4_UALPHA_selfdef;
                        UBETA_SV_Active<=Axis4_UBETA_selfdef;
                    end
                end
                default:begin
                UALPHA_SV_Active<=16'd0;
                UBETA_SV_Active<=16'd0;
                end
                endcase
            end
        end
    end    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Axis1_DutyA <= 16'd0;
            Axis1_DutyB <= 16'd0;
            Axis1_DutyC <= 16'd0;
            
            Axis2_DutyA <= 16'd0;
            Axis2_DutyB <= 16'd0;
            Axis2_DutyC <= 16'd0;
            
            Axis3_DutyA <= 16'd0;
            Axis3_DutyB <= 16'd0;
            Axis3_DutyC <= 16'd0;

            Axis4_DutyA <= 16'd0;
            Axis4_DutyB <= 16'd0;
            Axis4_DutyC <= 16'd0;            
        end
        else begin
            if(Axises_CalEN[0])begin
                if(SvpwmModulate_finish && (SvpwmModulate_AxisesCalStep==4'd1))begin
                    Axis1_DutyA <= DutyA_Active;
                    Axis1_DutyB <= DutyB_Active;
                    Axis1_DutyC <= DutyC_Active;
                end
            end
            else begin
                Axis1_DutyA <= 16'd0;
                Axis1_DutyB <= 16'd0;
                Axis1_DutyC <= 16'd0;
            end
            if(Axises_CalEN[1])begin
                if(SvpwmModulate_finish && (SvpwmModulate_AxisesCalStep==4'd2))begin
                    Axis2_DutyA <= DutyA_Active;
                    Axis2_DutyB <= DutyB_Active;
                    Axis2_DutyC <= DutyC_Active;
                end
            end
            else begin
                Axis2_DutyA <= 16'd0;
                Axis2_DutyB <= 16'd0;
                Axis2_DutyC <= 16'd0;
            end
            if(Axises_CalEN[2])begin
                if(SvpwmModulate_finish && (SvpwmModulate_AxisesCalStep==4'd3))begin
                    Axis3_DutyA <= DutyA_Active;
                    Axis3_DutyB <= DutyB_Active;
                    Axis3_DutyC <= DutyC_Active;
                end
            end
            else begin
                Axis3_DutyA <= 16'd0;
                Axis3_DutyB <= 16'd0;
                Axis3_DutyC <= 16'd0;
            end
            if(Axises_CalEN[3])begin
                if(SvpwmModulate_finish && (SvpwmModulate_AxisesCalStep==4'd4))begin
                    Axis4_DutyA <= DutyA_Active;
                    Axis4_DutyB <= DutyB_Active;
                    Axis4_DutyC <= DutyC_Active;
                end
            end
            else begin
                Axis4_DutyA <= 16'd0;
                Axis4_DutyB <= 16'd0;
                Axis4_DutyC <= 16'd0;
            end            
        end
    end
    
    
    assign MotorCurrentCtrler_finish_aixs1 = MotorCurrentCtrler_finish && (MotorCurrentCtrler_AxisesCalStep==4'd1);
    assign MotorCurrentCtrler_finish_aixs2 = MotorCurrentCtrler_finish && (MotorCurrentCtrler_AxisesCalStep==4'd2);
    assign MotorCurrentCtrler_finish_aixs3 = MotorCurrentCtrler_finish && (MotorCurrentCtrler_AxisesCalStep==4'd3);
    assign MotorCurrentCtrler_finish_aixs4 = MotorCurrentCtrler_finish && (MotorCurrentCtrler_AxisesCalStep==4'd4);
    
            
    always @ (*)
        Axises_CurrentCtrlFinsih = {MotorCurrentCtrler_finish_aixs4,MotorCurrentCtrler_finish_aixs3,
                                        MotorCurrentCtrler_finish_aixs2,MotorCurrentCtrler_finish_aixs1};
                                        
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            finish<=1'b0;
        else
            finish<=((SvpwmModulate_AxisesCalStep==4'd4)&&SvpwmModulate_finish);
    end
endmodule         



























