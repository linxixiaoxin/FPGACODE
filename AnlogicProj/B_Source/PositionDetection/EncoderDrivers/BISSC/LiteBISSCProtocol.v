module LiteBISSCProtocol(
    input                   clk,//100Mhz
    input                   rst,
    
    input                   RequestTrig,
    output  reg     [31:0]  PositionFB,
    output  reg             DataValid,
    
    input                   BISS_DATAIN,
    output  reg             BISS_CLK
    );
    
    localparam  [15:0]  DataBitsSet =   16'd34;
    localparam  [15:0]  TimeoutSet  =   16'd40000;//ns
    
    localparam  BISSCLK_CNTSET      =   16'd39;//2.5Mhz 400ns, = 10ns(100Mhz) * 40
    localparam  BISSCLK_NedgeSET    =   BISSCLK_CNTSET-((BISSCLK_CNTSET+1'b1)>>1);
    localparam  BISSCLK_RedgeSET    =   BISSCLK_CNTSET;
    
    reg         BISSCLKEN;    
    reg [15:0]  CLK_CNT;
   
    reg         BISSCLK_TXPluse;
    reg         BISSCLK_RXPluse;
    
    reg [3:0]   BISSDEAL_CNT;
    
    reg [15:0]  DataBitRXCNT;
    
    reg [15:0]  TimeoutCounter;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            BISSCLKEN<=1'b0;
        else begin
            if(RequestTrig)
                BISSCLKEN<=1'b1;
            else begin
                if(((BISSDEAL_CNT>=4'd4)&&BISSCLK_TXPluse)||(TimeoutCounter>=(TimeoutSet-16'd10)))
                    BISSCLKEN<=1'b0;
            end 
        end
    end    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            CLK_CNT<=16'd0;
        else begin
            if(BISSCLKEN==1'b1)begin
                if(CLK_CNT<BISSCLK_CNTSET)
                    CLK_CNT<=CLK_CNT+1'b1;
                else
                    CLK_CNT<=16'd0;
            end
            else
                CLK_CNT<=16'd0;
        end
    end

    always @(posedge clk or negedge rst)begin
        if(!rst)begin
            BISSCLK_TXPluse<=1'b0;
            BISSCLK_RXPluse<=1'b0;
            BISS_CLK<=1'b1;
        end
        else begin
            BISSCLK_TXPluse<=(CLK_CNT==BISSCLK_RedgeSET);
            BISSCLK_RXPluse<=(CLK_CNT==BISSCLK_NedgeSET);
            BISS_CLK<=(CLK_CNT<BISSCLK_NedgeSET);
        end
    end
    
    always @(posedge clk or negedge rst)begin
        if(!rst)begin
            BISSDEAL_CNT<=4'd0;
        end
        else begin
            if(BISSCLKEN)begin
                if(BISSCLK_RXPluse)begin
                    case(BISSDEAL_CNT)
                    4'd0:begin//wait ack
                        if(BISS_DATAIN==1'b1)
                            BISSDEAL_CNT<=4'd0;
                        else
                            BISSDEAL_CNT<=4'd1;
                    end
                    4'd1:begin//acked,wait start1'b1
                        if(BISS_DATAIN==1'b1)
                            BISSDEAL_CNT<=4'd2;
                        else
                            BISSDEAL_CNT<=4'd1;
                    end
                    4'd2:begin//started,wait CDS1'b0
                        if(BISS_DATAIN==1'b0)
                            BISSDEAL_CNT<=4'd3;
                        else
                            BISSDEAL_CNT<=4'd15;
                    end   
                    4'd3:begin
                        if(DataBitRXCNT==(DataBitsSet-1'b1))
                            BISSDEAL_CNT<=4'd4;
                        else
                            BISSDEAL_CNT<=4'd3;
                    end
                    4'd4:begin
                        BISSDEAL_CNT<=4'd4;
                    end
                    4'd15:begin//err
                        BISSDEAL_CNT<=4'd15;
                    end
                    endcase
                end
            end
            else
                BISSDEAL_CNT<=4'd0;
        end
    end
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            DataBitRXCNT<=16'd0;
        else begin
            if(BISSDEAL_CNT==4'd3)begin
                if(BISSCLK_RXPluse)
                    DataBitRXCNT<=DataBitRXCNT+1'b1;
            end
            else
                DataBitRXCNT<=16'd0;
        end
    end 
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            TimeoutCounter<=16'd0;
        else begin
            if(BISSCLKEN==1'b1)
                TimeoutCounter<=TimeoutCounter+16'd10;
            else
                TimeoutCounter<=16'd0;
        end
    end

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            PositionFB<=32'd0;
        else begin
            if(BISSCLK_RXPluse)begin
            case(DataBitRXCNT)
            16'd0:PositionFB[25]<=BISS_DATAIN;
            16'd1:PositionFB[24]<=BISS_DATAIN;
            16'd2:PositionFB[23]<=BISS_DATAIN;
            16'd3:PositionFB[22]<=BISS_DATAIN;
            16'd4:PositionFB[21]<=BISS_DATAIN;
            16'd5:PositionFB[20]<=BISS_DATAIN;
            16'd6:PositionFB[19]<=BISS_DATAIN;
            16'd7:PositionFB[18]<=BISS_DATAIN;
            16'd8:PositionFB[17]<=BISS_DATAIN;
            16'd9:PositionFB[16]<=BISS_DATAIN;
            16'd10:PositionFB[15]<=BISS_DATAIN;
            16'd11:PositionFB[14]<=BISS_DATAIN;
            16'd12:PositionFB[13]<=BISS_DATAIN;
            16'd13:PositionFB[12]<=BISS_DATAIN;
            16'd14:PositionFB[11]<=BISS_DATAIN;
            16'd15:PositionFB[10]<=BISS_DATAIN;
            16'd16:PositionFB[9]<=BISS_DATAIN;
            16'd17:PositionFB[8]<=BISS_DATAIN;
            16'd18:PositionFB[7]<=BISS_DATAIN;
            16'd19:PositionFB[6]<=BISS_DATAIN;
            16'd20:PositionFB[5]<=BISS_DATAIN;
            16'd21:PositionFB[4]<=BISS_DATAIN;
            16'd22:PositionFB[3]<=BISS_DATAIN;
            16'd23:PositionFB[2]<=BISS_DATAIN;
            16'd24:PositionFB[1]<=BISS_DATAIN;
            16'd25:PositionFB[0]<=BISS_DATAIN;
            endcase
            end
        end
    end

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            DataValid<=1'b0;
        else begin
            if(BISSCLK_RXPluse)begin
            case(DataBitRXCNT)
            16'd30:DataValid<=1'b1;
            default:DataValid<=1'b0;
            endcase
            end
        end
    end
    
    
endmodule
