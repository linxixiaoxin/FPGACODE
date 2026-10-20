module Slave100MHz_TopUnPack(
    input                   clk,
    input                   rst,

    input                   RXDV,
    input                   RXD,
    input       [7:0]       TAG_ByteStream, 
    input                   TAG_ByteActive, 
    input       [3:0]       TAG_FrameState,
    input       [15:0]      TAG_DataPartByteCNT,
    input       [15:0]      MSG_EthernetType,
    
    //==Msg Out
    output  reg [31:0]      SysRefClk,
    output  reg [7:0]       OperationMode,
    output  reg [7:0]       SlaveDetect,
    output  reg [15:0]      FrameIndex,
    output  reg [15:0]      Datalength,
    
    //==sync RXDV
    output                  ReplaceFlag,
    output  reg             TXD
);
    //======Msg output==============================
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            SysRefClk<=32'd0;
            SlaveDetect<=8'd0;
            OperationMode<=8'd0;
            FrameIndex<=16'd0;
            Datalength<=16'd0;
        end
        else begin
            if(TAG_FrameState==4'd1)begin
                SysRefClk<=32'd0;
                SlaveDetect<=8'd0;
                OperationMode<=8'd0;
                FrameIndex<=16'd0;
                Datalength<=16'd0;
            end
            else begin
                if((MSG_EthernetType==16'h88A4)&&(TAG_FrameState==4'd3))begin
                    if(TAG_ByteActive)begin
                        case(TAG_DataPartByteCNT)
                        16'd0:SysRefClk[31:24]<=TAG_ByteStream;
                        16'd1:SysRefClk[23:16]<=TAG_ByteStream;
                        16'd2:SysRefClk[15:8]<=TAG_ByteStream;
                        16'd3:SysRefClk[7:0]<=TAG_ByteStream;
                        16'd4:SlaveDetect<=TAG_ByteStream;
                        16'd5:OperationMode<=TAG_ByteStream;
                        16'd6:FrameIndex[15:8]<=TAG_ByteStream;
                        16'd7:FrameIndex[7:0]<=TAG_ByteStream;
                        16'd8:Datalength[15:8]<=TAG_ByteStream;
                        16'd9:Datalength[7:0]<=TAG_ByteStream;
                        endcase
                    end
                end
            end
        end
    end


    //======SlaveDetect Part deal ==================
    reg [2:0]   BitCNT;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            BitCNT<=3'd0;
        else begin
            if(TAG_ByteActive||(TAG_FrameState!=4'd3))
                BitCNT<=3'd0;
            else begin
                BitCNT<=BitCNT+1'b1;
            end
        end
    end
    
    reg [1:0] adder;
    wire carryflag;
    assign carryflag = adder[1];
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            adder<=2'd0;
        else begin
            if((MSG_EthernetType==16'h88A4)&&(TAG_FrameState==4'd3)&&(TAG_DataPartByteCNT==16'd4))begin
                case(BitCNT)
                3'd0:adder <= {1'b0,RXD} + 2'd1;
                default:adder <= {1'b0,RXD} + {1'b0,carryflag};
                endcase
            end
            else
                adder<=2'd0;
        end
    end
    
    always @ (*)begin
        if((MSG_EthernetType==16'h88A4)&&(TAG_FrameState==4'd3)&&(TAG_DataPartByteCNT==16'd4))begin
            case(BitCNT)
            3'd0:TXD = RXD + 1'b1;
            3'd1,3'd2,3'd3,3'd4,3'd5,3'd6:TXD = RXD + carryflag;
            3'd7:begin
                if(RXD)
                    TXD = RXD;
                else
                    TXD = carryflag;
            end
            default:TXD = RXD;
            endcase
        end
        else
            TXD = RXD;
    end 
    
    assign ReplaceFlag = (MSG_EthernetType==16'h88A4)&&(TAG_FrameState==4'd3)&&(TAG_DataPartByteCNT==16'd4);
    
endmodule
