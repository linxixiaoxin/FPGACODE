module Slave100MHz_SubDatagramdeal(
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
    
    output  reg             SubDatagramIndicate,
    output  reg [15:0]      SubDatagramCNT,
    output  reg [15:0]      SubDatagramByteCNT,
    output  reg [7:0]       SubDatagram_CMD,
    output  reg [7:0]       SubDatagram_SlaveAddr,
    output  reg [15:0]      SubDatagram_LocalAddr,
    output  reg [15:0]      SubDatagram_Datalength,
    output  reg             SubDatagram_NextFlag,
    output  reg             SubDatagram_CMDValid
    );
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            SubDatagram_CMDValid<=1'b0;
        else
            SubDatagram_CMDValid<=TAG_ByteActive&&SubDatagramIndicate&&(SubDatagramByteCNT==16'd5);
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            SubDatagram_CMD<=8'd0;
            SubDatagram_SlaveAddr<=8'd0;
            SubDatagram_LocalAddr<=16'd0;
            SubDatagram_Datalength<=16'd0;
            SubDatagram_NextFlag<=1'b0;
        end
        else begin
            if(SubDatagramIndicate)begin
                if(TAG_ByteActive)begin
                    case(SubDatagramByteCNT)
                    16'd0:begin
                        SubDatagram_CMD<=TAG_ByteStream;
                        SubDatagram_SlaveAddr<=8'd0;
                        SubDatagram_LocalAddr<=16'd0;
                        SubDatagram_Datalength<=16'd0;
                        SubDatagram_NextFlag<=1'b0;
                    end
                    16'd1:SubDatagram_SlaveAddr<=TAG_ByteStream;
                    16'd2:SubDatagram_LocalAddr[15:8]<=TAG_ByteStream;
                    16'd3:SubDatagram_LocalAddr[7:0]<=TAG_ByteStream;
                    16'd4:SubDatagram_Datalength[15:7]<={1'b0,TAG_ByteStream};
                    16'd5:begin
                        SubDatagram_Datalength[6:0]<=TAG_ByteStream[7:1];
                        SubDatagram_NextFlag<=TAG_ByteStream[0];
                    end
                    
                    endcase
                end
            end
            else begin
                SubDatagram_CMD<=8'd0;
                SubDatagram_SlaveAddr<=8'd0;
                SubDatagram_LocalAddr<=16'd0;
                SubDatagram_Datalength<=16'd0;
                SubDatagram_NextFlag<=1'b0;
            end
        end
    end
    
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            SubDatagramIndicate<=1'b0;
            SubDatagramByteCNT<=16'd0;
            SubDatagramCNT<=16'd0;
        end
        else begin
            if(TAG_FrameState!=4'd3)begin
                SubDatagramIndicate<=1'b0;
                SubDatagramByteCNT<=16'd0;
                SubDatagramCNT<=16'd0;
            end
            else begin
                if(TAG_ByteActive)begin
                    if(TAG_DataPartByteCNT==16'd9)
                        SubDatagramIndicate<=1'b1;
                    else begin
                        if(TAG_DataPartByteCNT>=(Datalength+16'd9))
                            SubDatagramIndicate<=1'b0;
                    end
                end
                
                if(SubDatagramIndicate)begin
                    if(TAG_ByteActive)begin
                        if(SubDatagramByteCNT<=6)
                            SubDatagramByteCNT<=SubDatagramByteCNT+1'b1;
                        else begin
                            if(SubDatagramByteCNT>=(SubDatagram_Datalength+16'd9))
                                SubDatagramByteCNT<=16'd0;
                            else
                                SubDatagramByteCNT<=SubDatagramByteCNT+1'b1;
                        end
                    end
                end
                else
                    SubDatagramByteCNT<=16'd0;
                    
                if(SubDatagramIndicate)begin
                    if(TAG_ByteActive)begin
                        if((SubDatagramByteCNT==(SubDatagram_Datalength+16'd9))&&SubDatagram_NextFlag)
                            SubDatagramCNT<=SubDatagramCNT+1'b1;
                    end
                end
                else
                    SubDatagramCNT<=16'd0;
            end
        end
            
    end
    


endmodule
