/*
PwmGen PwmGen_inst(
    .clk(),
    .rst(),
    .CounterCNT(),
    .CounterDIR(),
    .ZeroPluse(),    
    .PeriodPluse(),
    .CounterPeriod(),
    .PWMUNLOCK(),
    .PWMEN(),
    .BootstrapInit(),
    .DutyA(),
    .DutyB(),
    .DutyC(),
    .PWMU_P(),
    .PWMU_N(),
    .PWMV_P(),
    .PWMV_N(),
    .PWMW_P(),
    .PWMW_N()
    );
*/
module  PwmGen (
    input               clk,//100Mhz
    input               rst,
    //carrier interface
    input       [15:0]  CounterCNT,
    input               CounterDIR,
    input               ZeroPluse,    
    input               PeriodPluse,
    input       [15:0]  CounterPeriod,

    //Ctrl interface
    input               PWMUNLOCK,
    input               PWMEN,
    input               BootstrapInit,
    //ACR interface
    input       [15:0]  DutyA,
    input       [15:0]  DutyB,
    input       [15:0]  DutyC,
    //output
    output  reg         PWMU_P,
    output  reg         PWMU_N,
    output  reg         PWMV_P,
    output  reg         PWMV_N,
    output  reg         PWMW_P,
    output  reg         PWMW_N
    );
    
    localparam MinPulseWidth=   16'd400;//unit 10ns,400-4us
    localparam DeadTime     =   16'd200;//16'd200;//unit 10ns, 200-2us
    
    wire    [15:0]  DeadTime_half;
    wire    [15:0]  MinPulseWidth_half;
    
    wire    [15:0]  CMPa;
    wire    [15:0]  CMPb;
    wire    [15:0]  CMPc;
    
    wire	[15:0]	CMPMAX;
    wire	[15:0]	CMPMIN;
    wire    [15:0]  CMPa_limited;
    wire    [15:0]  CMPb_limited;
    wire    [15:0]  CMPc_limited;
    
    reg     [15:0]  CMPaH_Act;
    reg     [15:0]  CMPaL_Act;
    reg     [15:0]  CMPbH_Act;
    reg     [15:0]  CMPbL_Act;
    reg     [15:0]  CMPcH_Act;
    reg     [15:0]  CMPcL_Act;
    
    reg             PWMEN_Sync;
    wire            PWMEN_Inner;
    
    reg             BootstrapInit_Sync;
    wire            BootstrapInit_Inner;
    

    wire            PWMU_P_pre;
    wire            PWMU_N_pre;
    wire            PWMV_P_pre;
    wire            PWMV_N_pre;
    wire            PWMW_P_pre;
    wire            PWMW_N_pre;
    
    
    assign DeadTime_half = {DeadTime[15],DeadTime[15:1]};
    assign MinPulseWidth_half = {MinPulseWidth[15],MinPulseWidth[15:1]};
    
    assign CMPa = CounterPeriod - DutyA;
    assign CMPb = CounterPeriod - DutyB;
    assign CMPc = CounterPeriod - DutyC;
    
    assign CMPMAX=CounterPeriod-MinPulseWidth_half-DeadTime_half;
    assign CMPMIN=MinPulseWidth_half+DeadTime_half;
        
    assign CMPa_limited = (CMPa<CMPMIN)?CMPMIN:((CMPa>CMPMAX)?CMPMAX:CMPa);//MinPulseWidth limited
    assign CMPb_limited = (CMPb<CMPMIN)?CMPMIN:((CMPb>CMPMAX)?CMPMAX:CMPb);//MinPulseWidth limited
    assign CMPc_limited = (CMPc<CMPMIN)?CMPMIN:((CMPc>CMPMAX)?CMPMAX:CMPc);//MinPulseWidth limited	
	
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CMPaH_Act<=16'hFFFF;
            CMPaL_Act<=16'hFFFF;
            CMPbH_Act<=16'hFFFF;
            CMPbL_Act<=16'hFFFF;
            CMPcH_Act<=16'hFFFF;
            CMPcL_Act<=16'hFFFF;
        end
        else begin
            if(ZeroPluse||PeriodPluse)begin
                CMPaH_Act<=CMPa_limited+DeadTime_half;
                CMPaL_Act<=CMPa_limited-DeadTime_half;
                CMPbH_Act<=CMPb_limited+DeadTime_half;
                CMPbL_Act<=CMPb_limited-DeadTime_half;
                CMPcH_Act<=CMPc_limited+DeadTime_half;
                CMPcL_Act<=CMPc_limited-DeadTime_half;
            end
        end
    end

    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            PWMEN_Sync<=1'b0;
            BootstrapInit_Sync<=1'b0;
        end
        else begin
            if(ZeroPluse||PeriodPluse)begin
                PWMEN_Sync<=PWMEN;
                BootstrapInit_Sync<=BootstrapInit;
            end
        end
    end
    assign PWMEN_Inner = PWMEN_Sync && PWMUNLOCK;
    assign BootstrapInit_Inner = BootstrapInit_Sync && PWMUNLOCK;
    
    assign PWMU_P_pre = (BootstrapInit_Inner==1'b1)?1'b0:((PWMEN_Inner==1'b1)?((CounterCNT>CMPaH_Act)?1'b1:1'b0):1'b0);
    assign PWMU_N_pre = (BootstrapInit_Inner==1'b1)?1'b1:((PWMEN_Inner==1'b1)?((CounterCNT<CMPaL_Act)?1'b1:1'b0):1'b0);
    
    assign PWMV_P_pre = (BootstrapInit_Inner==1'b1)?1'b0:((PWMEN_Inner==1'b1)?((CounterCNT>CMPbH_Act)?1'b1:1'b0):1'b0);
    assign PWMV_N_pre = (BootstrapInit_Inner==1'b1)?1'b1:((PWMEN_Inner==1'b1)?((CounterCNT<CMPbL_Act)?1'b1:1'b0):1'b0);
    
    assign PWMW_P_pre = (BootstrapInit_Inner==1'b1)?1'b0:((PWMEN_Inner==1'b1)?((CounterCNT>CMPcH_Act)?1'b1:1'b0):1'b0);
    assign PWMW_N_pre = (BootstrapInit_Inner==1'b1)?1'b1:((PWMEN_Inner==1'b1)?((CounterCNT<CMPcL_Act)?1'b1:1'b0):1'b0); 


    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            PWMU_P<=1'b0;
            PWMU_N<=1'b0;
            PWMV_P<=1'b0;
            PWMV_N<=1'b0;
            PWMW_P<=1'b0;
            PWMW_N<=1'b0;
        end
        else begin
            PWMU_P<=PWMU_P_pre;
            PWMU_N<=PWMU_N_pre;
            PWMV_P<=PWMV_P_pre;
            PWMV_N<=PWMV_N_pre;
            PWMW_P<=PWMW_P_pre;
            PWMW_N<=PWMW_N_pre;
        end
    end
    
endmodule
