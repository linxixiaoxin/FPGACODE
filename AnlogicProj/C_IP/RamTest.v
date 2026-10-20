module RamTest(
    input   clk,
    input   rst,
    
    input   testin,
    output  testsig
);

reg             WR;//synthesis keep = 1;FourAxisesDriver/RamTest/Counter
reg     [3:0]   WRADDR;//synthesis keep = 1;
reg     [7:0]   WRDATA;//synthesis keep = 1;

reg             RD;//synthesis keep = 1;
reg     [3:0]   RDADDR;//synthesis keep = 1;
wire    [7:0]   RDDATA;//synthesis keep = 1;

reg     [3:0]   Counter;//synthesis keep = 1;

always @ (posedge clk or negedge rst)begin
    if(!rst)begin
        Counter<=4'd0;
    end
    else begin
        Counter<=Counter+1'b1;
    end
end

always @ (posedge clk or negedge rst)begin
    if(!rst)begin
        WR<=1'b0;
        WRADDR<=4'd0;
        WRDATA<=8'd0;
    end
    else begin
        if(Counter<4'd5)begin
            WR<=1'b1;
            WRADDR<=Counter;
            WRDATA<=Counter+1;
        end
        else begin
            WR<=1'b0;
            WRADDR<=4'd0;
            WRDATA<=8'd0;
        end
    end
end

always @ (posedge clk or negedge rst)begin
    if(!rst)begin
        RD<=1'b0;
        RDADDR<=4'd0;
    end
    else begin
        if((Counter>=4'd8)&&(Counter<4'd13))begin
            RD<=1'b1;
            RDADDR<=Counter-4'd8;
        end
        else begin
            RD<=1'b0;
            RDADDR<=4'd0;
        end
    end
end

SimpleDualPortRAM 
    #(
    .DATAWIDTH(8),
    .ADDRESSWIDTH(4),
    .DATANum(16)  
    )
    SimpleDualPortRAM(
    .WRclk(clk),
    .WRADDR(WRADDR),
    .WRDATA(WRDATA),
    .WR(WR),
    .RDclk(clk),
    .RDADDR(RDADDR),
    .RDDATA(RDDATA),
    .RD(RD)
    );
    
    assign testsig = RDDATA=={testin,testin,testin,testin,testin,testin,testin,testin};

endmodule
