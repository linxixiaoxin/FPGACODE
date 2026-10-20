module Slave100MHz_FrameAnalysis(
    input               clk,
    input               rst,
    input               RXDV_org,
    input               RXD_org,
    //=====================================================
    output              RXDV,
    output              RXD, 
    //===sync to RXD ... frame tags relate
    output  reg [7:0]   TAG_ByteStream, 
    output              TAG_ByteActive, 
    output      [3:0]   TAG_FrameState,
    output  reg [15:0]  TAG_DataPartByteCNT,
    //===delay RXD by 1 clk ... frame message capture 
    output  reg [47:0]  MSG_TargetAddress,
    output  reg [47:0]  MSG_SourceAddress,
    output  reg [15:0]  MSG_EthernetType,
    //===delay RXD by 2 clk ... frame crc check
    output              CK_FrameOK,
    output              CK_CRC_Valid,
    output              CK_CheckResult
    );
    
    reg RXDV_d1;
    reg RXD_d1;
    reg RXDV_d2;
    reg RXD_d2;
    reg RXD_d3;
    
    reg     [15:0]  BitsCounter_d1;
    wire    [2:0]   BitsCounterLoop;
    reg     [7:0]   ByteRec;
    
    reg     [7:0]   FrameMsgBytesCount;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RXDV_d1<=1'b0;
            RXD_d1<=1'b0;
            RXDV_d2<=1'b0;
            RXD_d2<=1'b0;
            RXD_d3<=1'b0;
        end
        else begin
            RXDV_d1<=RXDV_org;
            RXD_d1<=RXD_org;
            RXDV_d2<=RXDV_d1;
            RXD_d2<=RXD_d1;
            RXD_d3<=RXD_d2;
        end
    end
    assign RXDV = RXDV_d1;
    assign RXD = RXD_d1;
    
    //FMS State=====================================
    reg     [3:0]   state_current_d1; 
    reg     [3:0]   state_next_d1;
    assign TAG_FrameState = state_current_d1;
    parameter   Frame_Idel      =   4'd0;
    parameter   Frame_Preamble  =   4'd1;
    parameter   Frame_Message   =   4'd2;
    parameter   Frame_DATA_FCS  =   4'd3;
    parameter   Frame_InValid   =   4'd15;
    
    //FMS===========================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst) state_current_d1<=Frame_Idel;
        else state_current_d1<=state_next_d1;
    end 

    always @ (*)
    begin
        case(state_current_d1)
            Frame_Idel:begin
                if((RXDV_org==1'b1)&&(RXDV_d1==1'b0)) 
                    state_next_d1=Frame_Preamble;
                else 
                    state_next_d1=Frame_Idel;
            end

            Frame_Preamble:begin
                if(RXDV_org==1'b0)
                    state_next_d1=Frame_InValid;
                else begin
                    if({RXD_d1,RXD_d2,RXD_d3}==3'b111)
                        state_next_d1=Frame_Message;
                    else
                        state_next_d1=Frame_Preamble;
                end
            end

            Frame_Message:begin
                if(RXDV_org==1'b0)
                    state_next_d1=Frame_InValid;
                else begin
                    if(BitsCounter_d1>=15'd111) 
                        state_next_d1=Frame_DATA_FCS;
                    else 
                        state_next_d1=Frame_Message; 
                end
            end

            Frame_DATA_FCS:begin
                if(RXDV_org==1'b0)
                    state_next_d1=Frame_Idel;
                else begin
                    state_next_d1=Frame_DATA_FCS; 
                end 
            end

            Frame_InValid:begin
                if(RXDV_org==1'b0) 
                    state_next_d1=Frame_Idel;
                else 
                    state_next_d1=Frame_InValid; 
            end

            default: state_next_d1=Frame_Idel; 
        endcase
    end 
    
    //Regs Updata===================================
    
    //==BitsCounter_d1
    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            BitsCounter_d1<=16'd0;
        else begin
            if((state_current_d1==Frame_Idel)||(state_current_d1==Frame_Preamble))
                BitsCounter_d1<=16'd0;
            else
                BitsCounter_d1<=BitsCounter_d1+16'd1;
        end
    end 
    assign BitsCounterLoop = BitsCounter_d1[2:0];
    assign TAG_ByteActive = (BitsCounterLoop==3'd7)&&((state_current_d1==Frame_Message)||(state_current_d1==Frame_DATA_FCS));
    
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            ByteRec<=8'd0;
        else begin
            if((state_current_d1==Frame_Message)||(state_current_d1==Frame_DATA_FCS))begin
                case(BitsCounterLoop)
                3'd0:ByteRec[1:0]<={RXD_org,RXD_d1};
                3'd1:ByteRec[2]<=RXD_org;
                3'd2:ByteRec[3]<=RXD_org;
                3'd3:ByteRec[4]<=RXD_org;
                3'd4:ByteRec[5]<=RXD_org;
                3'd5:ByteRec[6]<=RXD_org;
                3'd6:ByteRec[7]<=RXD_org;
                endcase
            end
            else
                ByteRec<=8'd0;
        end
    end
    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            TAG_ByteStream<=8'd0;
        else begin
            if((state_current_d1==Frame_Message)||(state_current_d1==Frame_DATA_FCS))begin
                case(BitsCounterLoop)
                3'd6:TAG_ByteStream<={RXD_org,ByteRec[6:0]};
                endcase
            end
        end
    end
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            TAG_DataPartByteCNT<=16'd0;
        else begin
            if(TAG_FrameState==4'd1)
                TAG_DataPartByteCNT<=16'd0;
            else begin
                if(TAG_FrameState==4'd3)begin
                    if(TAG_ByteActive)
                        TAG_DataPartByteCNT<=TAG_DataPartByteCNT+1'b1;
                end
            end
        end
    end
    
    
Slave100MHz_CRCCHECK CRCCHECK(
    .clk(clk),
    .rst(rst),
    .ByteStream(TAG_ByteStream), 
    .ByteActive(TAG_ByteActive),
    .FrameDeal_State(TAG_FrameState), 
    .CheckResult(CK_CheckResult),
    .FrameOK(CK_FrameOK),
    .CRC_Valid(CK_CRC_Valid)
    );
    
    //===================
    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            FrameMsgBytesCount<=8'd1;
        else begin
            if(TAG_FrameState==Frame_Message)begin
                if(TAG_ByteActive)
                    FrameMsgBytesCount<=FrameMsgBytesCount+1'b1;
            end
            else
                FrameMsgBytesCount<=8'd1;
        end 
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            MSG_TargetAddress<=48'd0;
        else begin
            if((TAG_FrameState==Frame_Message)&&TAG_ByteActive)begin
                case(FrameMsgBytesCount)
                8'd6:MSG_TargetAddress[7:0]<=TAG_ByteStream;
                8'd5:MSG_TargetAddress[15:8]<=TAG_ByteStream;
                8'd4:MSG_TargetAddress[23:16]<=TAG_ByteStream;
                8'd3:MSG_TargetAddress[31:24]<=TAG_ByteStream;
                8'd2:MSG_TargetAddress[39:32]<=TAG_ByteStream;
                8'd1:MSG_TargetAddress[47:40]<=TAG_ByteStream;
                endcase
            end
            else if(TAG_FrameState==Frame_Preamble)
                MSG_TargetAddress<=48'd0;
        end
    end 

    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            MSG_SourceAddress<=48'd0;
        else begin
            if((TAG_FrameState==Frame_Message)&&TAG_ByteActive)begin
                case(FrameMsgBytesCount)
                8'd12:MSG_SourceAddress[7:0]<=TAG_ByteStream;
                8'd11:MSG_SourceAddress[15:8]<=TAG_ByteStream;
                8'd10:MSG_SourceAddress[23:16]<=TAG_ByteStream;
                8'd9:MSG_SourceAddress[31:24]<=TAG_ByteStream;
                8'd8:MSG_SourceAddress[39:32]<=TAG_ByteStream;
                8'd7:MSG_SourceAddress[47:40]<=TAG_ByteStream;
                endcase
            end
            else if(TAG_FrameState==Frame_Preamble)
                MSG_SourceAddress<=48'd0;
        end
    end 

    always @ (posedge clk or negedge rst)begin
        if(!rst) begin
            MSG_EthernetType<=16'd0;
        end
        else begin
            if((TAG_FrameState==Frame_Message)&&TAG_ByteActive)begin
                case(FrameMsgBytesCount)
                8'd14:MSG_EthernetType[7:0]<=TAG_ByteStream;
                8'd13:MSG_EthernetType[15:8]<=TAG_ByteStream;
                endcase
            end
            else if(TAG_FrameState==Frame_Preamble)
                MSG_EthernetType<=16'd0;
        end
    end 


endmodule
