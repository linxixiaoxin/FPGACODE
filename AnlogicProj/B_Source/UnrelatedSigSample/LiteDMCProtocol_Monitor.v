module LiteDMCProtocol_Monitor(
    input                   clk,
    input                   rst,

    output  reg     [31:0]  PositionFB,

    input                   DMC_IN,//485 TX
    output                  DMC_OUT,//485 RX
    output                  DMC_DE//485 EN
    );
    
//    localparam  CF0 = 8'b00000010;

    //2.5Mbps 1bit 400ns, 1byte = 4us
    localparam ByteIntervalMax = 16'd600;//unit 10ns, 6us
    reg [15:0]  ByteIntervalCNT;

    wire            RxedPluse;//synthesis keep = 1;
    wire    [7:0]   RXDATA;//synthesis keep = 1;
UARTServiceForDMC UARTServiceForDMC(
    .clk(clk),
    .rst(rst),
    
    .TXRXSwitch(1'b0),//0: RXDen 1: RXDen
    .TXTrig(1'b0),
    .TXDATA(),
    .TXedPluse(),
    .RxedPluse(RxedPluse),
    .RXDATA(RXDATA),
    
    .DMC_IN(DMC_IN),//485 TX
    .DMC_OUT(DMC_OUT),//485 RX
    .DMC_DE(DMC_DE)//485 EN
    );
    
    
    always  @ (posedge clk or negedge rst)begin
        if(!rst)
            ByteIntervalCNT<=16'd0;
        else begin
            if(RxedPluse)
                ByteIntervalCNT<=16'd0;
            else begin
                if(ByteIntervalCNT<ByteIntervalMax)
                    ByteIntervalCNT<=ByteIntervalCNT+1'b1;
                else
                    ByteIntervalCNT<=ByteIntervalMax;
            end
        end
    end
    
    wire RXByteCNT_CLR;//synthesis keep = 1;
    assign RXByteCNT_CLR = (ByteIntervalCNT==ByteIntervalMax);
    
    
    
//======RX Ctrl=========================================== 
    reg [7:0]   RXByteCNT;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            RXByteCNT<=8'd0;
        else begin
            if(RxedPluse)
                RXByteCNT<=RXByteCNT+1'b1;
            else begin
                if(RXByteCNT_CLR)
                    RXByteCNT<=8'd0;
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
            8'd0:Byte0<=RXDATA;
            8'd1:Byte1<=RXDATA;
            8'd2:Byte2<=RXDATA;
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
        end
        else begin
            if(RxedPluse && (RXByteCNT==8'd5))
                PositionFB <= {8'd0,Byte4,Byte3,Byte2};
        end
    end


endmodule
