module Slave100MHz_CRCCal(
    input               clk,
    input               rst,

    input       [7:0]   ByteStream, 
    input               ByteActive,
    input               CalEn,
    
    input               ResultClr,
    output      [31:0]  CRCResult
    );
    

    reg [15:0]  FrameBytesCount;
    always @ (posedge clk or negedge rst)begin
        if(!rst) 
            FrameBytesCount<=16'd1;
        else begin
            if(CalEn)begin
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
    .ByteActive(ByteActive&&CalEn), 
    .FrameBytesCount(FrameBytesCount),
    .clr(!ResultClr),
    .CRC_Result(CRCResult)
    ); 
    


endmodule