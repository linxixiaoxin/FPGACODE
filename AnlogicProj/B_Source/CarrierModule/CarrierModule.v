module  CarrierModule (
	input				clk,//100Mhz
	input				rst,
    //data & addr bus
    input               CS,
    input               RDLWRH,
    input       [15:0]  ADDR,
    input       [15:0]  WRDATA,
    output      [15:0]  RDDATA,
    
    //ACR interface
    output              EncoderTrig,
    output              ACRTrig,
    output              ZEROTrig,
    output              PeriodTrig,
    output              INTOut,
    output      [15:0]  CounterPeriod,
    
    //==========Axis1
    //ctrl input
    input               Axis1_PWMUNLOCK,
    input       [15:0]  Axis1_DutyA,
    input       [15:0]  Axis1_DutyB,
    input       [15:0]  Axis1_DutyC,  
    output              Axis1_CalEN,
    //output
    output              Axis1_PWMUP,
    output              Axis1_PWMUN,
    output              Axis1_PWMVP,
    output              Axis1_PWMVN,
    output              Axis1_PWMWP,
    output              Axis1_PWMWN,
    //==========Axis2
    //ctrl input
    input               Axis2_PWMUNLOCK,
    input       [15:0]  Axis2_DutyA,
    input       [15:0]  Axis2_DutyB,
    input       [15:0]  Axis2_DutyC,
    output              Axis2_CalEN,  
    //output
    output              Axis2_PWMUP,
    output              Axis2_PWMUN,
    output              Axis2_PWMVP,
    output              Axis2_PWMVN,
    output              Axis2_PWMWP,
    output              Axis2_PWMWN,
    //==========Axis3
    //ctrl input
    input               Axis3_PWMUNLOCK,
    input       [15:0]  Axis3_DutyA,
    input       [15:0]  Axis3_DutyB,
    input       [15:0]  Axis3_DutyC,
    output              Axis3_CalEN,     
    //output
    output              Axis3_PWMUP,
    output              Axis3_PWMUN,
    output              Axis3_PWMVP,
    output              Axis3_PWMVN,
    output              Axis3_PWMWP,
    output              Axis3_PWMWN,
    //==========Axis4
    //ctrl input
    input               Axis4_PWMUNLOCK,
    input       [15:0]  Axis4_DutyA,
    input       [15:0]  Axis4_DutyB,
    input       [15:0]  Axis4_DutyC, 
    output              Axis4_CalEN,    
    //output
    output              Axis4_PWMUP,
    output              Axis4_PWMUN,
    output              Axis4_PWMVP,
    output              Axis4_PWMVN,
    output              Axis4_PWMWP,
    output              Axis4_PWMWN    
    
	);
    
    wire        Axis1_Bootstrap;
    wire        Axis1_PWMEN;
    wire        Axis2_Bootstrap;
    wire        Axis2_PWMEN;
    wire        Axis3_Bootstrap;
    wire        Axis3_PWMEN;
    wire        Axis4_Bootstrap;
    wire        Axis4_PWMEN;
    assign Axis1_CalEN = (Axis1_PWMEN==1'b1)&&(Axis1_Bootstrap==1'b0);
    assign Axis2_CalEN = (Axis2_PWMEN==1'b1)&&(Axis2_Bootstrap==1'b0);
    assign Axis3_CalEN = (Axis3_PWMEN==1'b1)&&(Axis3_Bootstrap==1'b0);
    assign Axis4_CalEN = (Axis4_PWMEN==1'b1)&&(Axis4_Bootstrap==1'b0);
    
RegSpcae_CarrierModule RegSpcae_CarrierModule(
    .clk(clk),
    .rst(rst),
    //data & addr bus
    .CS(CS),
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .RDDATA(RDDATA),
    //inner reg interface
    .Axis1_Bootstrap(Axis1_Bootstrap),
    .Axis1_PWMEN(Axis1_PWMEN),
    .Axis1_PWMUNLOCK(Axis1_PWMUNLOCK),
    .Axis2_Bootstrap(Axis2_Bootstrap),
    .Axis2_PWMEN(Axis2_PWMEN),
    .Axis2_PWMUNLOCK(Axis2_PWMUNLOCK),
    .Axis3_Bootstrap(Axis3_Bootstrap),
    .Axis3_PWMEN(Axis3_PWMEN),
    .Axis3_PWMUNLOCK(Axis3_PWMUNLOCK),
    .Axis4_Bootstrap(Axis4_Bootstrap),
    .Axis4_PWMEN(Axis4_PWMEN),
    .Axis4_PWMUNLOCK(Axis4_PWMUNLOCK)
    );   
    
    wire    [15:0]  CounterCNT;
    wire            CounterDIR;
    wire            ZeroPluse;
    wire            PeriodPluse;
    
CarrierGen CarrierGen_inst(
	.clk(clk),
	.rst(rst),
    .CounterCNT(CounterCNT),
    .CounterDIR(CounterDIR),
    .CounterPeriod(CounterPeriod),
    .ZeroPluse(ZeroPluse),
    .PeriodPluse(PeriodPluse),
    .ACRTrig(ACRTrig),
    .EncoderTrig(EncoderTrig),
    .INTOut(INTOut)
	);
    
PwmGen PwmGen_Axis1(
    .clk(clk),
    .rst(rst),
    .CounterCNT(CounterCNT),
    .CounterDIR(CounterDIR),
    .ZeroPluse(ZeroPluse),    
    .PeriodPluse(PeriodPluse),
    .CounterPeriod(CounterPeriod),
    .PWMUNLOCK(Axis1_PWMUNLOCK),
    .PWMEN(Axis1_PWMEN),
    .BootstrapInit(Axis1_Bootstrap),
    .DutyA(Axis1_DutyA),
    .DutyB(Axis1_DutyB),
    .DutyC(Axis1_DutyC),
    .PWMU_P(Axis1_PWMUP),
    .PWMU_N(Axis1_PWMUN),
    .PWMV_P(Axis1_PWMVP),
    .PWMV_N(Axis1_PWMVN),
    .PWMW_P(Axis1_PWMWP),
    .PWMW_N(Axis1_PWMWN)
    );
    
PwmGen PwmGen_Axis2(
    .clk(clk),
    .rst(rst),
    .CounterCNT(CounterCNT),
    .CounterDIR(CounterDIR),
    .ZeroPluse(ZeroPluse),    
    .PeriodPluse(PeriodPluse),
    .CounterPeriod(CounterPeriod),
    .PWMUNLOCK(Axis2_PWMUNLOCK),
    .PWMEN(Axis2_PWMEN),
    .BootstrapInit(Axis2_Bootstrap),
    .DutyA(Axis2_DutyA),
    .DutyB(Axis2_DutyB),
    .DutyC(Axis2_DutyC),
    .PWMU_P(Axis2_PWMUP),
    .PWMU_N(Axis2_PWMUN),
    .PWMV_P(Axis2_PWMVP),
    .PWMV_N(Axis2_PWMVN),
    .PWMW_P(Axis2_PWMWP),
    .PWMW_N(Axis2_PWMWN)
    );    
    
PwmGen PwmGen_Axis3(
    .clk(clk),
    .rst(rst),
    .CounterCNT(CounterCNT),
    .CounterDIR(CounterDIR),
    .ZeroPluse(ZeroPluse),    
    .PeriodPluse(PeriodPluse),
    .CounterPeriod(CounterPeriod),
    .PWMUNLOCK(Axis3_PWMUNLOCK),
    .PWMEN(Axis3_PWMEN),
    .BootstrapInit(Axis3_Bootstrap),
    .DutyA(Axis3_DutyA),
    .DutyB(Axis3_DutyB),
    .DutyC(Axis3_DutyC),
    .PWMU_P(Axis3_PWMUP),
    .PWMU_N(Axis3_PWMUN),
    .PWMV_P(Axis3_PWMVP),
    .PWMV_N(Axis3_PWMVN),
    .PWMW_P(Axis3_PWMWP),
    .PWMW_N(Axis3_PWMWN)
    );    

PwmGen PwmGen_Axis4(
    .clk(clk),
    .rst(rst),
    .CounterCNT(CounterCNT),
    .CounterDIR(CounterDIR),
    .ZeroPluse(ZeroPluse),    
    .PeriodPluse(PeriodPluse),
    .CounterPeriod(CounterPeriod),
    .PWMUNLOCK(Axis4_PWMUNLOCK),
    .PWMEN(Axis4_PWMEN),
    .BootstrapInit(Axis4_Bootstrap),
    .DutyA(Axis4_DutyA),
    .DutyB(Axis4_DutyB),
    .DutyC(Axis4_DutyC),
    .PWMU_P(Axis4_PWMUP),
    .PWMU_N(Axis4_PWMUN),
    .PWMV_P(Axis4_PWMVP),
    .PWMV_N(Axis4_PWMVN),
    .PWMW_P(Axis4_PWMWP),
    .PWMW_N(Axis4_PWMWN)
    );        
    
    assign ZEROTrig = ZeroPluse;
    assign PeriodTrig = PeriodPluse;
    
    
endmodule

	