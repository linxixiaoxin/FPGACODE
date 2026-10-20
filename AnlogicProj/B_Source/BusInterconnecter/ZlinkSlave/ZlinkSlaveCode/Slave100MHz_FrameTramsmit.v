module Slave100MHz_FrameTramsmit(
    input                   clk,
    input                   rst,
    
    input                   RXDV,
    input                   RXD,
    input       [7:0]       TAG_ByteStream, 
    input                   TAG_ByteActive, 
    input       [3:0]       TAG_FrameState,
    input       [15:0]      TAG_DataPartByteCNT,
    input       [15:0]      MSG_EthernetType,

    input       [15:0]      Datalength,
    
    input                   TopPackReplaceFlag,
    input                   TopPackTXD,
    input                   IndependentReadReplaceFlag,
    input                   IndependentReadTXD,
    
    output  reg             TXEN,
    output  reg             TXD
    );
    
    localparam MinDataLength = 16'd46;
    wire [15:0] FrameDatalength;
    assign FrameDatalength = Datalength + 16'd10;
    wire [15:0] DataLength_Active;
    assign DataLength_Active = (FrameDatalength>MinDataLength)?FrameDatalength:MinDataLength;
    
    
    //Replace================================================================
    
    
    reg TXD_PRE;
    always @ (*)begin
        if(TopPackReplaceFlag)
            TXD_PRE = TopPackTXD;
        else if(IndependentReadReplaceFlag)
            TXD_PRE = IndependentReadTXD;
        else
            TXD_PRE = RXD;
    end
    
    
    wire ByteReplaceFlag;
    assign ByteReplaceFlag = TopPackReplaceFlag || IndependentReadReplaceFlag;
    
    
    
    //CRC and TX===============================================================
    reg [7:0] ByteRec;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            ByteRec <= 8'd0;
        else begin
            if(TAG_FrameState==4'd3)
                ByteRec <= {TXD_PRE,ByteRec[7:1]};
            else
                ByteRec <= 8'd0;
        end
    end
    
    reg [7:0]   BytetobeSent;
    reg         ByteSendTrig;
    wire [31:0] CRCResult;
    wire CalEn;
    wire ResultClr;
    
    
    always @ (*)begin
        if(ByteReplaceFlag)
            BytetobeSent = {TXD_PRE,ByteRec[7:1]};
        else
            BytetobeSent = TAG_ByteStream;
            
        ByteSendTrig = TAG_ByteActive;
    end
    
    assign CalEn = (TAG_FrameState==4'd2)||((TAG_FrameState==4'd3)&&(TAG_DataPartByteCNT<DataLength_Active));
    assign ResultClr = (TAG_FrameState==4'd1);
    
    
Slave100MHz_CRCCal CRCCal(
    .clk(clk),
    .rst(rst),

    .ByteStream(BytetobeSent), 
    .ByteActive(ByteSendTrig),
    .CalEn(CalEn),
    .ResultClr(ResultClr),
    .CRCResult(CRCResult)
    );
    
    reg [4:0] CRC_bitCNT;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            CRC_bitCNT <= 5'd0;
        else begin
            if((TAG_FrameState==4'd3)&&(TAG_DataPartByteCNT>=DataLength_Active))
                CRC_bitCNT <= CRC_bitCNT+1'b1;
            else
                CRC_bitCNT <= 5'd0;
        end
    end
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            TXD <= 1'b0;
            TXEN <= 1'b0;
        end
        else begin
            TXEN <= RXDV;
            
            if((TAG_FrameState==4'd3)&&(TAG_DataPartByteCNT>=DataLength_Active))begin
                case(CRC_bitCNT)
                    5'd0:TXD<=CRCResult[0];
                    5'd1:TXD<=CRCResult[1];
                    5'd2:TXD<=CRCResult[2];
                    5'd3:TXD<=CRCResult[3];
                    5'd4:TXD<=CRCResult[4];
                    5'd5:TXD<=CRCResult[5];
                    5'd6:TXD<=CRCResult[6];
                    5'd7:TXD<=CRCResult[7];
                    5'd8:TXD<=CRCResult[8];
                    5'd9:TXD<=CRCResult[9];
                    5'd10:TXD<=CRCResult[10];
                    5'd11:TXD<=CRCResult[11];
                    5'd12:TXD<=CRCResult[12];
                    5'd13:TXD<=CRCResult[13];
                    5'd14:TXD<=CRCResult[14];
                    5'd15:TXD<=CRCResult[15];
                    5'd16:TXD<=CRCResult[16];
                    5'd17:TXD<=CRCResult[17];
                    5'd18:TXD<=CRCResult[18];
                    5'd19:TXD<=CRCResult[19];
                    5'd20:TXD<=CRCResult[20];
                    5'd21:TXD<=CRCResult[21];
                    5'd22:TXD<=CRCResult[22];
                    5'd23:TXD<=CRCResult[23];
                    5'd24:TXD<=CRCResult[24];
                    5'd25:TXD<=CRCResult[25];
                    5'd26:TXD<=CRCResult[26];
                    5'd27:TXD<=CRCResult[27];
                    5'd28:TXD<=CRCResult[28];
                    5'd29:TXD<=CRCResult[29];
                    5'd30:TXD<=CRCResult[30];
                    5'd31:TXD<=CRCResult[31];
                endcase
            end
            else
                TXD <= TXD_PRE;
        end
    end

endmodule
