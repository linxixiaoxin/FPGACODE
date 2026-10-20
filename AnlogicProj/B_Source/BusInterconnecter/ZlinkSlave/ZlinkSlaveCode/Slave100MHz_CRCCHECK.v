module Slave100MHz_CRCCHECK(
    input               clk,
    input               rst,

    input       [7:0]   ByteStream, 
    input               ByteActive,
    input       [3:0]   FrameDeal_State, 
    
    output  reg         CheckResult,
    output  reg         FrameOK,
    output  reg         CRC_Valid
    
    );
    
    reg [3:0]   FrameDeal_State_dly;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            FrameDeal_State_dly<=4'd0;
        else
            FrameDeal_State_dly<=FrameDeal_State;
    end
    

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            FrameOK<=1'b0;
        else begin
            FrameOK<=(FrameDeal_State_dly==4'd3)&&(FrameDeal_State==4'd0);
        end
    end


    wire            crc_en;
    wire            crc_rst;
    wire    [31:0]  crc32_sig;

    assign crc_rst = (FrameDeal_State==4'd1)?1'b0:1'b1;
    assign crc_en = ((FrameDeal_State==4'd2)||(FrameDeal_State==4'd3))&&ByteActive;

    reg [15:0]  FrameBytesCount;
    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            FrameBytesCount<=16'd1;
        else begin
            if((FrameDeal_State==4'd2)||(FrameDeal_State==4'd3))begin
                if(ByteActive)
                    FrameBytesCount<=FrameBytesCount+1'b1;
            end
            else
                FrameBytesCount<=16'd1;
        end 
    end
    
    
Slave100MHz_CRC32CORE CRC32CORE(
    .clk(clk),
    .rst(rst),

    .ByteStream(ByteStream), 
    .ByteActive(crc_en), 
    .FrameBytesCount(FrameBytesCount),
    .clr(crc_rst),//同步清零

    .CRC_Result(crc32_sig)//crc校验结果
    ); 
    
    reg ByteActive_dly;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            ByteActive_dly<=1'b0;
        end
        else begin
            ByteActive_dly<=ByteActive;
        end
    end
    
    
    reg [31:0] CRC32_PreSave1;
    reg [31:0] CRC32_PreSave2;
    reg [31:0] CRC32_PreSave3;
    reg [31:0] CRC32_Save;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CRC32_PreSave1<=32'd0;
            CRC32_PreSave2<=32'd0;
            CRC32_PreSave3<=32'd0;
            CRC32_Save<=32'd0;
        end
        else begin
            if((FrameDeal_State==4'd3)&&ByteActive)begin
                CRC32_PreSave1<=crc32_sig;
                CRC32_PreSave2<=CRC32_PreSave1;
                CRC32_PreSave3<=CRC32_PreSave2;
                CRC32_Save<=CRC32_PreSave3;
            end
        end
    end

    reg [31:0]  FrameFCS;
    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            FrameFCS<=32'd0;
        else begin
            if(FrameDeal_State==4'd1)begin
                FrameFCS<=32'd0;
            end
            else begin
                if((FrameDeal_State==4'd3)&&ByteActive)begin
                    FrameFCS[7:0]<=FrameFCS[15:8];
                    FrameFCS[15:8]<=FrameFCS[23:16];
                    FrameFCS[23:16]<=FrameFCS[31:24];
                    FrameFCS[31:24]<=ByteStream;
                end
            end
        end
    end
    
    wire CheckFalg;
    assign CheckFalg=(FrameDeal_State_dly!=4'd0)&&(FrameDeal_State==4'd0);//ByteActive_dly&&(FrameDeal_State==4'd0);
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CheckResult<=1'b0;
            CRC_Valid<=1'b0;
        end
        else begin
            CheckResult<=CheckFalg;
            CRC_Valid<=CheckFalg&&(FrameFCS==CRC32_Save);
        end
    end 

endmodule