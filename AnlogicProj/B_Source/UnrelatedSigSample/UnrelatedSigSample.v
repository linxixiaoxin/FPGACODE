module UnrelatedSigSample(
    input                       clk100Mhz,
    input                       clk20Mhz,
    input                       rst,
    //hardware interface
    output                      VBUSClk,
    input                       VBUSDataIn,
    
    input           [15:0]      DigitalInput,
    output          [15:0]      DigitalOutput,
    
    input                       ASide_SD,
    output                      ASide_RQ,
    output                      ASide_DRCNT,
    
    input                       DSide_SD,
    output                      DSide_RQ,
    output                      DSide_DRCNT,
    //data & addr bus
    input                       RDLWRH,
    input           [15:0]      ADDR,
    input           [15:0]      WRDATA,    
    input                       CS,
    output          [15:0]      RDDATA   
    );
    
    wire    [15:0]  Vbus;
    wire    [15:0]  DIs;
    wire    [15:0]  DOs;
    wire [31:0] PositionFB_Aside;
    wire [31:0] PositionFB_Dside;
    
RegSpcae_UnrelatedSigSample RegSpcae_UnrelatedSigSample(
    .clk(clk100Mhz),
    .rst(rst),
    //data & addr bus
    .CS(CS),
    .RDLWRH(RDLWRH),
    .ADDR(ADDR),
    .WRDATA(WRDATA),
    .RDDATA(RDDATA),
    
    //inner reg interface
    .Vbus(Vbus),
    .DIs(DIs),
    .DOs(DOs),
    .PositionFB_Aside(PositionFB_Aside),
    .PositionFB_Dside(PositionFB_Dside)
    );
    
    
DriversMux DriversMux(
    .clk(clk100Mhz),//100Mhz
    .clk20Mhz(clk20Mhz),
    .rst(rst),
    //hardware interface
    .VBUSClk(VBUSClk),
    .VBUSDataIn(VBUSDataIn),
    
    .DigitalInput(DigitalInput),
    .DigitalOutput(DigitalOutput),
    
    //Internal data
    .Vbus(Vbus),
    .DIs(DIs),
    .DOs(DOs)
    );
    

LiteDMCProtocol_Monitor Aside(
    .clk(clk100Mhz),
    .rst(rst),

    .PositionFB(PositionFB_Aside),

    .DMC_IN(ASide_SD),//485 TX
    .DMC_OUT(ASide_RQ),//485 RX
    .DMC_DE(ASide_DRCNT)//485 EN
    );
LiteDMCProtocol_Monitor Dside(
    .clk(clk100Mhz),
    .rst(rst),

    .PositionFB(PositionFB_Dside),

    .DMC_IN(DSide_SD),//485 TX
    .DMC_OUT(DSide_RQ),//485 RX
    .DMC_DE(DSide_DRCNT)//485 EN
    );
    
endmodule
