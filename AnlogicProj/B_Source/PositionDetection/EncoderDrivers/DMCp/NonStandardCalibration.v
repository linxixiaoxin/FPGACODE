module NonStandardCalibration(
    input                   clk,
    input                   rst,
    
    input                   CalibrationEN,
    output          [3:0]   CalibrationState, 
    
    output  reg             TXRXSwitch,
    output  reg             TXTrig,
    output  reg     [7:0]   TXDATA,
    input                   TXedPluse,
    input                   RxedPluse,
    input           [7:0]   RXDATA
    );
    wire            TXFrameTrig;
    reg             TXFrameFinished;
    reg     [7:0]   TXEN_DelayCNT;
    localparam  TXEN_DelayCNT_SET = 8'd12;
    reg [3:0]TXBYTECNT;
    reg [3:0]TXRequestCNT;
    reg [31:0]  DelayCount;
    localparam DelayCountRef = 32'd2000000;
   
    //======FSM=====================================
    reg [3:0]   DealState;
    reg [3:0]   DealState_dly;
    assign CalibrationState = DealState;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DealState<=4'd0;
            DealState_dly<=4'd0;
        end
        else begin
            if(CalibrationEN==1'b0)
                DealState<=4'd0;
            else begin
                case(DealState)
                4'd0:DealState<=4'd1;//Idel to Calibration
                4'd1:begin//trig Calibration
                    if(TXFrameFinished)
                        DealState<=4'd2;
                    else
                        DealState<=4'd1;
                end
                4'd2:begin//wait responce
                    if(RxedPluse && (RXDATA==8'hA3))
                        DealState<=4'd12;
                    else
                        DealState<=4'd2;
                end
                4'd3:begin//trig ENC Calibration state
                    if(TXFrameFinished)
                        DealState<=4'd4;
                    else
                        DealState<=4'd3;
                end
                4'd4:begin//wait ENC back Calibration state
                    if(RxedPluse)begin
                        if(TXRequestCNT>=4'd15)begin
                            if(RXDATA==8'hB3)//finished
                                DealState<=4'd10;
                            else//not finished
                                DealState<=4'd14;
                        end
                        else
                            DealState<=4'd14;
                    end
                    else//wait response
                        DealState<=4'd4;
                end
                
                4'd12:begin//delay
                    if(DelayCount>=DelayCountRef)begin
                        if(TXRequestCNT>4'd9)
                            DealState<=4'd3;
                        else
                            DealState<=4'd1;
                    end
                    else
                        DealState<=4'd12;
                end
                4'd14:begin//delay
                    if(DelayCount>=DelayCountRef)
                        DealState<=4'd3;
                    else
                        DealState<=4'd14;
                end
                
                default:
                    DealState<=DealState;
                endcase
            end
            
            DealState_dly<=DealState;
        end
    end
    
    //======TX CTRL=================================
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            TXRXSwitch<=1'b0;
        else begin
            if(CalibrationEN==1'b0)
                TXRXSwitch<=1'b0;
            else begin
                if(((DealState==4'd1)&&((DealState_dly==4'd0)||(DealState_dly==4'd12)))||
                   ((DealState==4'd3)&&((DealState_dly==4'd12)||(DealState_dly==4'd14))) 
                )
                    TXRXSwitch<=1'b1;
                else begin
                    if(TXFrameFinished)
                        TXRXSwitch<=1'b0;
                end
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            TXEN_DelayCNT<=8'd0;
        else begin
            if(TXRXSwitch==1'b0)
                TXEN_DelayCNT<=8'd0;
            else begin
                if(TXEN_DelayCNT<(TXEN_DelayCNT_SET+1'b1))
                    TXEN_DelayCNT<=TXEN_DelayCNT+1'b1;
                else
                    TXEN_DelayCNT<=(TXEN_DelayCNT_SET+1'b1);
            end
        end
    end
    assign TXFrameTrig = (TXEN_DelayCNT==TXEN_DelayCNT_SET);
    
    
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            TXTrig<=1'b0;
            TXBYTECNT<=4'd0;
            TXFrameFinished=1'b0;
            TXDATA<=8'd0;
            TXRequestCNT<=3'd0;
        end
        else begin
            if(DealState==4'd1)begin
                if(TXBYTECNT==4'd0)
                    TXTrig<=TXFrameTrig;
                else begin
                        TXTrig<=1'b0;
                end
                
                if(TXTrig)
                    TXBYTECNT<=TXBYTECNT+1'b1;
                    
                TXDATA<=8'h3A;
                    
                TXFrameFinished<=((TXBYTECNT==4'd1)&&TXedPluse);
                
                if(TXFrameFinished)
                    TXRequestCNT<=TXRequestCNT+1'b1;
            end
                
            else if(DealState==4'd3)begin
                if(TXBYTECNT==4'd0)
                    TXTrig<=TXFrameTrig;
                else begin
                        TXTrig<=1'b0;
                end
                
                if(TXTrig)
                    TXBYTECNT<=TXBYTECNT+1'b1;
                    
                TXDATA<=8'h3B;
                    
                TXFrameFinished<=((TXBYTECNT==4'd1)&&TXedPluse);
                //TXRequestCNT<=4'd0;
                
                if(TXFrameFinished)
                    TXRequestCNT<=TXRequestCNT+1'b1;
            end
            else begin
                TXTrig<=1'b0;
                TXBYTECNT<=4'd0;
                TXFrameFinished=1'b0;
                TXDATA<=8'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            DelayCount<=32'd0;
        else begin
            if((DealState_dly==4'd12)||(DealState_dly==4'd14))
                DelayCount<=DelayCount+1'b1;
            else
                DelayCount<=32'd0;
        end
    end
    
    //======RX DEAL=================================
    

endmodule
