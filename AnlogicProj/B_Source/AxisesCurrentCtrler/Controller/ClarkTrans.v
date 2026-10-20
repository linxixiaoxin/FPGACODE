/*
ClarkTrans ClarkTrans_inst(
    .clk(),
    .rst(),
    .trig(),
    .busy(),
    .finish(),

    .IU(),
    .IV(),
    .IALPHA(),
    .IBETA()
    );
    
    Trig(include) to finish(include): 2 clk
*/
module ClarkTrans(
    input                       clk,
    input                       rst,
    input                       trig,//input pluse, active high
    output                      busy,//output level, active high
    output  reg                 finish,//output pluse, active high

    input       signed  [15:0]  IU,//pu, range(-1,1), Base Ibase, 16bit Q15 signed ,additional range : IU+Iv (-1,1)
    input       signed  [15:0]  IV,//pu, range(-1,1), Base Ibase, 16bit Q15 signed ,additional range : IU+Iv (-1,1)
    output  reg signed  [15:0]  IALPHA,//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed 
    output  reg signed  [15:0]  IBETA//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed
    );

    wire    signed  [15:0]  IU_half;
    wire    signed  [31:0]  Result1;
    
    assign IU_half = {IU[15],IU[15:1]};
    
HW_MULT_S1616 MultS1(         
    .MultA(IU),//16bit Q15 signed
    .MultB(16'h6EDA),//sqrt(3)/2 16bit Q15 signed
    .Result(Result1)//32bit Q30signed
    );
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            IALPHA <= 16'd0;
        else begin
            if(trig == 1'b1)
                IALPHA<=Result1[30:15];
        end
            
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            IBETA <= 16'd0;
        else begin
            if(trig == 1'b1)
                IBETA<=IU_half + IV;
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            finish <= 1'b0;
        else begin
            if(trig == 1'b1)
                finish<=1'b1;
            else
                finish<=1'b0;
        end
    end    
    
    assign busy = trig;

endmodule
