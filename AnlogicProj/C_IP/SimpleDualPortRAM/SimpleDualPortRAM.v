module SimpleDualPortRAM 
    #(
    parameter   DATAWIDTH       =   16,
    parameter   ADDRESSWIDTH    =   6,
    parameter   DATANum         =   64
    )
    (
    input                           WRclk,
    input       [ADDRESSWIDTH-1:0]  WRADDR,
    input       [DATAWIDTH-1:0]     WRDATA,
    input                           WR,
    input                           RDclk,
    input       [ADDRESSWIDTH-1:0]  RDADDR,
    output      [DATAWIDTH-1:0]     RDDATA,
    input                           RD
    );
    
AnlogicDPRAM 
    #(
    .DATA_WIDTH_A(DATAWIDTH),
    .ADDR_WIDTH_A(ADDRESSWIDTH),
    .DATA_DEPTH_A(DATANum),
    .DATA_WIDTH_B(DATAWIDTH),
    .ADDR_WIDTH_B(ADDRESSWIDTH),
    .DATA_DEPTH_B(DATANum)
    )
    AnlogicDPRAM( 
    .doa(),
	.dia(WRDATA), 
    .addra(WRADDR), 
    .clka(WRclk),
    .wea(WR),
    
	.dob(RDDATA), 
    .dib(),
    .addrb(RDADDR), 
    .ceb(RD),
    .clkb(RDclk), 
    .web(1'b0)
    );
    
     
/*     reg [DATAWIDTH-1:0] BufferData[0:DATANum-1];
    
    always @ (posedge WRclk)begin
        if(WR==1'b1)begin
            BufferData[WRADDR]<=WRDATA;
        end
    end
    
    always @ (posedge RDclk)begin
        if(RD==1'b1)begin
            RDDATA<=BufferData[RDADDR];
        end
    end */
    
endmodule
