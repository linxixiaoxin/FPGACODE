module PhyInterface_1bit100Mhz(
    input               clk,//input clk 100Mhz
    input               rst,//input rst,low active
    //PHY-relating sets
    input       [4:0]   PHY_address,
    //phy managenent interface , and reset
    output              MDC,
    inout               MDIO,
    //MII/RMII interface
    input               RMII_REFCLK,
    input               RMII_RXDV,
    input       [1:0]   RMII_RXD,
    output              RMII_TXEN,
    output      [1:0]   RMII_TXD,
    ////inner interface and phy link state
    output              Linkstate,
    output              RXDV,
    output              RXD,
    input               TXEN,
    input               TXD
    );

PhyManage U1(
    .clk(clk),//input clk 100Mhz
    .rst(rst),//input rst,low active
    .PhyAddress(PHY_address),
    .Linkstate(Linkstate),
    .PHY_ID(),
    .MDC(MDC),//1Mhz clk, normal high
    .MDIO(MDIO)
    );
    
    wire            RMII_RXDV_EXT;
    wire    [1:0]   RMII_RXD_EXT;
CRSDV2RXDV U2(
    .clk(RMII_REFCLK),//input clk 50Mhz
    .rst(rst),//input rst,low active

    .RMII_RXDVorCRSDV_pre(RMII_RXDV),
    .RMII_RXD_pre(RMII_RXD),

    .RMII_RXDV(RMII_RXDV_EXT),
    .RMII_RXD(RMII_RXD_EXT) 
    ); 
    
Stream2bitTo1bit U3(
    .RMII_REFCLK(RMII_REFCLK),
    .RMII_RXDV_EXT(RMII_RXDV_EXT),
    .RMII_RXD_EXT(RMII_RXD_EXT),
    .clk(clk),
    .rst(rst),
    .RXDV(RXDV),
    .RXD(RXD)
    );
    
Stream1bitTo2bit  U4(
    .clk(clk),
    .rst(rst),
    .TXEN(TXEN),
    .TXD(TXD),

    .RMII_REFCLK(RMII_REFCLK),
    .RMII_TXEN_EXT(RMII_TXEN),
    .RMII_TXD_EXT(RMII_TXD)
    );
endmodule
