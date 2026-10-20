module DriversMux(
    input                       clk,//100Mhz
    input                       clk20Mhz,
    input                       rst,
    //hardware interface
    output                      VBUSClk,
    input                       VBUSDataIn,
    
    input           [15:0]      DigitalInput,
    output  reg     [15:0]      DigitalOutput,
    
    //Internal data
    output          [15:0]      Vbus,
    output          [15:0]      DIs,
    input           [15:0]      DOs
    );
    
    
    assign VBUSClk = clk20Mhz;
Sinc3Driver Sinc3Driver1(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk),
    .rst(rst), 
    .mdata1(VBUSDataIn), 
    .polarity(1'b1),
    .Offset(16'd0),
    .DataOut(Vbus)
    );
    
    
    reg [15:0]  DI_sync0;
    reg [15:0]  DI_sync1;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DI_sync0<=16'h0000;
            DI_sync1<=16'h0000;
        end
        else begin
            DI_sync0<=DigitalInput;
            DI_sync1<=DI_sync0;
        end
    end
    assign DIs = DI_sync1;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DigitalOutput<=16'h0000;
        end
        else begin
            DigitalOutput<=DOs;
        end
    end
    
    
    
endmodule
