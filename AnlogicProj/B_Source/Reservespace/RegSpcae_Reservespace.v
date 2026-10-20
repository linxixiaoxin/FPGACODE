module RegSpcae_Reservespace(
    input                       clk,
    input                       rst,
    //data & addr bus
    input                       CS,
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,
    output              [15:0]  RDDATA
    );
    
    wire            RD;
    wire            WR;
    assign  RD = CS&&(RDLWRH==1'b0);
    assign  WR = CS&&(RDLWRH==1'b1);
    
    
SimpleDualPortRAM 
    #(
    .DATAWIDTH(16),
    .ADDRESSWIDTH(4),
    .DATANum(16)
    )
    SimpleDualPortRAM(
    .WRclk(clk),
    .WRADDR(ADDR[3:0]),
    .WRDATA(WRDATA),
    .WR(WR),
    .RDclk(clk),
    .RDADDR(ADDR[3:0]),
    .RDDATA(RDDATA),
    .RD(RD)
    ); 

endmodule
