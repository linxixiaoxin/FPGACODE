module ADCsDriver(
    input                       clk100Mhz,
    input                       clk20Mhz,
    input                       rst,
    //hardware interface
    output                      DSASCCLK,
    input                       Axis1_IUBitin,
    input                       Axis1_IVBitin,
    input                       Axis2_IUBitin,
    input                       Axis2_IVBitin,
    input                       Axis3_IUBitin,
    input                       Axis3_IVBitin,
    input                       Axis4_IUBitin,
    input                       Axis4_IVBitin,  
    //user set paras
    input               [1:0]   Axis1_polarity,//define Driver to Motor is positive, value is 1;Motor to Driver is negetive, value is 0
    input               [1:0]   Axis2_polarity,
    input               [1:0]   Axis3_polarity,
    input               [1:0]   Axis4_polarity,
    input       signed  [15:0]  Axis1_IU_Offset,
    input       signed  [15:0]  Axis1_IV_Offset,
    input       signed  [15:0]  Axis2_IU_Offset,
    input       signed  [15:0]  Axis2_IV_Offset,
    input       signed  [15:0]  Axis3_IU_Offset,
    input       signed  [15:0]  Axis3_IV_Offset,
    input       signed  [15:0]  Axis4_IU_Offset,
    input       signed  [15:0]  Axis4_IV_Offset,    
    //output data
    output      signed  [15:0]  Axis1_IU,
    output      signed  [15:0]  Axis1_IV,
    output      signed  [15:0]  Axis2_IU,
    output      signed  [15:0]  Axis2_IV,
    output      signed  [15:0]  Axis3_IU,
    output      signed  [15:0]  Axis3_IV,
    output      signed  [15:0]  Axis4_IU,
    output      signed  [15:0]  Axis4_IV
    );
    
    assign DSASCCLK = clk20Mhz;
    
    wire    signed  [15:0]  Axis1_IUW_pre;
    wire    signed  [15:0]  Axis2_IUW_pre;
    wire    signed  [15:0]  Axis3_IUW_pre;
    wire    signed  [15:0]  Axis4_IUW_pre;
    
    wire    signed  [16:0]  Axis1_IU_pre;
    wire    signed  [16:0]  Axis2_IU_pre;
    wire    signed  [16:0]  Axis3_IU_pre;
    wire    signed  [16:0]  Axis4_IU_pre;
    
    reg     signed  [15:0]  Axis1_IU_act;
    reg     signed  [15:0]  Axis2_IU_act;
    reg     signed  [15:0]  Axis3_IU_act;
    reg     signed  [15:0]  Axis4_IU_act;
    
    wire    signed  [15:0]  Axis1_IV_pre;
    wire    signed  [15:0]  Axis2_IV_pre;
    wire    signed  [15:0]  Axis3_IV_pre;
    wire    signed  [15:0]  Axis4_IV_pre;
    reg     signed  [15:0]  Axis1_IV_act;
    reg     signed  [15:0]  Axis2_IV_act;
    reg     signed  [15:0]  Axis3_IV_act;
    reg     signed  [15:0]  Axis4_IV_act;
    
Sinc3Driver Sinc3Driver1(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk100Mhz),
    .rst(rst), 
    .mdata1(Axis1_IUBitin), 
    .polarity(Axis1_polarity[0]),
    .Offset(Axis1_IU_Offset),
    .DataOut(Axis1_IUW_pre)
    );
Sinc3Driver Sinc3Driver2(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk100Mhz),
    .rst(rst), 
    .mdata1(Axis1_IVBitin), 
    .polarity(Axis1_polarity[1]),
    .Offset(Axis1_IV_Offset),
    .DataOut(Axis1_IV_pre)
    );  
  

Sinc3Driver Sinc3Driver4(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk100Mhz),
    .rst(rst), 
    .mdata1(Axis2_IUBitin), 
    .polarity(Axis2_polarity[0]),
    .Offset(Axis2_IU_Offset),
    .DataOut(Axis2_IUW_pre)
    ); 
Sinc3Driver Sinc3Driver5(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk100Mhz),
    .rst(rst), 
    .mdata1(Axis2_IVBitin), 
    .polarity(Axis2_polarity[1]),
    .Offset(Axis2_IV_Offset),
    .DataOut(Axis2_IV_pre)
    ); 

Sinc3Driver Sinc3Driver7(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk100Mhz),
    .rst(rst), 
    .mdata1(Axis3_IUBitin), 
    .polarity(Axis3_polarity[0]),
    .Offset(Axis3_IU_Offset),
    .DataOut(Axis3_IUW_pre)
    ); 
Sinc3Driver Sinc3Driver8(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk100Mhz),
    .rst(rst), 
    .mdata1(Axis3_IVBitin), 
    .polarity(Axis3_polarity[1]),
    .Offset(Axis3_IV_Offset),
    .DataOut(Axis3_IV_pre)
    ); 

Sinc3Driver Sinc3Driver10(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk100Mhz),
    .rst(rst), 
    .mdata1(Axis4_IUBitin), 
    .polarity(Axis4_polarity[0]),
    .Offset(Axis4_IU_Offset),
    .DataOut(Axis4_IUW_pre)
    ); 
Sinc3Driver Sinc3Driver11(
    .clk20Mhz(clk20Mhz), 
    .clk100Mhz(clk100Mhz),
    .rst(rst), 
    .mdata1(Axis4_IVBitin), 
    .polarity(Axis4_polarity[1]),
    .Offset(Axis4_IV_Offset),
    .DataOut(Axis4_IV_pre)
    ); 
    
    always @ (posedge clk100Mhz or negedge rst)begin
        if(!rst)begin
            Axis1_IV_act<=16'd0;
            Axis2_IV_act<=16'd0;
            Axis3_IV_act<=16'd0;
            Axis4_IV_act<=16'd0;
        end    
        else begin
            Axis1_IV_act<=Axis1_IV_pre;
            Axis2_IV_act<=Axis2_IV_pre;
            Axis3_IV_act<=Axis3_IV_pre;
            Axis4_IV_act<=Axis4_IV_pre;
        end
    end
    
    assign  Axis1_IU_pre = -($signed({Axis1_IUW_pre[15],Axis1_IUW_pre}))-($signed({Axis1_IV_pre[15],Axis1_IV_pre}));
    assign  Axis2_IU_pre = -($signed({Axis2_IUW_pre[15],Axis2_IUW_pre}))-($signed({Axis2_IV_pre[15],Axis2_IV_pre}));
    assign  Axis3_IU_pre = -($signed({Axis3_IUW_pre[15],Axis3_IUW_pre}))-($signed({Axis3_IV_pre[15],Axis3_IV_pre}));
    assign  Axis4_IU_pre = -($signed({Axis4_IUW_pre[15],Axis4_IUW_pre}))-($signed({Axis4_IV_pre[15],Axis4_IV_pre}));
    
    always @ (posedge clk100Mhz or negedge rst)begin
        if(!rst)begin
            Axis1_IU_act<=16'd0;
            Axis2_IU_act<=16'd0;
            Axis3_IU_act<=16'd0;
            Axis4_IU_act<=16'd0;
        end    
        else begin
/*             Axis1_IU_act<=Axis1_IUW_pre;
            Axis2_IU_act<=Axis2_IUW_pre;
            Axis3_IU_act<=Axis3_IUW_pre;
            Axis4_IU_act<=Axis4_IUW_pre; */
            
            case(Axis1_IU_pre[16:15])
                2'b10:begin
                    Axis1_IU_act<=$signed(16'd32767);
                end
                2'b01:begin
                    Axis1_IU_act<=$signed(-16'd32767);
                end
                default:begin
                    Axis1_IU_act<=Axis1_IU_pre[15:0];
                end
            endcase
            case(Axis2_IU_pre[16:15])
                2'b10:begin
                    Axis2_IU_act<=$signed(16'd32767);
                end
                2'b01:begin
                    Axis2_IU_act<=$signed(-16'd32767);
                end
                default:begin
                    Axis2_IU_act<=Axis2_IU_pre[15:0];
                end
            endcase
            case(Axis3_IU_pre[16:15])
                2'b10:begin
                    Axis3_IU_act<=$signed(16'd32767);
                end
                2'b01:begin
                    Axis3_IU_act<=$signed(-16'd32767);
                end
                default:begin
                    Axis3_IU_act<=Axis3_IU_pre[15:0];
                end
            endcase
            case(Axis4_IU_pre[16:15])
                2'b10:begin
                    Axis4_IU_act<=$signed(16'd32767);
                end
                2'b01:begin
                    Axis4_IU_act<=$signed(-16'd32767);
                end
                default:begin
                    Axis4_IU_act<=Axis4_IU_pre[15:0];
                end
            endcase            
            
        end
    end
    
    
    assign  Axis1_IU    =   Axis1_IU_act;
    assign  Axis1_IV    =   Axis1_IV_act;
    assign  Axis2_IU    =   Axis2_IU_act;
    assign  Axis2_IV    =   Axis2_IV_act; 
    assign  Axis3_IU    =   Axis3_IU_act;
    assign  Axis3_IV    =   Axis3_IV_act;
    assign  Axis4_IU    =   Axis4_IU_act;
    assign  Axis4_IV    =   Axis4_IV_act;    
    

    
endmodule
