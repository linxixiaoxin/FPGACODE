module UARTServiceForDMC(
    input                   clk,
    input                   rst,
    
    input                   TXRXSwitch,//0: RXDen 1: RXDen
    input                   TXTrig,
    input           [7:0]   TXDATA,
    output                  TXedPluse,
    output                  RxedPluse,
    output          [7:0]   RXDATA,
    
    input                   DMC_IN,//485 TX
    output                  DMC_OUT,//485 RX
    output                  DMC_DE//485 EN
    );
    
    assign DMC_DE = TXRXSwitch;
    
UART_BYTETX_forDMC UART_BYTETX_forDMC_inst(
	.clk(clk),
	.rst(rst),
			
	.trig(TXTrig),
	.DATA_in(TXDATA),
	.Finishpluse(TXedPluse),
    .TXD(DMC_OUT)
    );    
    
UART_BYTERX_forDMC UART_BYTERX_forDMC_inst(
    .clk(clk),
    .rst(rst),
    .RXD(DMC_IN),
    .DATA_RX(RXDATA),
    .RXPluse(RxedPluse)
	);
    
    
endmodule
