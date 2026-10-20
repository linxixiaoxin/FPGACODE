module Reservespace(
    input                       clk,
    input                       rst,
    //data & addr bus
    input                       CS,
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,
    output              [15:0]  RDDATA
    );
    
RegSpcae_Reservespace RegSpcae_Reservespace(
    .clk(clk),
    .rst(rst),
    //data & addr bus
    .CS(CS),
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .RDDATA(RDDATA)
    );
    
endmodule
