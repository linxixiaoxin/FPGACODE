module AppEnvironment(
    //======Clks and Reset===============================
    input               clk,//50Mhz input 
    //======MCU Async Bus================================
    input       [15:0]  AsyncADDRBus,
    inout       [15:0]  AsyncDATABus,
    input               AsyncCS,
    input               AsyncWE0,
    input               AsyncRD,
    
    input               AsyncWE1,
    input               AsyncRD_WR,
    input               AsyncWAIT,
    input               AsyncBS,
    
    output              INT2MCU,
    //======Debug Module Interface========================
    //UART
    //input               RXD,//PHY-RX0:R7
    //output              TXD,//PHY-TX0:T4
    //RMII
    input               PHY_REFCLK,
    input               PHY_CRSDV,    
    input       [1:0]   PHY_RXD,
    output              PHY_TXEN,
    output      [1:0]   PHY_TXD,
    inout               PHY_MDIO,
    output              PHY_MDC,     
    
    input               PHY_REFCLK2,
    input               PHY_CRSDV2,    
    input       [1:0]   PHY_RXD2,
    output              PHY_TXEN2,
    output      [1:0]   PHY_TXD2,
    inout               PHY_MDIO2,
    output              PHY_MDC2,    
    
    output              LED,
    //======SPI slave Interface==========================
    input               SPI_SEL,//TESTIO1:K12
    input               SPI_CLK,//TESTIO2:K14
    input               SPI_MOSI,//TESTIO3:J12
    output              SPI_MISO,//TESTIO4:J13
    //======Current Sample===============================
    output              A_MCLKU,
    input               A_MDATU,
    output              A_MCLKV,
    input               A_MDATV,
    
    output              B_MCLKU,
    input               B_MDATU,
    output              B_MCLKV,
    input               B_MDATV,
    
    output              C_MCLKU,
    input               C_MDATU,
    output              C_MCLKV,
    input               C_MDATV,

    output              D_MCLKU,
    input               D_MDATU,
    output              D_MCLKV,
    input               D_MDATV,    
    //======Position Sample==============================
    input               A_PluseA,
    input               A_PluseB,
    input               A_PluseZ,  
    
    input               A_ENC_IN,
    output              A_ENC_OUT,
    output              A_ENC_DE,
    output              A_BISSCCLK,   
    
    input               B_ENC_IN,
    output              B_ENC_OUT,
    output              B_ENC_DE,
    output              B_BISSCCLK,     

    input               C_ENC_IN,
    output              C_ENC_OUT,
    output              C_ENC_DE,
    output              C_BISSCCLK,      

    input               D_ENC_IN,
    output              D_ENC_OUT,
    output              D_ENC_DE,   
    output              D_BISSCCLK,     
    
    input               ADD485_1_IN,
    output              ADD485_1_OUT,
    output              ADD485_1_DE,
    input               ADD485_2_IN,
    output              ADD485_2_OUT,
    output              ADD485_2_DE, 
    input               ADD485_3_IN,
    output              ADD485_3_OUT,
    output              ADD485_3_DE, 
    input               ADD485_4_IN,
    output              ADD485_4_OUT,
    output              ADD485_4_DE,
    //======PWM Drivers==================================
    output              STOout,
    
    output              A_PWMEN_L,
    output              A_PU,
    output              A_NU,
    output              A_PV,
    output              A_NV,
    output              A_PW,
    output              A_NW,
    input               A_IPMFo_L,
    
    output              B_PWMEN_L,
    output              B_PU,
    output              B_NU,
    output              B_PV,
    output              B_NV,
    output              B_PW,
    output              B_NW,    
    input               B_IPMFo_L,

    output              C_PWMEN_L,
    output              C_PU,
    output              C_NU,
    output              C_PV,
    output              C_NV,
    output              C_PW,
    output              C_NW,  
    input               C_IPMFo_L,
    
    output              D_PWMEN_L,
    output              D_PU,
    output              D_NU,
    output              D_PV,
    output              D_NV,
    output              D_PW,
    output              D_NW,
    input               D_IPMFo_L,
    //======UnrelatedSigs==================================
    output              CLK_BUS,
    input               DAT_BUS
    // input       [15:0]  DigitalInputs,
    // output      [15:0]  DigitalOutputs    
    );
    //reset generate================================================================
    wire rstin;
    reg [7:0]  CNT0;
    always @ (posedge clk)begin
        if(CNT0!=8'd254)
            CNT0<=CNT0+1'b1;
    end
    assign rstin = (CNT0==8'd254);
    
    //tri-state bus deal=============================================================
    wire    [15:0]    AsyncDATABus_out;
    assign AsyncDATABus = ((!AsyncCS) && (!AsyncRD))? AsyncDATABus_out:{16{1'bz}};
    
    wire    A_PWMEN;
    wire    B_PWMEN;
    wire    C_PWMEN;
    wire    D_PWMEN;
    assign A_PWMEN_L = !A_PWMEN;
    assign B_PWMEN_L = !B_PWMEN;
    assign C_PWMEN_L = !C_PWMEN;
    assign D_PWMEN_L = !D_PWMEN;
    
   
    wire    A_PU_pre;
    wire    A_NU_pre;
    wire    A_PV_pre;
    wire    A_NV_pre;
    wire    A_PW_pre;
    wire    A_NW_pre;
    wire    B_PU_pre;
    wire    B_NU_pre;
    wire    B_PV_pre;
    wire    B_NV_pre;
    wire    B_PW_pre;
    wire    B_NW_pre;
    wire    C_PU_pre;
    wire    C_NU_pre;
    wire    C_PV_pre;
    wire    C_NV_pre;
    wire    C_PW_pre;
    wire    C_NW_pre;
    wire    D_PU_pre;
    wire    D_NU_pre;
    wire    D_PV_pre;
    wire    D_NV_pre;
    wire    D_PW_pre;
    wire    D_NW_pre;
    
    
    //direct output
    assign A_PU = A_PU_pre;
    assign A_NU = A_NU_pre;
    assign A_PV = A_PV_pre;
    assign A_NV = A_NV_pre;
    assign A_PW = A_PW_pre;
    assign A_NW = A_NW_pre;
    assign B_PU = B_PU_pre;
    assign B_NU = B_NU_pre;
    assign B_PV = B_PV_pre;
    assign B_NV = B_NV_pre;
    assign B_PW = B_PW_pre;
    assign B_NW = B_NW_pre;
    assign C_PU = C_PU_pre;
    assign C_NU = C_NU_pre;
    assign C_PV = C_PV_pre;
    assign C_NV = C_NV_pre;
    assign C_PW = C_PW_pre;
    assign C_NW = C_NW_pre;
    assign D_PU = D_PU_pre;
    assign D_NU = D_NU_pre;
    assign D_PV = D_PV_pre;
    assign D_NV = D_NV_pre;
    assign D_PW = D_PW_pre;
    assign D_NW = D_NW_pre;

    //48V
/*     assign A_PU = A_PW_pre;
    assign A_NU = !A_NW_pre;
    assign A_PV = A_PV_pre;
    assign A_NV = !A_NV_pre;
    assign A_PW = A_PU_pre;
    assign A_NW = !A_NU_pre;
    
    assign B_PU = B_PW_pre;
    assign B_NU = !B_NW_pre;
    assign B_PV = B_PV_pre;
    assign B_NV = !B_NV_pre;
    assign B_PW = B_PU_pre;
    assign B_NW = !B_NU_pre;
    
    assign C_PU = C_PW_pre;
    assign C_NU = !C_NW_pre;
    assign C_PV = C_PV_pre;
    assign C_NV = !C_NV_pre;
    assign C_PW = C_PU_pre;
    assign C_NW = !C_NU_pre;
    
    assign D_PU = D_PW_pre;
    assign D_NU = !D_NW_pre;
    assign D_PV = D_PV_pre;
    assign D_NV = !D_NV_pre;
    assign D_PW = D_PU_pre;
    assign D_NW = !D_NU_pre; */
    
FourAxisesDriver FourAxisesDriver(
    //======Clks and Reset===============================
    .clk(clk),
    .rstin(rstin),
    //======Access Interface=============================
    .Master1Sel(4'd1),
    .Master2Sel(4'd2),
    
    .RXD(1'b0),//PHY-RX0:R7; PHY_RXD[0]
    .TXD(),//PHY-TX0:T4 ;PHY_TXD[0]
    
    .PHY_REFCLK(PHY_REFCLK),
    .PHY_CRSDV(PHY_CRSDV),    
    .PHY_RXD(PHY_RXD),
    .PHY_TXEN(PHY_TXEN),
    .PHY_TXD(PHY_TXD),
    .PHY_MDIO(PHY_MDIO),
    .PHY_MDC(PHY_MDC),  
    
    .PHY_REFCLK2(PHY_REFCLK2),
    .PHY_CRSDV2(PHY_CRSDV2),    
    .PHY_RXD2(PHY_RXD2),
    .PHY_TXEN2(PHY_TXEN2),
    .PHY_TXD2(PHY_TXD2),
    .PHY_MDIO2(PHY_MDIO2),
    .PHY_MDC2(PHY_MDC2),  
    
    .SPI_SEL(SPI_SEL),
    .SPI_CLK(SPI_CLK),
    .SPI_MOSI(SPI_MOSI),
    .SPI_MISO(SPI_MISO),
    
    .AsyncADDRBus({1'b0,AsyncADDRBus[15:1]}),
    .AsyncDATABus_in(AsyncDATABus),
    .AsyncDATABus_out(AsyncDATABus_out),
    .AsyncCS(AsyncCS),
    .AsyncWE0(AsyncWE0),
    .AsyncRD(AsyncRD),    
    .AsyncNADV(1'b0),
    
    .INTOut(INT2MCU),
    //======Current Sample===============================
    .A_MCLKU(A_MCLKU),
    .A_MDATU(A_MDATU),
    .A_MCLKV(A_MCLKV),
    .A_MDATV(A_MDATV),
    .B_MCLKU(B_MCLKU),
    .B_MDATU(B_MDATU),
    .B_MCLKV(B_MCLKV),
    .B_MDATV(B_MDATV),
    .C_MCLKU(C_MCLKU),
    .C_MDATU(C_MDATU),
    .C_MCLKV(C_MCLKV),
    .C_MDATV(C_MDATV),
    .D_MCLKU(D_MCLKU),
    .D_MDATU(D_MDATU),
    .D_MCLKV(D_MCLKV),
    .D_MDATV(D_MDATV),    
    //======Position Sample==============================
    .A_PluseA(A_PluseA),
    .A_PluseB(A_PluseB),
    .A_PluseZ(A_PluseZ),     
    .A_SD(A_ENC_IN),//485_RX
    .A_RQ(A_ENC_OUT),//485_TX
    .A_DRCNT(A_ENC_DE),//485_EN
    .A_BISSCCLK(A_BISSCCLK),
    .B_SD(B_ENC_IN),//485_RX
    .B_RQ(B_ENC_OUT),//485_TX
    .B_DRCNT(B_ENC_DE), //485_EN 
    .B_BISSCCLK(B_BISSCCLK),
    .C_SD(C_ENC_IN),//485_RX
    .C_RQ(C_ENC_OUT),//485_TX
    .C_DRCNT(C_ENC_DE), //485_EN 
    .C_BISSCCLK(C_BISSCCLK),
    .D_SD(D_ENC_IN),//485_RX
    .D_RQ(D_ENC_OUT),//485_TX
    .D_DRCNT(D_ENC_DE), //485_EN   
    .D_BISSCCLK(D_BISSCCLK),   
    //======PWM Drivers==================================
    .STOout(STOout),
    .A_PWMEN(A_PWMEN),
    .A_PU(A_PU_pre),
    .A_NU(A_NU_pre),
    .A_PV(A_PV_pre),
    .A_NV(A_NV_pre),
    .A_PW(A_PW_pre),
    .A_NW(A_NW_pre),
    .A_IPMFo(!A_IPMFo_L),
    .B_PWMEN(B_PWMEN),
    .B_PU(B_PU_pre),
    .B_NU(B_NU_pre),
    .B_PV(B_PV_pre),
    .B_NV(B_NV_pre),
    .B_PW(B_PW_pre),
    .B_NW(B_NW_pre),    
    .B_IPMFo(!B_IPMFo_L),
    .C_PWMEN(C_PWMEN),
    .C_PU(C_PU_pre),
    .C_NU(C_NU_pre),
    .C_PV(C_PV_pre),
    .C_NV(C_NV_pre),
    .C_PW(C_PW_pre),
    .C_NW(C_NW_pre),  
    .C_IPMFo(!C_IPMFo_L),
    .D_PWMEN(D_PWMEN),
    .D_PU(D_PU_pre),
    .D_NU(D_NU_pre),
    .D_PV(D_PV_pre),
    .D_NV(D_NV_pre),
    .D_PW(D_PW_pre),
    .D_NW(D_NW_pre),
    .D_IPMFo(!D_IPMFo_L),
    //======UnrelatedSigs==================================
    .CLK_BUS(CLK_BUS),
    .DAT_BUS(DAT_BUS),
    .DigitalInputs(16'd0),
    .DigitalOutputs(),

    .ASide_SD(ADD485_2_IN),
    .ASide_RQ(ADD485_2_OUT),
    .ASide_DRCNT(ADD485_2_DE),
    
    .DSide_SD(ADD485_4_IN),
    .DSide_RQ(ADD485_4_OUT),
    .DSide_DRCNT(ADD485_4_DE)  
    );
    
    assign ADD485_1_DE = 1'b0;
    assign ADD485_1_OUT = 1'b0;
    assign ADD485_3_DE = 1'b0;
    assign ADD485_3_OUT = 1'b0;
    

    //work LED=======================================================================
    localparam Period = 32'd5000000;//100ms:32'd5000000
    localparam Period_2 = 32'd2500000;//50ms:32'd2500000
    reg [31:0]  CNT;
    always @ (posedge clk)begin
        if(CNT<=Period)
            CNT<=CNT+1'b1;
        else
            CNT<=32'd0;
    end
    assign LED = (CNT<Period_2);

	//temp code=====================================================================
    reg       [15:0]  AsyncADDRBus_1;//synthesis keep = 1;
    reg       [15:0]  AsyncDATABus_1;//synthesis keep = 1;
    reg               AsyncCS_1;//synthesis keep = 1;
    reg               AsyncWE0_1;//synthesis keep = 1;
    reg               AsyncRD_1;//synthesis keep = 1;
    
    reg               AsyncWE1_1;//synthesis keep = 1;
    reg               AsyncRD_WR_1;//synthesis keep = 1;
    reg               AsyncWAIT_1;//synthesis keep = 1;
    reg               AsyncBS_1;//synthesis keep = 1;
    always @ (posedge clk)begin
        AsyncADDRBus_1<=AsyncADDRBus;
        AsyncDATABus_1<=AsyncDATABus;
        AsyncCS_1<=AsyncCS;
        AsyncWE0_1<=AsyncWE0;
        AsyncRD_1<=AsyncRD;
		AsyncWE1_1<=AsyncWE1;
		AsyncRD_WR_1<=AsyncRD_WR;
		AsyncWAIT_1<=AsyncWAIT;
		AsyncBS_1<=AsyncBS;
    end
    
endmodule
