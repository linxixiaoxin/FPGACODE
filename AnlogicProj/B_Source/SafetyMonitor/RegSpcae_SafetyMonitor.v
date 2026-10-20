module RegSpcae_SafetyMonitor(
    input                       clk,
    input                       rst,
    //data & addr bus
    input                       CS,
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,
    output  reg         [15:0]  RDDATA,
    //inner reg interface
    input                       Axis1_IPMFault,
    input                       Axis2_IPMFault,
    input                       Axis3_IPMFault,
    input                       Axis4_IPMFault,
    input                       Axis1_OC,
    input                       Axis2_OC,
    input                       Axis3_OC,
    input                       Axis4_OC,
    //Unlock carrier module
    output  reg                 Axis1_PWMUNLOCK,
    output  reg                 Axis2_PWMUNLOCK,
    output  reg                 Axis3_PWMUNLOCK,
    output  reg                 Axis4_PWMUNLOCK,  
    //pwm output channel enbale
    output                      Axis1_PWMEN,
    output                      Axis2_PWMEN,
    output                      Axis3_PWMEN,
    output                      Axis4_PWMEN,  
    
    output                      STOout,
    
    output                      SysResetSig
    );
    
    wire            RD;
    wire            WR;
    assign  RD = CS&&(RDLWRH==1'b0);
    assign  WR = CS&&(RDLWRH==1'b1);
    
    wire [15:0] FPGALoadedFlag;
    assign FPGALoadedFlag = 16'h5AF0;

    wire [15:0] Version_H;
    wire [15:0] Version_L;
    assign Version_H = 16'h01_00;
    assign Version_L = 16'h00_01;
    
    reg [15:0]  SysResetCTRL;
    
    reg [31:0]  FreeRunCNTer;
    
    reg     [15:0]  ProtectFuncEnable;   
    wire            WatchdogEN;
    wire            Axis4_IPMFaultMonitorEN;
    wire            Axis4_OCFaultMonitorEN;
    wire            Axis3_IPMFaultMonitorEN;
    wire            Axis3_OCFaultMonitorEN;
    wire            Axis2_IPMFaultMonitorEN;
    wire            Axis2_OCFaultMonitorEN;
    wire            Axis1_IPMFaultMonitorEN;
    wire            Axis1_OCFaultMonitorEN;
    assign WatchdogEN               =   ProtectFuncEnable[15];
    assign Axis4_IPMFaultMonitorEN  =   ProtectFuncEnable[7];
    assign Axis4_OCFaultMonitorEN   =   ProtectFuncEnable[6];
    assign Axis3_IPMFaultMonitorEN  =   ProtectFuncEnable[5];
    assign Axis3_OCFaultMonitorEN   =   ProtectFuncEnable[4];
    assign Axis2_IPMFaultMonitorEN  =   ProtectFuncEnable[3];
    assign Axis2_OCFaultMonitorEN   =   ProtectFuncEnable[2];
    assign Axis1_IPMFaultMonitorEN  =   ProtectFuncEnable[1];
    assign Axis1_OCFaultMonitorEN   =   ProtectFuncEnable[0];
    
    
    reg     [15:0]  ProtectLockedFlagClear; 
    wire            WatchdogFoCLR;
    wire            Axis4_IPMFoCLR;
    wire            Axis4_OCFoCLR;
    wire            Axis3_IPMFoCLR;
    wire            Axis3_OCFoCLR;
    wire            Axis2_IPMFoCLR;
    wire            Axis2_OCFoCLR;
    wire            Axis1_IPMFoCLR;
    wire            Axis1_OCFoCLR;
    assign WatchdogFoCLR            =   ProtectLockedFlagClear[15];
    assign Axis4_IPMFoCLR           =   ProtectLockedFlagClear[7];
    assign Axis4_OCFoCLR            =   ProtectLockedFlagClear[6];
    assign Axis3_IPMFoCLR           =   ProtectLockedFlagClear[5];
    assign Axis3_OCFoCLR            =   ProtectLockedFlagClear[4];
    assign Axis2_IPMFoCLR           =   ProtectLockedFlagClear[3];
    assign Axis2_OCFoCLR            =   ProtectLockedFlagClear[2];
    assign Axis1_IPMFoCLR           =   ProtectLockedFlagClear[1];
    assign Axis1_OCFoCLR            =   ProtectLockedFlagClear[0];
    
    
    reg     [7:0]   Timer_1usCNT;
    wire            Timer_1usPluse;
    reg     [15:0]  WatchDog_Period;//unit us
    reg     [15:0]  WatchDog_CNT;
    reg             WatchDog_FeedPluse;
    
    
    wire            WatchDog_overflow;
    reg             WatchDog_overflow_Lock;
    reg             Axis4_IPMFo_Lock;
    reg             Axis4_OC_Lock;
    reg             Axis3_IPMFo_Lock;
    reg             Axis3_OC_Lock;
    reg             Axis2_IPMFo_Lock;
    reg             Axis2_OC_Lock;
    reg             Axis1_IPMFo_Lock;
    reg             Axis1_OC_Lock;

    
    reg             Axis4_IPMFault_sync0;
    reg             Axis4_IPMFault_sync1;
    reg             Axis3_IPMFault_sync0;
    reg             Axis3_IPMFault_sync1;
    reg             Axis2_IPMFault_sync0;
    reg             Axis2_IPMFault_sync1;
    reg             Axis1_IPMFault_sync0;
    reg             Axis1_IPMFault_sync1;
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            Axis4_IPMFault_sync0<=1'b0;
            Axis4_IPMFault_sync1<=1'b0;
            Axis3_IPMFault_sync0<=1'b0;
            Axis3_IPMFault_sync1<=1'b0;
            Axis2_IPMFault_sync0<=1'b0;
            Axis2_IPMFault_sync1<=1'b0;
            Axis1_IPMFault_sync0<=1'b0;
            Axis1_IPMFault_sync1<=1'b0;
        end
        else begin
            Axis4_IPMFault_sync0<=Axis4_IPMFault;
            Axis4_IPMFault_sync1<=Axis4_IPMFault_sync0;
            Axis3_IPMFault_sync0<=Axis3_IPMFault;
            Axis3_IPMFault_sync1<=Axis3_IPMFault_sync0;
            Axis2_IPMFault_sync0<=Axis2_IPMFault;
            Axis2_IPMFault_sync1<=Axis2_IPMFault_sync0;
            Axis1_IPMFault_sync0<=Axis1_IPMFault;
            Axis1_IPMFault_sync1<=Axis1_IPMFault_sync0;
        end
    end 
    
    
    wire    [15:0]  FaultStateRT;
    wire    [15:0]  FaultStateLocked;
    assign FaultStateRT = {WatchDog_overflow,7'd0,
                            Axis4_IPMFault_sync1,Axis4_OC,
                            Axis3_IPMFault_sync1,Axis3_OC,
                            Axis2_IPMFault_sync1,Axis2_OC,
                            Axis1_IPMFault_sync1,Axis1_OC};
    
    assign FaultStateLocked = {WatchDog_overflow_Lock,7'd0,
                                Axis4_IPMFo_Lock,Axis4_OC_Lock,
                                Axis3_IPMFo_Lock,Axis3_OC_Lock,
                                Axis2_IPMFo_Lock,Axis2_OC_Lock,
                                Axis1_IPMFo_Lock,Axis1_OC_Lock};
                                
    reg     [3:0]  PWMOutputChannelEN;
    
    
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            FreeRunCNTer<=32'd0;
        end
        else begin
            FreeRunCNTer<=FreeRunCNTer+32'd1;
        end
    end
    

    //regs Write===========================================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            WatchDog_Period<=16'd100;//1ms set
            ProtectFuncEnable<=16'd0;
            ProtectLockedFlagClear<=16'd0;
            WatchDog_FeedPluse<=1'b0;
            PWMOutputChannelEN<=16'd0;
            SysResetCTRL<=16'd0;
        end
        else begin
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0003:SysResetCTRL<=WRDATA;
                16'h0006:WatchDog_Period<=WRDATA;
                16'h000A:ProtectFuncEnable<=WRDATA;
                endcase
            end
            
            if((WR==1'b1)&&(ADDR==16'h000B))
                ProtectLockedFlagClear<=WRDATA;
            else begin
                if(ProtectLockedFlagClear!=16'd0)
                    ProtectLockedFlagClear<=16'd0;
            end
            
            if((WR==1'b1)&&(ADDR==16'h0007)&&(WRDATA==16'h5AA5))
                WatchDog_FeedPluse<=1'b1;
            else begin
                if(WatchDog_FeedPluse==1'b1)
                    WatchDog_FeedPluse<=1'b0;
            end
            
            if(Axis4_IPMFo_Lock||Axis4_OC_Lock||WatchDog_overflow_Lock)
                PWMOutputChannelEN[3]<=1'b0;
            else begin
                if((WR==1'b1)&&(ADDR==16'h000F))
                    PWMOutputChannelEN[3]<=WRDATA[3];
            end
            if(Axis3_IPMFo_Lock||Axis3_OC_Lock||WatchDog_overflow_Lock)
                PWMOutputChannelEN[2]<=1'b0;
            else begin
                if((WR==1'b1)&&(ADDR==16'h000F))
                    PWMOutputChannelEN[2]<=WRDATA[2];
            end
            if(Axis2_IPMFo_Lock||Axis2_OC_Lock||WatchDog_overflow_Lock)
                PWMOutputChannelEN[1]<=1'b0;
            else begin
                if((WR==1'b1)&&(ADDR==16'h000F))
                    PWMOutputChannelEN[1]<=WRDATA[1];
            end
            if(Axis1_IPMFo_Lock||Axis1_OC_Lock||WatchDog_overflow_Lock)
                PWMOutputChannelEN[0]<=1'b0;
            else begin
                if((WR==1'b1)&&(ADDR==16'h000F))
                    PWMOutputChannelEN[0]<=WRDATA[0];
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
                16'h0:RDDATA<=FPGALoadedFlag;
                16'h1:RDDATA<=Version_H;
                16'h2:RDDATA<=Version_L;
                16'h3:RDDATA<=FreeRunCNTer[22:7];
                16'h6:RDDATA<=WatchDog_Period;
                16'h8:RDDATA<=FaultStateRT;
                16'h9:RDDATA<=FaultStateLocked;
                16'hA:RDDATA<=ProtectFuncEnable;
                16'hF:RDDATA<={12'd0,PWMOutputChannelEN};
                default:RDDATA<=16'd0;
                endcase
            end
        end
    end 
    
    //Regs deal===========================================================
    //======watch dog=======================
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            Timer_1usCNT<=8'd0;
        else begin
            if(WatchdogEN)begin
                if(Timer_1usCNT<8'd99)//counter base 10ns
                    Timer_1usCNT<=Timer_1usCNT+8'd1;
                else
                    Timer_1usCNT<=8'd0;
            end
            else
                Timer_1usCNT<=8'd0;
        end
    end
    assign Timer_1usPluse = (Timer_1usCNT==8'd99);

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            WatchDog_CNT<=16'd0;
        else begin
            if(WatchdogEN)begin
                if(WatchDog_FeedPluse)
                    WatchDog_CNT<=16'd0;
                else begin
                    if(Timer_1usPluse)begin//counter base 1us
                        if(WatchDog_CNT<WatchDog_Period)
                            WatchDog_CNT<=WatchDog_CNT+1'b1;
                        else
                            WatchDog_CNT<=WatchDog_Period;
                    end
                end
            end
            else
                WatchDog_CNT<=16'd0;
        end
    end
    
    assign WatchDog_overflow = (WatchDog_CNT>=WatchDog_Period);
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            WatchDog_overflow_Lock<=1'b0;
        else begin
            if(WatchdogFoCLR||(WatchdogEN==1'b0))
                WatchDog_overflow_Lock<=1'b0;
            else begin
                if(WatchDog_overflow)
                    WatchDog_overflow_Lock<=1'b1;
            end
        end
    end
    

    //======IPMfault & OC===================
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Axis4_IPMFo_Lock<=1'b0;
            Axis4_OC_Lock<=1'b0;
            Axis3_IPMFo_Lock<=1'b0;
            Axis3_OC_Lock<=1'b0;
            Axis2_IPMFo_Lock<=1'b0;
            Axis2_OC_Lock<=1'b0;
            Axis1_IPMFo_Lock<=1'b0;
            Axis1_OC_Lock<=1'b0;
        end
        else begin
            if(Axis4_IPMFoCLR||(Axis4_IPMFaultMonitorEN==1'b0))
                Axis4_IPMFo_Lock<=1'b0;
            else begin
                if(Axis4_IPMFault_sync1)
                    Axis4_IPMFo_Lock<=1'b1;
            end
            if(Axis4_OCFoCLR||(Axis4_OCFaultMonitorEN==1'b0))
                Axis4_OC_Lock<=1'b0;
            else begin
                if(Axis4_OC)
                    Axis4_OC_Lock<=1'b1;
            end
            
            
            if(Axis3_IPMFoCLR||(Axis3_IPMFaultMonitorEN==1'b0))
                Axis3_IPMFo_Lock<=1'b0;
            else begin
                if(Axis3_IPMFault_sync1)
                    Axis3_IPMFo_Lock<=1'b1;
            end
            if(Axis3_OCFoCLR||(Axis3_OCFaultMonitorEN==1'b0))
                Axis3_OC_Lock<=1'b0;
            else begin
                if(Axis3_OC)
                    Axis3_OC_Lock<=1'b1;
            end
            
            
            if(Axis2_IPMFoCLR||(Axis2_IPMFaultMonitorEN==1'b0))
                Axis2_IPMFo_Lock<=1'b0;
            else begin
                if(Axis2_IPMFault_sync1)
                    Axis2_IPMFo_Lock<=1'b1;
            end
            if(Axis2_OCFoCLR||(Axis2_OCFaultMonitorEN==1'b0))
                Axis2_OC_Lock<=1'b0;
            else begin
                if(Axis2_OC)
                    Axis2_OC_Lock<=1'b1;
            end
            
            
            if(Axis1_IPMFoCLR||(Axis1_IPMFaultMonitorEN==1'b0))
                Axis1_IPMFo_Lock<=1'b0;
            else begin
                if(Axis1_IPMFault_sync1)
                    Axis1_IPMFo_Lock<=1'b1;
            end
            if(Axis1_OCFoCLR||(Axis1_OCFaultMonitorEN==1'b0))
                Axis1_OC_Lock<=1'b0;
            else begin
                if(Axis1_OC)
                    Axis1_OC_Lock<=1'b1;
            end
        end
    end


    //======PWM output channel enbale & PWM unlock===================
    assign Axis4_PWMEN = PWMOutputChannelEN[3];
    assign Axis3_PWMEN = PWMOutputChannelEN[2];
    assign Axis2_PWMEN = PWMOutputChannelEN[1];
    assign Axis1_PWMEN = PWMOutputChannelEN[0];
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Axis4_PWMUNLOCK<=1'b0;
            Axis3_PWMUNLOCK<=1'b0;
            Axis2_PWMUNLOCK<=1'b0;
            Axis1_PWMUNLOCK<=1'b0;
        end
        else begin
            if(WatchDog_overflow_Lock)begin
                Axis4_PWMUNLOCK<=1'b0;
                Axis3_PWMUNLOCK<=1'b0;
                Axis2_PWMUNLOCK<=1'b0;
                Axis1_PWMUNLOCK<=1'b0;
            end
            else begin
                if(Axis4_IPMFo_Lock||Axis4_OC_Lock)
                    Axis4_PWMUNLOCK<=1'b0;
                else
                    Axis4_PWMUNLOCK<=Axis4_PWMEN;//no fault && PWM output channel enable, unlock PWMGen
                    
                if(Axis3_IPMFo_Lock||Axis3_OC_Lock)
                    Axis3_PWMUNLOCK<=1'b0;
                else
                    Axis3_PWMUNLOCK<=Axis3_PWMEN;//no fault && PWM output channel enable, unlock PWMGen
                    
                if(Axis2_IPMFo_Lock||Axis2_OC_Lock)
                    Axis2_PWMUNLOCK<=1'b0;
                else
                    Axis2_PWMUNLOCK<=Axis2_PWMEN;//no fault && PWM output channel enable, unlock PWMGen
                    
                if(Axis1_IPMFo_Lock||Axis1_OC_Lock)
                    Axis1_PWMUNLOCK<=1'b0;
                else
                    Axis1_PWMUNLOCK<=Axis1_PWMEN;//no fault && PWM output channel enable, unlock PWMGen
            end
        end
    end
    
    //======STO deal========================
    assign STOout = 1'b0;
    
    
    
    assign SysResetSig = (SysResetCTRL==16'hFFAA);
    
endmodule
