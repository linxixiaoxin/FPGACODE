module Slave100MHz_IndependentRead(
    input                   clk,
    input                   rst,
    
    input                   RXDV,
    input                   RXD,
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
    
    output  reg             RDPluse,
    output  reg [15:0]      RDADDR,
    input       [15:0]      RDDATA,
    input                   RDValid,
    
    output                  ReplaceFlag,
    output  reg             TXD
    );
    

    reg RDEN;
    reg [15:0]  LoadByte0;
    reg [15:0]  LoadByte1;
    reg         LoadByteFalg;
    reg         LoadByte0_ReplaceFlag;
    reg         LoadByte1_ReplaceFlag;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            RDEN<=1'b0;
        else begin
            if(SubDatagramIndicate)begin
                if(SubDatagramByteCNT==16'd0)
                    RDEN<=1'b0;
                else begin
                    if(SubDatagram_CMDValid)begin
                        if((SubDatagram_CMD==8'h12)&&(SubDatagram_SlaveAddr==SetSlaveAddr))begin
                            RDEN<=1'b1;
                        end
                    end
                end
            end
            else begin
                RDEN<=1'b0;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            RDADDR<=16'd0;
        else begin
            if(SubDatagram_CMDValid)
                RDADDR<=SubDatagram_LocalAddr;
            else begin
                if(RDEN && TAG_ByteActive &&(SubDatagramByteCNT>=16'd8))begin
                    if(SubDatagramByteCNT[2:0]==3'b000)
                        RDADDR[15:8]<=TAG_ByteStream;
                    else if(SubDatagramByteCNT[2:0]==3'b001)
                        RDADDR[7:0]<=TAG_ByteStream;
                    else if(SubDatagramByteCNT[2:0]==3'b110)
                        RDADDR[15:8]<=TAG_ByteStream;
                    else if(SubDatagramByteCNT[2:0]==3'b111)
                        RDADDR[7:0]<=TAG_ByteStream;                        
                end
            end
        end
    end
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RDPluse<=1'b0;
            LoadByteFalg<=1'b0;
        end
        else begin
            if(RDEN)begin
                if(SubDatagram_Datalength>16'd0)begin
                    RDPluse <= TAG_ByteActive && 
                                (SubDatagramByteCNT>=16'd9) && 
                                (SubDatagramByteCNT<=(SubDatagram_Datalength+16'd7) && 
                                ((SubDatagramByteCNT[2:0]==3'b001)||(SubDatagramByteCNT[2:0]==3'b111)));
                                
                    if(TAG_ByteActive && 
                                (SubDatagramByteCNT>=16'd9) && 
                                (SubDatagramByteCNT<=(SubDatagram_Datalength+16'd7) && 
                                ((SubDatagramByteCNT[2:0]==3'b001)||(SubDatagramByteCNT[2:0]==3'b111))))
                        LoadByteFalg<=!LoadByteFalg;
                    
                end
                else
                    RDPluse<=1'b0;
            end
            else begin
                RDPluse<=(SubDatagram_CMDValid && 
                            (SubDatagram_CMD==8'h12)&&
                            (SubDatagram_SlaveAddr==SetSlaveAddr));
                            
                if(SubDatagram_CMDValid && 
                            (SubDatagram_CMD==8'h12)&&
                            (SubDatagram_SlaveAddr==SetSlaveAddr))
                    LoadByteFalg<=1'b0;
            end
        end
    end
    

    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            LoadByte0<=16'd0;
            LoadByte1<=16'd0;
        end
        else begin
            if(RDValid)begin
                if(LoadByteFalg==1'b0)
                    LoadByte0<=RDDATA;
                else
                    LoadByte1<=RDDATA;
            end
        end
    end
    

    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            LoadByte0_ReplaceFlag<=1'b0;
            LoadByte1_ReplaceFlag<=1'b0;
        end
        else begin
            if(RDEN)begin
                if(TAG_ByteActive)begin
                    if((SubDatagramByteCNT>=16'd7) && (SubDatagramByteCNT<(SubDatagram_Datalength+16'd7)))begin
                        if(SubDatagramByteCNT[2:0]==3'b001)
                            LoadByte0_ReplaceFlag<=1'b1;
                        else if(SubDatagramByteCNT[2:0]==3'b011)
                            LoadByte0_ReplaceFlag<=1'b0;
                            
                        if(SubDatagramByteCNT[2:0]==3'b011)
                            LoadByte1_ReplaceFlag<=1'b1;
                        else if(SubDatagramByteCNT[2:0]==3'b101)
                            LoadByte1_ReplaceFlag<=1'b0;
                    end
                    else begin
                        LoadByte0_ReplaceFlag<=1'b0;
                        LoadByte1_ReplaceFlag<=1'b0;
                    end
                end
            end
            else begin
                LoadByte0_ReplaceFlag<=1'b0;
                LoadByte1_ReplaceFlag<=1'b0;
            end
        end
    end
    
    //Replace ======================================
    assign ReplaceFlag = LoadByte0_ReplaceFlag || LoadByte1_ReplaceFlag;
    
    reg [3:0]   BitCNT;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            BitCNT<=3'd0;
        else begin
            if(ReplaceFlag)begin
                BitCNT<=BitCNT+3'd1;
            end
            else
                BitCNT<=3'd0;
        end
    end
    
    
    always @ (*)begin
        if(LoadByte0_ReplaceFlag)begin
            case(BitCNT)
            4'd0:TXD = LoadByte0[8];
            4'd1:TXD = LoadByte0[9];
            4'd2:TXD = LoadByte0[10];
            4'd3:TXD = LoadByte0[11];
            4'd4:TXD = LoadByte0[12];
            4'd5:TXD = LoadByte0[13];
            4'd6:TXD = LoadByte0[14];
            4'd7:TXD = LoadByte0[15];
            4'd8:TXD = LoadByte0[0];
            4'd9:TXD = LoadByte0[1];
            4'd10:TXD = LoadByte0[2];
            4'd11:TXD = LoadByte0[3];
            4'd12:TXD = LoadByte0[4];
            4'd13:TXD = LoadByte0[5];
            4'd14:TXD = LoadByte0[6];
            4'd15:TXD = LoadByte0[7];
            default:TXD = 1'b0;
            endcase
        end
        else if(LoadByte1_ReplaceFlag)begin
            case(BitCNT)
            4'd0:TXD = LoadByte1[8];
            4'd1:TXD = LoadByte1[9];
            4'd2:TXD = LoadByte1[10];
            4'd3:TXD = LoadByte1[11];
            4'd4:TXD = LoadByte1[12];
            4'd5:TXD = LoadByte1[13];
            4'd6:TXD = LoadByte1[14];
            4'd7:TXD = LoadByte1[15];
            4'd8:TXD = LoadByte1[0];
            4'd9:TXD = LoadByte1[1];
            4'd10:TXD = LoadByte1[2];
            4'd11:TXD = LoadByte1[3];
            4'd12:TXD = LoadByte1[4];
            4'd13:TXD = LoadByte1[5];
            4'd14:TXD = LoadByte1[6];
            4'd15:TXD = LoadByte1[7];
            default:TXD = 1'b0;
            endcase
        end
        else
            TXD = RXD;
    end
    
    
    

endmodule
