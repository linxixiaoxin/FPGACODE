module PhyManageMDC(
    input               clk,//input clk 100Mhz
    input               rst,//input rst,low active
    input               trig,
    output  reg         finished,//process finish pluse,1clk(100Mhz)

    output  reg [7:0]   ActivePluseCNT,
    output              ActivePluse,

    output  reg         MDC//1Mhz clk, normal high
    );

    //State Reg && Finish signal
    reg             ProcessState;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            ProcessState<=1'b0;
        else begin
            if(ProcessState==1'b0)begin
                if(trig==1'b1)
                    ProcessState<=1'b1;
            end
            else begin
                if((ActivePluseCNT==8'd64)&&(CNT==8'd49))
                    ProcessState<=1'b0;
            end
        end
    end

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            finished<=1'b0;
        else begin
            if((ActivePluseCNT==8'd64)&&(CNT==8'd49))
                finished<=1'b1;
            else
                finished<=1'b0;
        end
    end

    reg     [7:0]   CNT;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            CNT<=8'd0;
        else begin
            if(ProcessState==1'b0)
                CNT<=8'd0;
            else begin
                if(CNT<8'd99)
                    CNT<=CNT+1'b1;
                else
                    CNT<=8'd0;
            end
        end
    end
    always @ (*)begin
        if(ProcessState==1'b1)begin
            if(CNT<8'd50)
                MDC<=1'b1;
            else
                MDC<=1'b0;
        end
        else
            MDC<=1'b1;
    end

    assign ActivePluse = (CNT==8'd49);

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            ActivePluseCNT<=8'd0;
        else begin
            if(ProcessState==1'b0)
                ActivePluseCNT<=8'd0;
            else begin
                if(ActivePluse)
                    ActivePluseCNT<=ActivePluseCNT+1'b1;
            end
        end
    end





endmodule
