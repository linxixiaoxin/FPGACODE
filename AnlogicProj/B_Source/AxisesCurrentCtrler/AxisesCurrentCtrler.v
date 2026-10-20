module AxisesCurrentCtrler(
    input                       clk,
    input                       rst,
    input                       trig,
    output                      finish,
    //data & addr bus
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,    
    input                       CS,
    output              [15:0]  RDDATA,   
    
    input               [3:0]   Axises_CalEN,
    
    input       signed  [15:0]  Axis1_IU,//16bit 
    input       signed  [15:0]  Axis1_IV,//16bit
    input       signed  [15:0]  Axis1_SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis1_COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis1_ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis1_ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    input       signed  [15:0]  Axis2_IU,//16bit 
    input       signed  [15:0]  Axis2_IV,//16bit
    input       signed  [15:0]  Axis2_SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis2_COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis2_ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis2_ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    input       signed  [15:0]  Axis3_IU,//16bit 
    input       signed  [15:0]  Axis3_IV,//16bit
    input       signed  [15:0]  Axis3_SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis3_COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis3_ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis3_ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    input       signed  [15:0]  Axis4_IU,//16bit 
    input       signed  [15:0]  Axis4_IV,//16bit
    input       signed  [15:0]  Axis4_SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis4_COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis4_ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  Axis4_ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    input               [15:0]  PreiodCNT,//half counter period(Carrier, up & down count)
    output              [15:0]  Axis1_DutyA,//=PhaseA Duty cycle*PreiodCNT
    output              [15:0]  Axis1_DutyB,//=PhaseB Duty cycle*PreiodCNT
    output              [15:0]  Axis1_DutyC,//=PhaseC Duty cycle*PreiodCNT
    output              [15:0]  Axis2_DutyA,//=PhaseA Duty cycle*PreiodCNT
    output              [15:0]  Axis2_DutyB,//=PhaseB Duty cycle*PreiodCNT
    output              [15:0]  Axis2_DutyC,//=PhaseC Duty cycle*PreiodCNT
    output              [15:0]  Axis3_DutyA,//=PhaseA Duty cycle*PreiodCNT
    output              [15:0]  Axis3_DutyB,//=PhaseB Duty cycle*PreiodCNT
    output              [15:0]  Axis3_DutyC,//=PhaseC Duty cycle*PreiodCNT
    output              [15:0]  Axis4_DutyA,//=PhaseA Duty cycle*PreiodCNT
    output              [15:0]  Axis4_DutyB,//=PhaseB Duty cycle*PreiodCNT
    output              [15:0]  Axis4_DutyC//=PhaseC Duty cycle*PreiodCNT    
    );
    
    wire                [15:0]  HWVoltageCircleLimit;
    wire                        SvpwmModulate_trig;        
    wire                        SvpwmModulate_finish; 
    wire                        MotorCurrentCtrler_trig; 
    wire                        MotorCurrentCtrler_finish; 
    //===========================================
    wire                [15:0]  IU_Active;//16bit 
    wire                [15:0]  IV_Active;//16bit
    wire                [15:0]  SINval_Active;//pu, range(-1,1), Base 1, 16bit Q15 signed
    wire                [15:0]  COSval_Active;//pu, range(-1,1), Base 1, 16bit Q15 signed
    wire                [15:0]  ISINval_Active;//pu, range(-1,1), Base 1, 16bit Q15 signed
    wire                [15:0]  ICOSval_Active;//pu, range(-1,1), Base 1, 16bit Q15 signed
    
    wire                [15:0]  DRef_Active;//D axis reference,16bit,Q15, pu , base = Ibase,(-1,1)
    wire                [31:0]  DKp_Active;//D axis Kp,32bit,Q15, pu , base = Ubase/Ibase
    wire                [31:0]  DKi_Active;//D axis Ki,32bit,Q15, pu , base = Ubase/Ibase
    wire                [15:0]  DCompensate_Active;//D axis DCompensate,16bit,Q15, pu , base = Ubase,(-1,1)
    wire                [15:0]  QRef_Active;//Q axis reference,16bit,Q15, pu , base = Ibase,(-1,1)
    wire                [31:0]  QKp_Active;//Q axis Kp,32bit,Q15, pu , base = Ubase/Ibase
    wire                [31:0]  QKi_Active;//Q axis Ki,32bit,Q15, pu , base = Ubase/Ibase
    wire                [15:0]  QCompensate_Active;//Q axis DCompensate,16bit,Q15, pu , base = Ubase,(-1,1)  
    wire                [15:0]  LimitCircleRadius_Active;//Voltage Circle limit,limit from user, 16bit,Q15, pu , base = Ubase,(-1,1)    
    wire                        LimitMode_HDLQ_Active;//Limit Mode, 1:Limit D aixs output,Q axis cal first; 0:limit Q axis mode,D axis cal first
    
    wire                [15:0]  IALPHA_Active;
    wire                [15:0]  IBETA_Active;
    wire                [15:0]  ID_Active;
    wire                [15:0]  IQ_Active;
    wire                [31:0]  DUiAcc_new_Active;
    wire                [31:0]  QUiAcc_new_Active;
    wire                [15:0]  UD_Active; 
    wire                [15:0]  UQ_Active;
    wire                [15:0]  UALPHA_Active; 
    wire                [15:0]  UBETA_Active;    
    
    wire                [15:0]  UALPHA_SV_Active; 
    wire                [15:0]  UBETA_SV_Active;                
    
    wire                [15:0]  DutyA_Active;//=PhaseA Duty cycle*PreiodCNT
    wire                [15:0]  DutyB_Active;//=PhaseB Duty cycle*PreiodCNT
    wire                [15:0]  DutyC_Active;//=PhaseC Duty cycle*PreiodCNT    
    
    //===========================================
    wire                [15:0]  Axis1_DRef;
    wire                [31:0]  Axis1_DKp;
    wire                [31:0]  Axis1_DKi;
    wire                [15:0]  Axis1_DCompensate;
    wire                [15:0]  Axis1_QRef;
    wire                [31:0]  Axis1_QKp;
    wire                [31:0]  Axis1_QKi;
    wire                [15:0]  Axis1_QCompensate;
    wire                [15:0]  Axis1_LimitCircleRadius;
    wire                        Axis1_LimitMode_HDLQ;
    
    wire                [15:0]  Axis2_DRef;
    wire                [31:0]  Axis2_DKp;
    wire                [31:0]  Axis2_DKi;
    wire                [15:0]  Axis2_DCompensate;
    wire                [15:0]  Axis2_QRef;
    wire                [31:0]  Axis2_QKp;
    wire                [31:0]  Axis2_QKi;
    wire                [15:0]  Axis2_QCompensate;
    wire                [15:0]  Axis2_LimitCircleRadius;
    wire                        Axis2_LimitMode_HDLQ;

    wire                [15:0]  Axis3_DRef;
    wire                [31:0]  Axis3_DKp;
    wire                [31:0]  Axis3_DKi;
    wire                [15:0]  Axis3_DCompensate;
    wire                [15:0]  Axis3_QRef;
    wire                [31:0]  Axis3_QKp;
    wire                [31:0]  Axis3_QKi;
    wire                [15:0]  Axis3_QCompensate;
    wire                [15:0]  Axis3_LimitCircleRadius;
    wire                        Axis3_LimitMode_HDLQ;

    wire                [15:0]  Axis4_DRef;
    wire                [31:0]  Axis4_DKp;
    wire                [31:0]  Axis4_DKi;
    wire                [15:0]  Axis4_DCompensate;
    wire                [15:0]  Axis4_QRef;
    wire                [31:0]  Axis4_QKp;
    wire                [31:0]  Axis4_QKi;
    wire                [15:0]  Axis4_QCompensate;
    wire                [15:0]  Axis4_LimitCircleRadius;
    wire                        Axis4_LimitMode_HDLQ;
    
    wire                [3:0]   Axises_CurrentCtrlFinsih;
    wire                [31:0]  DUiAcc_Active;
    wire                [31:0]  QUiAcc_Active;    
    
    wire                [15:0]  Axis1_IALPHA;
    wire                [15:0]  Axis1_IBETA;
    wire                [15:0]  Axis1_ID;
    wire                [15:0]  Axis1_IQ;
    wire                [31:0]  Axis1_DUiAcc_update;
    wire                [31:0]  Axis1_QUiAcc_update;    
    wire                [15:0]  Axis1_UD; 
    wire                [15:0]  Axis1_UQ;
    wire                [15:0]  Axis1_UALPHA; 
    wire                [15:0]  Axis1_UBETA;
    wire                        Axis1_SvpwmInputSel;
    wire                [15:0]  Axis1_UALPHA_selfdef;
    wire                [15:0]  Axis1_UBETA_selfdef;
    
    wire                [15:0]  Axis2_IALPHA;
    wire                [15:0]  Axis2_IBETA;
    wire                [15:0]  Axis2_ID;
    wire                [15:0]  Axis2_IQ;
    wire                [31:0]  Axis2_DUiAcc_update;
    wire                [31:0]  Axis2_QUiAcc_update;    
    wire                [15:0]  Axis2_UD; 
    wire                [15:0]  Axis2_UQ;
    wire                [15:0]  Axis2_UALPHA; 
    wire                [15:0]  Axis2_UBETA;
    wire                        Axis2_SvpwmInputSel;
    wire                [15:0]  Axis2_UALPHA_selfdef;
    wire                [15:0]  Axis2_UBETA_selfdef;    
    
    wire                [15:0]  Axis3_IALPHA;
    wire                [15:0]  Axis3_IBETA;
    wire                [15:0]  Axis3_ID;
    wire                [15:0]  Axis3_IQ;
    wire                [31:0]  Axis3_DUiAcc_update;
    wire                [31:0]  Axis3_QUiAcc_update;    
    wire                [15:0]  Axis3_UD; 
    wire                [15:0]  Axis3_UQ;
    wire                [15:0]  Axis3_UALPHA; 
    wire                [15:0]  Axis3_UBETA;
    wire                        Axis3_SvpwmInputSel;
    wire                [15:0]  Axis3_UALPHA_selfdef;
    wire                [15:0]  Axis3_UBETA_selfdef;    

    wire                [15:0]  Axis4_IALPHA;
    wire                [15:0]  Axis4_IBETA;
    wire                [15:0]  Axis4_ID;
    wire                [15:0]  Axis4_IQ;
    wire                [31:0]  Axis4_DUiAcc_update;
    wire                [31:0]  Axis4_QUiAcc_update;   
    wire                [15:0]  Axis4_UD; 
    wire                [15:0]  Axis4_UQ;
    wire                [15:0]  Axis4_UALPHA; 
    wire                [15:0]  Axis4_UBETA; 
    wire                        Axis4_SvpwmInputSel;
    wire                [15:0]  Axis4_UALPHA_selfdef;
    wire                [15:0]  Axis4_UBETA_selfdef;    
              
    
RegSpcae_AxisesCurrentCtrler RegSpcae_AxisesCurrentCtrler_inst(
    .clk(clk),
    .rst(rst),
    //data & addr bus
    .CS(CS),
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .RDDATA(RDDATA),
    //inner reg interface
    .Axis1_DRef(Axis1_DRef),
    .Axis1_DKp(Axis1_DKp),
    .Axis1_DKi(Axis1_DKi),
    .Axis1_DCompensate(Axis1_DCompensate),
    .Axis1_QRef(Axis1_QRef),
    .Axis1_QKp(Axis1_QKp),
    .Axis1_QKi(Axis1_QKi),
    .Axis1_QCompensate(Axis1_QCompensate),
    .Axis1_LimitCircleRadius(Axis1_LimitCircleRadius),
    .Axis1_LimitMode_HDLQ(Axis1_LimitMode_HDLQ),
    
    .Axis2_DRef(Axis2_DRef),
    .Axis2_DKp(Axis2_DKp),
    .Axis2_DKi(Axis2_DKi),
    .Axis2_DCompensate(Axis2_DCompensate),
    .Axis2_QRef(Axis2_QRef),
    .Axis2_QKp(Axis2_QKp),
    .Axis2_QKi(Axis2_QKi),
    .Axis2_QCompensate(Axis2_QCompensate),
    .Axis2_LimitCircleRadius(Axis2_LimitCircleRadius),
    .Axis2_LimitMode_HDLQ(Axis2_LimitMode_HDLQ),

    .Axis3_DRef(Axis3_DRef),
    .Axis3_DKp(Axis3_DKp),
    .Axis3_DKi(Axis3_DKi),
    .Axis3_DCompensate(Axis3_DCompensate),
    .Axis3_QRef(Axis3_QRef),
    .Axis3_QKp(Axis3_QKp),
    .Axis3_QKi(Axis3_QKi),
    .Axis3_QCompensate(Axis3_QCompensate),
    .Axis3_LimitCircleRadius(Axis3_LimitCircleRadius),
    .Axis3_LimitMode_HDLQ(Axis3_LimitMode_HDLQ),

    .Axis4_DRef(Axis4_DRef),
    .Axis4_DKp(Axis4_DKp),
    .Axis4_DKi(Axis4_DKi),
    .Axis4_DCompensate(Axis4_DCompensate),
    .Axis4_QRef(Axis4_QRef),
    .Axis4_QKp(Axis4_QKp),
    .Axis4_QKi(Axis4_QKi),
    .Axis4_QCompensate(Axis4_QCompensate),
    .Axis4_LimitCircleRadius(Axis4_LimitCircleRadius),
    .Axis4_LimitMode_HDLQ(Axis4_LimitMode_HDLQ),
    
    .Axises_CalEN(Axises_CalEN),
    .Axises_CurrentCtrlFinsih(Axises_CurrentCtrlFinsih),
    .DUiAcc_Active(DUiAcc_new_Active),
    .QUiAcc_Active(QUiAcc_new_Active),
    
    .Axis1_IALPHA(Axis1_IALPHA),
    .Axis1_IBETA(Axis1_IBETA),
    .Axis1_ID(Axis1_ID),
    .Axis1_IQ(Axis1_IQ),
    .Axis1_DUiAcc_update(Axis1_DUiAcc_update),
    .Axis1_QUiAcc_update(Axis1_QUiAcc_update),
    .Axis1_UD(Axis1_UD), 
    .Axis1_UQ(Axis1_UQ),
    .Axis1_UALPHA(Axis1_UALPHA), 
    .Axis1_UBETA(Axis1_UBETA),
    .Axis1_SvpwmInputSel(Axis1_SvpwmInputSel),
    .Axis1_UALPHA_selfdef(Axis1_UALPHA_selfdef),
    .Axis1_UBETA_selfdef(Axis1_UBETA_selfdef),     

    .Axis2_IALPHA(Axis2_IALPHA),
    .Axis2_IBETA(Axis2_IBETA),
    .Axis2_ID(Axis2_ID),
    .Axis2_IQ(Axis2_IQ),
    .Axis2_DUiAcc_update(Axis2_DUiAcc_update),
    .Axis2_QUiAcc_update(Axis2_QUiAcc_update),    
    .Axis2_UD(Axis2_UD), 
    .Axis2_UQ(Axis2_UQ),
    .Axis2_UALPHA(Axis2_UALPHA), 
    .Axis2_UBETA(Axis2_UBETA),  
    .Axis2_SvpwmInputSel(Axis2_SvpwmInputSel),
    .Axis2_UALPHA_selfdef(Axis2_UALPHA_selfdef),
    .Axis2_UBETA_selfdef(Axis2_UBETA_selfdef),        

    .Axis3_IALPHA(Axis3_IALPHA),
    .Axis3_IBETA(Axis3_IBETA),
    .Axis3_ID(Axis3_ID),
    .Axis3_IQ(Axis3_IQ),
    .Axis3_DUiAcc_update(Axis3_DUiAcc_update),
    .Axis3_QUiAcc_update(Axis3_QUiAcc_update),    
    .Axis3_UD(Axis3_UD), 
    .Axis3_UQ(Axis3_UQ),
    .Axis3_UALPHA(Axis3_UALPHA), 
    .Axis3_UBETA(Axis3_UBETA),
    .Axis3_SvpwmInputSel(Axis3_SvpwmInputSel),
    .Axis3_UALPHA_selfdef(Axis3_UALPHA_selfdef),
    .Axis3_UBETA_selfdef(Axis3_UBETA_selfdef),        

    .Axis4_IALPHA(Axis4_IALPHA),
    .Axis4_IBETA(Axis4_IBETA),
    .Axis4_ID(Axis4_ID),
    .Axis4_IQ(Axis4_IQ),
    .Axis4_DUiAcc_update(Axis4_DUiAcc_update),
    .Axis4_QUiAcc_update(Axis4_QUiAcc_update),    
    .Axis4_UD(Axis4_UD), 
    .Axis4_UQ(Axis4_UQ),
    .Axis4_UALPHA(Axis4_UALPHA), 
    .Axis4_UBETA(Axis4_UBETA),
    .Axis4_SvpwmInputSel(Axis4_SvpwmInputSel),
    .Axis4_UALPHA_selfdef(Axis4_UALPHA_selfdef),
    .Axis4_UBETA_selfdef(Axis4_UBETA_selfdef)       
    );

ArithmeticScheduler ArithmeticScheduler_inst(    
    .clk(clk),
    .rst(rst),
    .trig(trig),
    .finish(finish),
    .Axises_CurrentCtrlFinsih(Axises_CurrentCtrlFinsih),
    
    .Axis1_IU(Axis1_IU),//16bit 
    .Axis1_IV(Axis1_IV),//16bit
    .Axis1_SINval(Axis1_SINval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis1_COSval(Axis1_COSval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis1_ISINval(Axis1_ISINval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis1_ICOSval(Axis1_ICOSval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    
    .Axis2_IU(Axis2_IU),//16bit 
    .Axis2_IV(Axis2_IV),//16bit
    .Axis2_SINval(Axis2_SINval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis2_COSval(Axis2_COSval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis2_ISINval(Axis2_ISINval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis2_ICOSval(Axis2_ICOSval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    
    .Axis3_IU(Axis3_IU),//16bit 
    .Axis3_IV(Axis3_IV),//16bit
    .Axis3_SINval(Axis3_SINval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis3_COSval(Axis3_COSval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis3_ISINval(Axis3_ISINval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis3_ICOSval(Axis3_ICOSval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    
    .Axis4_IU(Axis4_IU),//16bit 
    .Axis4_IV(Axis4_IV),//16bit
    .Axis4_SINval(Axis4_SINval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis4_COSval(Axis4_COSval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis4_ISINval(Axis4_ISINval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .Axis4_ICOSval(Axis4_ICOSval),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed    
    
    .Axis1_DUiAcc(Axis1_DUiAcc_update),
    .Axis1_QUiAcc(Axis1_QUiAcc_update),
    .Axis2_DUiAcc(Axis2_DUiAcc_update),
    .Axis2_QUiAcc(Axis2_QUiAcc_update),
    .Axis3_DUiAcc(Axis3_DUiAcc_update),
    .Axis3_QUiAcc(Axis3_QUiAcc_update),
    .Axis4_DUiAcc(Axis4_DUiAcc_update),
    .Axis4_QUiAcc(Axis4_QUiAcc_update),       
    
    .Axis1_DRef(Axis1_DRef),
    .Axis1_DKp(Axis1_DKp),
    .Axis1_DKi(Axis1_DKi),
    .Axis1_DCompensate(Axis1_DCompensate),
    .Axis1_QRef(Axis1_QRef),
    .Axis1_QKp(Axis1_QKp),
    .Axis1_QKi(Axis1_QKi),
    .Axis1_QCompensate(Axis1_QCompensate),
    .Axis1_LimitCircleRadius(Axis1_LimitCircleRadius),
    .Axis1_LimitMode_HDLQ(Axis1_LimitMode_HDLQ),
    
    .Axis2_DRef(Axis2_DRef),
    .Axis2_DKp(Axis2_DKp),
    .Axis2_DKi(Axis2_DKi),
    .Axis2_DCompensate(Axis2_DCompensate),
    .Axis2_QRef(Axis2_QRef),
    .Axis2_QKp(Axis2_QKp),
    .Axis2_QKi(Axis2_QKi),
    .Axis2_QCompensate(Axis2_QCompensate),
    .Axis2_LimitCircleRadius(Axis2_LimitCircleRadius),
    .Axis2_LimitMode_HDLQ(Axis2_LimitMode_HDLQ),

    .Axis3_DRef(Axis3_DRef),
    .Axis3_DKp(Axis3_DKp),
    .Axis3_DKi(Axis3_DKi),
    .Axis3_DCompensate(Axis3_DCompensate),
    .Axis3_QRef(Axis3_QRef),
    .Axis3_QKp(Axis3_QKp),
    .Axis3_QKi(Axis3_QKi),
    .Axis3_QCompensate(Axis3_QCompensate),
    .Axis3_LimitCircleRadius(Axis3_LimitCircleRadius),
    .Axis3_LimitMode_HDLQ(Axis3_LimitMode_HDLQ),

    .Axis4_DRef(Axis4_DRef),
    .Axis4_DKp(Axis4_DKp),
    .Axis4_DKi(Axis4_DKi),
    .Axis4_DCompensate(Axis4_DCompensate),
    .Axis4_QRef(Axis4_QRef),
    .Axis4_QKp(Axis4_QKp),
    .Axis4_QKi(Axis4_QKi),
    .Axis4_QCompensate(Axis4_QCompensate),
    .Axis4_LimitCircleRadius(Axis4_LimitCircleRadius),
    .Axis4_LimitMode_HDLQ(Axis4_LimitMode_HDLQ),

    //MotorCurrentCtrler interface==========================================================
    .MotorCurrentCtrler_trig(MotorCurrentCtrler_trig),   
    .MotorCurrentCtrler_finish(MotorCurrentCtrler_finish), 
    .IU_Active(IU_Active),//16bit 
    .IV_Active(IV_Active),//16bit
    .SINval_Active(SINval_Active),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .COSval_Active(COSval_Active),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .ISINval_Active(ISINval_Active),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .ICOSval_Active(ICOSval_Active),//pu(), range(-1(),1)(), Base 1(), 16bit Q15 signed
    .DUiAcc_Active(DUiAcc_Active),
    .QUiAcc_Active(QUiAcc_Active),
    
    .DRef_Active(DRef_Active),//D axis reference(),16bit(),Q15(), pu (), base = Ibase(),(-1(),1)
    .DKp_Active(DKp_Active),//D axis Kp(),32bit(),Q15(), pu (), base = Ubase/Ibase
    .DKi_Active(DKi_Active),//D axis Ki(),32bit(),Q15(), pu (), base = Ubase/Ibase
    .DCompensate_Active(DCompensate_Active),//D axis DCompensate(),16bit(),Q15(), pu (), base = Ubase(),(-1(),1)
    .QRef_Active(QRef_Active),//Q axis reference(),16bit(),Q15(), pu (), base = Ibase(),(-1(),1)
    .QKp_Active(QKp_Active),//Q axis Kp(),32bit(),Q15(), pu (), base = Ubase/Ibase
    .QKi_Active(QKi_Active),//Q axis Ki(),32bit(),Q15(), pu (), base = Ubase/Ibase
    .QCompensate_Active(QCompensate_Active),//Q axis DCompensate(),16bit(),Q15(), pu (), base = Ubase(),(-1(),1)  
    .LimitCircleRadius_Active(LimitCircleRadius_Active),//Voltage Circle limit(),limit from user(), 16bit(),Q15(), pu (), base = Ubase(),(-1(),1)    
    .LimitMode_HDLQ_Active(LimitMode_HDLQ_Active),//Limit Mode(), 1:Limit D aixs output(),Q axis cal first(), 0:limit Q axis mode(),D axis cal first

    .IALPHA_Active(IALPHA_Active),
    .IBETA_Active(IBETA_Active),
    .ID_Active(ID_Active),
    .IQ_Active(IQ_Active),
    .UD_Active(UD_Active), 
    .UQ_Active(UQ_Active),
    .UALPHA_Active(UALPHA_Active), 
    .UBETA_Active(UBETA_Active),    

    .Axis1_IALPHA(Axis1_IALPHA),
    .Axis1_IBETA(Axis1_IBETA),
    .Axis1_ID(Axis1_ID),
    .Axis1_IQ(Axis1_IQ),
    .Axis1_UD(Axis1_UD), 
    .Axis1_UQ(Axis1_UQ),
    .Axis1_UALPHA(Axis1_UALPHA), 
    .Axis1_UBETA(Axis1_UBETA),

    .Axis2_IALPHA(Axis2_IALPHA),
    .Axis2_IBETA(Axis2_IBETA),
    .Axis2_ID(Axis2_ID),
    .Axis2_IQ(Axis2_IQ), 
    .Axis2_UD(Axis2_UD), 
    .Axis2_UQ(Axis2_UQ),
    .Axis2_UALPHA(Axis2_UALPHA), 
    .Axis2_UBETA(Axis2_UBETA),    

    .Axis3_IALPHA(Axis3_IALPHA),
    .Axis3_IBETA(Axis3_IBETA),
    .Axis3_ID(Axis3_ID),
    .Axis3_IQ(Axis3_IQ), 
    .Axis3_UD(Axis3_UD), 
    .Axis3_UQ(Axis3_UQ),
    .Axis3_UALPHA(Axis3_UALPHA), 
    .Axis3_UBETA(Axis3_UBETA),

    .Axis4_IALPHA(Axis4_IALPHA),
    .Axis4_IBETA(Axis4_IBETA),
    .Axis4_ID(Axis4_ID),
    .Axis4_IQ(Axis4_IQ),
    .Axis4_UD(Axis4_UD), 
    .Axis4_UQ(Axis4_UQ),
    .Axis4_UALPHA(Axis4_UALPHA), 
    .Axis4_UBETA(Axis4_UBETA),

    //SvpwmModulate  interface==========================================================
    .Axises_CalEN(Axises_CalEN),
    .Axis1_SvpwmInputSel(Axis1_SvpwmInputSel),
    .Axis1_UALPHA_selfdef(Axis1_UALPHA_selfdef),
    .Axis1_UBETA_selfdef(Axis1_UBETA_selfdef), 
    .Axis2_SvpwmInputSel(Axis2_SvpwmInputSel),
    .Axis2_UALPHA_selfdef(Axis2_UALPHA_selfdef),
    .Axis2_UBETA_selfdef(Axis2_UBETA_selfdef), 
    .Axis3_SvpwmInputSel(Axis3_SvpwmInputSel),
    .Axis3_UALPHA_selfdef(Axis3_UALPHA_selfdef),
    .Axis3_UBETA_selfdef(Axis3_UBETA_selfdef), 
    .Axis4_SvpwmInputSel(Axis4_SvpwmInputSel),
    .Axis4_UALPHA_selfdef(Axis4_UALPHA_selfdef),
    .Axis4_UBETA_selfdef(Axis4_UBETA_selfdef),      
    .SvpwmModulate_trig(SvpwmModulate_trig),         
    .SvpwmModulate_finish(SvpwmModulate_finish), 
    .UALPHA_SV_Active(UALPHA_SV_Active), 
    .UBETA_SV_Active(UBETA_SV_Active),
    .DutyA_Active(DutyA_Active),//=PhaseA Duty cycle*PreiodCNT
    .DutyB_Active(DutyB_Active),//=PhaseB Duty cycle*PreiodCNT
    .DutyC_Active(DutyC_Active),//=PhaseC Duty cycle*PreiodCNT 
    .Axis1_DutyA(Axis1_DutyA),//=PhaseA Duty cycle*PreiodCNT
    .Axis1_DutyB(Axis1_DutyB),//=PhaseB Duty cycle*PreiodCNT
    .Axis1_DutyC(Axis1_DutyC),//=PhaseC Duty cycle*PreiodCNT
    .Axis2_DutyA(Axis2_DutyA),//=PhaseA Duty cycle*PreiodCNT
    .Axis2_DutyB(Axis2_DutyB),//=PhaseB Duty cycle*PreiodCNT
    .Axis2_DutyC(Axis2_DutyC),//=PhaseC Duty cycle*PreiodCNT
    .Axis3_DutyA(Axis3_DutyA),//=PhaseA Duty cycle*PreiodCNT
    .Axis3_DutyB(Axis3_DutyB),//=PhaseB Duty cycle*PreiodCNT
    .Axis3_DutyC(Axis3_DutyC),//=PhaseC Duty cycle*PreiodCNT
    .Axis4_DutyA(Axis4_DutyA),//=PhaseA Duty cycle*PreiodCNT
    .Axis4_DutyB(Axis4_DutyB),//=PhaseB Duty cycle*PreiodCNT
    .Axis4_DutyC(Axis4_DutyC)//=PhaseC Duty cycle*PreiodCNT
    );    
    
    
MotorCurrentCtrler MotorCurrentCtrler_inst(    
    .clk(clk),
    .rst(rst),
    .trig(MotorCurrentCtrler_trig),//input pluse, active high
    .busy(),//output level, active high
    .finish(MotorCurrentCtrler_finish),//output pluse, active high
    //inner input=======================================================================
    .IU(IU_Active),
    .IV(IV_Active),
    .SINval(SINval_Active),
    .COSval(COSval_Active),
    .ISINval(ISINval_Active),
    .ICOSval(ICOSval_Active),
    .DUiAcc(DUiAcc_Active),
    .QUiAcc(QUiAcc_Active),  
    .LimitCircleRadiusHW(HWVoltageCircleLimit),
    //UserCtrl Paras=====================================================================
    .DRef(DRef_Active),
    .DKp(DKp_Active),
    .DKi(DKi_Active),
    .DCompensate(DCompensate_Active),
    
    .QRef(QRef_Active),
    .QKp(QKp_Active),
    .QKi(QKi_Active),
    .QCompensate(QCompensate_Active),
    
    .LimitCircleRadius(LimitCircleRadius_Active),
    .LimitMode_HDLQ(LimitMode_HDLQ_Active),
    //output=============================================================================
    .OutOFRange(),
    .DUiAcc_new(DUiAcc_new_Active),
    .QUiAcc_new(QUiAcc_new_Active),    
    .IALPHA(IALPHA_Active),
    .IBETA(IBETA_Active),
    .ID(ID_Active),
    .IQ(IQ_Active),
    .UD(UD_Active),
    .UQ(UQ_Active), 
    .UALPHA(UALPHA_Active),
    .UBETA(UBETA_Active)
    );  

SvpwmModulate SvpwmModulate_inst(    
    .clk(clk),
    .rst(rst),
    .trig(SvpwmModulate_trig),
    .busy(),
    .finish(SvpwmModulate_finish),
    .PreiodCNT(PreiodCNT),
    .VoltageCircleLimit(HWVoltageCircleLimit),
    .Ualpha(UALPHA_SV_Active),
    .Ubeta(UBETA_SV_Active),
    .DutyA(DutyA_Active),
    .DutyB(DutyB_Active),
    .DutyC(DutyC_Active)
    );
    
    
endmodule
