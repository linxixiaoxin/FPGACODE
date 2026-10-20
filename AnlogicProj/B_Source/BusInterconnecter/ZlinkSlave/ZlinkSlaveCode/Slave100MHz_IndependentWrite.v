module Slave100MHz_IndependentWrite(
    input                   clk,
    input                   rst,
    
    input       [7:0]       TAG_ByteStream, 
    input                   TAG_ByteActive, 
    
    input                   SubDatagramIndicate,
    input       [15:0]      SubDatagramCNT,
    input       [15:0]      SubDatagramByteCNT,
    input       [7:0]       SubDatagram_CMD,
    input       [7:0]       SubDatagram_SlaveAddr,
    input       [15:0]      SubDatagram_LocalAddr,
    input       [15:0]      SubDatagram_Datalength,
    input                   SubDatagram_NextFlag,
    input                   SubDatagram_CMDValid,
    
    input       [7:0]       SetSlaveAddr,
    
    output  reg             WRPluse,
    output  reg [15:0]      WRADDR,
    output  reg [15:0]      WRDATA
    );
    
    reg WREN;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            WREN<=1'b0;
        else begin
            if(SubDatagramIndicate)begin
                if(SubDatagramByteCNT==16'd0)
                    WREN<=1'b0;
                else begin
                    if(SubDatagram_CMDValid)begin
                        if((SubDatagram_CMD==8'h01)||
                            ((SubDatagram_CMD==8'h11)&&(SubDatagram_SlaveAddr==SetSlaveAddr)))begin
                            WREN<=1'b1;
                        end
                    end
                end
            end
            else begin
                WREN<=1'b0;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            WRADDR<=16'd0;
        else begin
            if(SubDatagram_CMDValid)
                WRADDR<=SubDatagram_LocalAddr;
            else begin
                if(WREN && TAG_ByteActive &&(SubDatagramByteCNT>=16'd8))begin
                    if(SubDatagramByteCNT[1:0]==2'b10)
                        WRADDR[15:8]<=TAG_ByteStream;
                    else if(SubDatagramByteCNT[1:0]==2'b11)
                        WRADDR[7:0]<=TAG_ByteStream;
                end
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            WRDATA<=16'd0;
        else begin
            if(WREN && TAG_ByteActive&&(SubDatagramByteCNT>=16'd8))begin
                if(SubDatagramByteCNT[1:0]==2'b00)
                    WRDATA[15:8]<=TAG_ByteStream;
                else if(SubDatagramByteCNT[1:0]==2'b01)
                    WRDATA[7:0]<=TAG_ByteStream;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            WRPluse<=1'b0;
        else begin
            if(WREN)begin
                if(SubDatagram_Datalength>16'd0)begin
                    WRPluse <= TAG_ByteActive && 
                                (SubDatagramByteCNT>=16'd9) && 
                                (SubDatagramByteCNT<=(SubDatagram_Datalength+16'd7) && 
                                (SubDatagramByteCNT[1:0]==2'b01));
                end
                else
                    WRPluse<=1'b0;
            end
        end
    end
    
    


endmodule
