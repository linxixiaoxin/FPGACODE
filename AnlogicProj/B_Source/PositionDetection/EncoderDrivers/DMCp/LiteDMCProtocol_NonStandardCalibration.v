module LiteDMCProtocol_NonStandardCalibration(
    input                   clk,
    input                   rst,
    
    input                   CalibrationEN,
    output          [3:0]   CalibrationState,
    output                  ENCNoResponsPluse,
    output                  ENCCRCERRPluse,
    
    input                   RequestTrig,
    output  reg     [31:0]  PositionFB,
    output  reg             DataValid,
    
    input                   DMC_IN,//485 TX
    output                  DMC_OUT,//485 RX
    output                  DMC_DE//485 EN
    );
    
    localparam  CF0 = 8'b00000010;//ID0
    localparam  CF1 = 8'b00011010;//ID3
    
    wire            TXRXSwitch_Calib;
    wire            TXTrig_Calib;
    wire    [7:0]   TXDATA_Calib;
    
    reg             TXRXSwitch;
    reg             TXTrig;
    reg     [7:0]   TXDATA;
    wire            TXedPluse;
    wire            RxedPluse;
    wire    [7:0]   RXDATA;
    
    reg             CalibrationEN_sync;
    wire            TXRXSwitch_active;
    wire            TXTrig_active;
    wire    [7:0]   TXDATA_active;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            CalibrationEN_sync<=1'b0;
        else begin
            if(RequestTrig)
                CalibrationEN_sync<=CalibrationEN;
        end
    end
    
    assign TXRXSwitch_active = CalibrationEN_sync?TXRXSwitch_Calib:TXRXSwitch;
    assign TXTrig_active     = CalibrationEN_sync?TXTrig_Calib:TXTrig;
    assign TXDATA_active     = CalibrationEN_sync?TXDATA_Calib:TXDATA; 
    
NonStandardCalibration NonStandardCalibration(
    .clk(clk),
    .rst(rst),
    
    .CalibrationEN(CalibrationEN_sync),
    .CalibrationState(CalibrationState),
    
    .TXRXSwitch(TXRXSwitch_Calib),
    .TXTrig(TXTrig_Calib),
    .TXDATA(TXDATA_Calib),
    .TXedPluse(TXedPluse),
    .RxedPluse(RxedPluse),
    .RXDATA(RXDATA)
    );
UARTServiceForDMC UARTServiceForDMC(
    .clk(clk),
    .rst(rst),
    
    .TXRXSwitch(TXRXSwitch_active),//0: RXDen 1: RXDen
    .TXTrig(TXTrig_active),
    .TXDATA(TXDATA_active),
    .TXedPluse(TXedPluse),
    .RxedPluse(RxedPluse),
    .RXDATA(RXDATA),
    
    .DMC_IN(DMC_IN),//485 TX
    .DMC_OUT(DMC_OUT),//485 RX
    .DMC_DE(DMC_DE)//485 EN
    );
    
    wire            TXFrameTrig;
    reg             TXFrameFinished;
    reg     [7:0]   TXEN_DelayCNT;
    localparam  TXEN_DelayCNT_SET = 8'd12;
    
//======TX Start Ctrl===========================================    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            TXRXSwitch<=1'b0;
        else begin
            if(CalibrationEN_sync==1'b0)begin
                if(RequestTrig)
                    TXRXSwitch<=1'b1;
                else begin
                    if(TXFrameFinished)
                        TXRXSwitch<=1'b0;
                end
            end
            else
                TXRXSwitch<=1'b0;
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
    
//======TX Ctrl===========================================  
    always @ (*)begin
        TXDATA = CF1;//CF0;//
        TXTrig = TXFrameTrig;
        TXFrameFinished = TXedPluse;
    end
    
    
    
    
//======RX Ctrl=========================================== 
    reg [7:0]   RXByteCNT;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            RXByteCNT<=8'd0;
        else begin
            if(TXFrameTrig)
                RXByteCNT<=8'd0;
            else begin
                if(TXRXSwitch==1'b0)begin
                    if(RxedPluse)
                        RXByteCNT<=RXByteCNT+1'b1;
                end
            end
        end
    end
    
    reg [7:0]   Byte0;
    reg [7:0]   Byte1;
    reg [7:0]   Byte2;
    reg [7:0]   Byte3;
    reg [7:0]   Byte4;
    reg [7:0]   Byte5;
    reg [7:0]   Byte6;
    reg [7:0]   Byte7;
    reg [7:0]   Byte8;
    reg [7:0]   Byte9;
    reg [7:0]   Byte10;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Byte0<=8'd0;
            Byte1<=8'd0;
            Byte2<=8'd0;
            Byte3<=8'd0;
            Byte4<=8'd0;
            Byte5<=8'd0;
            Byte6<=8'd0;
            Byte7<=8'd0;
            Byte8<=8'd0;
            Byte9<=8'd0;
            Byte10<=8'd0;
        end
        else begin
            if(RxedPluse)begin
            case(RXByteCNT)
            8'd0:Byte0<=RXDATA;//CF
            8'd1:Byte1<=RXDATA;//SF
            8'd2:Byte2<=RXDATA;//Data
            8'd3:Byte3<=RXDATA;
            8'd4:Byte4<=RXDATA;
            8'd5:Byte5<=RXDATA;
            8'd6:Byte6<=RXDATA;
            8'd7:Byte7<=RXDATA;
            8'd8:Byte8<=RXDATA;
            8'd9:Byte9<=RXDATA;
            8'd10:Byte10<=RXDATA;
            endcase
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            PositionFB<=32'd0;
            DataValid<=1'b0;
        end
        else begin
            if(RxedPluse && (RXByteCNT==8'd5))
                PositionFB <= {8'd0,Byte4,Byte3,Byte2};
                
            DataValid<=(RxedPluse && (RXByteCNT==8'd5));
        end
    end


endmodule
