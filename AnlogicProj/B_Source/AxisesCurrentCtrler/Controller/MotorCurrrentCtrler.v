module MotorCurrentCtrler(    
    input                       clk,
    input                       rst,
    input                       trig,//input pluse, active high
    output                      busy,//output level, active high
    output                      finish,//output pluse, active high
    //inner input=======================================================================
    input       signed  [15:0]  IU,//16bit 
    input       signed  [15:0]  IV,//16bit
    input       signed  [15:0]  SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  ISINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  ICOSval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [31:0]  DUiAcc,//D axis intergral part
    input       signed  [31:0]  QUiAcc,//D axis intergral part    
    input       signed  [15:0]  LimitCircleRadiusHW,//Voltage Circle limit,limit from SVPWM,16bit,Q15, pu , base = Ubase,(-1,1) 
    //UserCtrl Paras=====================================================================
    input       signed  [15:0]  DRef,//D axis reference,16bit,Q15, pu , base = Ibase,(-1,1)
    input       signed  [31:0]  DKp,//D axis Kp,32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [31:0]  DKi,//D axis Ki,32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [15:0]  DCompensate,//D axis DCompensate,16bit,Q15, pu , base = Ubase,(-1,1)
    
    input       signed  [15:0]  QRef,//Q axis reference,16bit,Q15, pu , base = Ibase,(-1,1)
    input       signed  [31:0]  QKp,//Q axis Kp,32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [31:0]  QKi,//Q axis Ki,32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [15:0]  QCompensate,//Q axis DCompensate,16bit,Q15, pu , base = Ubase,(-1,1)  
    
    input       signed  [15:0]  LimitCircleRadius,//Voltage Circle limit,limit from user, 16bit,Q15, pu , base = Ubase,(-1,1)    
    input                       LimitMode_HDLQ,//Limit Mode, 1:Limit D aixs output,Q axis cal first; 0:limit Q axis mode,D axis cal first
    //output=============================================================================
    output                      OutOFRange,
    output      signed  [31:0]  DUiAcc_new,//D axis intergral part output
    output      signed  [31:0]  QUiAcc_new,//Q axis intergral part output
    
    output      signed  [15:0]  IALPHA,//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed 
    output      signed  [15:0]  IBETA,//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed
    output      signed  [15:0]  ID,//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed
    output      signed  [15:0]  IQ,//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed
    output      signed  [15:0]  UD,//output D axis voltage, 16bit,Q15, pu , base = Ubase,(-1,1)  
    output      signed  [15:0]  UQ,//output Q axis voltage, 16bit,Q15, pu , base = Ubase,(-1,1)  
    output      signed  [15:0]  UALPHA,//output Alpha axis voltage,16bit,Q15, pu , base = Ubase,(-1,1)  
    output      signed  [15:0]  UBETA//output Beta axis voltage,16bit,Q15, pu , base = Ubase,(-1,1)
    );  
    
    wire            ClarkTrans_finish;
    wire            ParkTrans_finish;
    wire            VectorCtrler_finish;
    
InputCurrentMonitor InputCurrentMonitor_inst(
    .IU(IU),
    .IV(IV),
    .OutOFRange(OutOFRange)
    );    
    
ClarkTrans ClarkTrans_inst(
    .clk(clk),
    .rst(rst),
    .trig(trig),
    .busy(),
    .finish(ClarkTrans_finish),

    .IU(IU),
    .IV(IV),
    .IALPHA(IALPHA),
    .IBETA(IBETA)
    );
      
ParkTrans ParkTrans_inst(
    .clk(clk),
    .rst(rst),
    .trig(ClarkTrans_finish),
    .busy(),
    .finish(ParkTrans_finish),
    
    .IALPHA(IALPHA),
    .IBETA(IBETA),
    .SINval(SINval),
    .COSval(COSval),

    .ID(ID),
    .IQ(IQ)
    );

VectorCtrler VectorCtrler_inst(    
    .clk(clk),
    .rst(rst),
    .trig(ParkTrans_finish),
    .busy(),
    .finish(finish),
    .DKp(DKp),
    .DKi(DKi),
    .DCompensate(DCompensate),
    .QKp(QKp),
    .QKi(QKi),
    .QCompensate(QCompensate),   
    .LimitCircleRadiusHW(LimitCircleRadiusHW), 
    .LimitCircleRadius(LimitCircleRadius),
    .LimitMode_HDLQ(LimitMode_HDLQ),
    .DRef(DRef),
    .DFeedback(ID),
    .DUiAcc(DUiAcc),
    .QRef(QRef),
    .QFeedback(IQ),
    .QUiAcc(QUiAcc),
    .SINval(ISINval),
    .COSval(ICOSval),
    .DUiAcc_new(DUiAcc_new),
    .QUiAcc_new(QUiAcc_new),
    .UD(UD),
    .UQ(UQ),
    .UALPHA(UALPHA),
    .UBETA(UBETA)
    ); 
    
endmodule         



























