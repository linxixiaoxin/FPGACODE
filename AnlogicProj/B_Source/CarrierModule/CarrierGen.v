/*
CarrierGen CarrierGen_inst(
	.clk(),
	.rst(),
    .CounterCNT(),
    .CounterDIR(),
    .CounterPeriod(),
    .ZeroPluse(),
    .PeriodPluse(),
    .ACRTrig(),
    .EncoderTrig()
	);
*/
module  CarrierGen (
	input				clk,//100Mhz
	input				rst,
	
    output  reg [15:0]  CounterCNT,
    output  reg         CounterDIR,
    output      [15:0]  CounterPeriod,
    
    output              ZeroPluse,
    output              PeriodPluse,
    output              ACRTrig,
    output              EncoderTrig,
    output              INTOut
	);
    
    localparam  CNTPeriod = 16'd6249;//6250*10ns = 62.5us half period, Tpwm = 125us,8khz  //3125,16K
    localparam  ACRTrigLead   = 16'd250;//the lead of Dutyclcye-update pluse(ZeroPluse&PeriodPluse) is ACRTrig pluse

    assign CounterPeriod = CNTPeriod;

    wire    [15:0]  ACRTrigPos_P;//ACRTrigPos during Counter up
    wire    [15:0]  ACRTrigPos_N;//ACRTrigPos during Counter down
    
    assign ACRTrigPos_P = CNTPeriod - ACRTrigLead;
    assign ACRTrigPos_N = ACRTrigLead;
    
    reg             ACRTrig_P;
    reg             ACRTrig_N;
    reg             EncoderTrig_P;
    reg             EncoderTrig_N;
    
    
    //Counter go
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CounterCNT<=16'd0;
        end
        else begin
            if(CounterDIR==1'b0)begin//Count up
                if(CounterCNT<CNTPeriod)
                    CounterCNT<=CounterCNT+1'b1;
                else
                    CounterCNT<=CNTPeriod;
            end
            else begin//Count down
                if(CounterCNT>16'd0)
                    CounterCNT<=CounterCNT-1'b1;
                else
                    CounterCNT<=16'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CounterDIR<=1'b0;
        end
        else begin
            if((CounterDIR==1'b0)&&(CounterCNT==CNTPeriod))
                CounterDIR<=1'b1;
            else if((CounterDIR==1'b1)&&(CounterCNT==16'd0))
                CounterDIR<=1'b0;
            else
                CounterDIR<=CounterDIR;
        end
    end
    
    //Trigs gen
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            ACRTrig_P<=1'b0;
            ACRTrig_N<=1'b0;
            EncoderTrig_P<=1'b0;
            EncoderTrig_N<=1'b0;
        end
        else begin
            if(CounterDIR==1'b0)begin
                if(CounterCNT==ACRTrigPos_P)
                    ACRTrig_P<=1'b1;
                else
                    ACRTrig_P<=1'b0;
            end
            else begin
                if(CounterCNT==ACRTrigPos_N)
                    ACRTrig_N<=1'b1;
                else
                    ACRTrig_N<=1'b0;
            end
        end
    end
    
    assign ACRTrig      =   ACRTrig_P||ACRTrig_N;
    assign EncoderTrig  =   ZeroPluse||PeriodPluse;
    assign ZeroPluse    =   (CounterCNT==16'd0)&&(CounterDIR==1'b1);
    assign PeriodPluse  =   (CounterCNT==CNTPeriod)&&(CounterDIR==1'b0);
    
    reg [7:0]   HoldCNT;
    localparam  INTPluseHoldTime = 8'd99;//unit 10ns;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            HoldCNT<=INTPluseHoldTime;
        else begin
            if(ZeroPluse||PeriodPluse)
                HoldCNT<=8'd0;
            else begin
                if(HoldCNT<INTPluseHoldTime)
                    HoldCNT<=HoldCNT+8'd1;
                else
                    HoldCNT<=INTPluseHoldTime;
            end
        end
    end
    assign INTOut = (HoldCNT!=INTPluseHoldTime);
    
    
endmodule

	