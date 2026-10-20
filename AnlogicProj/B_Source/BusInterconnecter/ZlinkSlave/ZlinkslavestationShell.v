module ZlinkslavestationShell(
    input                   clk,
    input                   rst,
    //Port0
    input                   PHY_REFCLK0,
    input                   PHY_CRSDV0,    
    input           [1:0]   PHY_RXD0,
    output                  PHY_TXEN0,
    output          [1:0]   PHY_TXD0,
    inout                   PHY_MDIO0,
    output                  PHY_MDC0,
    //Port1
    input                   PHY_REFCLK1,
    input                   PHY_CRSDV1,    
    input           [1:0]   PHY_RXD1,
    output                  PHY_TXEN1,
    output          [1:0]   PHY_TXD1,
    inout                   PHY_MDIO1,
    output                  PHY_MDC1,
    //==
    output                  UserSpace_RD,
    output                  UserSpace_WR,
    output          [15:0]  UserSpace_ADDR,
    output          [15:0]  UserSpace_WRDATA,
    input           [15:0]  UserSpace_RDDATA,
    input                   UserSpace_RDDATAVALID
);

    wire Linkstate0;
    wire RXDV0;
    wire RXD0;
    wire TXEN0;
    wire TXD0;
    wire Linkstate1;
    wire RXDV1;
    wire RXD1;
    wire TXEN1;
    wire TXD1;
Zlinkslavestation slavestation(
    .clk(clk),
    .rst(rst),
    //port link state
    .Linkstate0(Linkstate0),
    .Linkstate1(Linkstate1),
    //Port0
    .RXDV0(RXDV0),
    .RXD0(RXD0),
    .TXEN0(TXEN0),
    .TXD0(TXD0),
    //Port1
    .RXDV1(RXDV1),
    .RXD1(RXD1),
    .TXEN1(TXEN1),
    .TXD1(TXD1),
    //Local Space Access Interface
    .ZlinkS_RE(UserSpace_RD),
    .ZlinkS_WE(UserSpace_WR),
    .ZlinkS_XA(UserSpace_ADDR),
    .ZlinkS_XDout(UserSpace_WRDATA),
    .ZlinkS_XDinValid(UserSpace_RDDATAVALID),
    .ZlinkS_XDin(UserSpace_RDDATA) 
);

PhyInterface_1bit100Mhz PhyInterface(
    .clk(clk),//input clk 100Mhz
    .rst(rst),//input rst,low active
    //PHY-relating sets
    .PHY_address(5'd1),
    //phy managenent interface , and reset
    .MDC(PHY_MDC0),
    .MDIO(PHY_MDIO0),
    //MII/RMII interface
    .RMII_REFCLK(PHY_REFCLK0),
    .RMII_RXDV(PHY_CRSDV0),
    .RMII_RXD(PHY_RXD0),
    .RMII_TXEN(PHY_TXEN0),
    .RMII_TXD(PHY_TXD0),
    ////inner interface and phy link state
    .Linkstate(Linkstate0),
    .RXDV(RXDV0),
    .RXD(RXD0),
    .TXEN(TXEN0),
    .TXD(TXD0)
    );
    
PhyInterface_1bit100Mhz PhyInterface2(
    .clk(clk),//input clk 100Mhz
    .rst(rst),//input rst,low active
    //PHY-relating sets
    .PHY_address(5'd1),
    //phy managenent interface , and reset
    .MDC(PHY_MDC1),
    .MDIO(PHY_MDIO1),
    //MII/RMII interface
    .RMII_REFCLK(PHY_REFCLK1),
    .RMII_RXDV(PHY_CRSDV1),
    .RMII_RXD(PHY_RXD1),
    .RMII_TXEN(PHY_TXEN1),
    .RMII_TXD(PHY_TXD1),
    ////inner interface and phy link state
    .Linkstate(Linkstate1),
    .RXDV(RXDV1),
    .RXD(RXD1),
    .TXEN(TXEN1),
    .TXD(TXD1)
    );

endmodule
