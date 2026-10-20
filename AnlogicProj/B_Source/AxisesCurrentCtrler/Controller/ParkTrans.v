/*
ParkTrans ParkTrans_inst(
    .clk(),
    .rst(),
    .trig(),
    .busy(),
    .finish(),
    
    .IALPHA(),
    .IBETA(),
    .SINval(),
    .COSval(),

    .ID(),
    .IQ()
    );
    
    Trig(include) to finish(include): 3clk
*/
module ParkTrans(
    input                       clk,
    input                       rst,
    input                       trig,//input pluse, active high
    output                      busy,//output level, active high
    output  reg                 finish,//output pluse, active high
    
    input       signed  [15:0]  IALPHA,//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed 
    input       signed  [15:0]  IBETA,//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed
    input       signed  [15:0]  SINval,//pu, range(-1,1), Base 1, 16bit Q15 signed
    input       signed  [15:0]  COSval,//pu, range(-1,1), Base 1, 16bit Q15 signed

    output  reg signed  [15:0]  ID,//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed
    output  reg signed  [15:0]  IQ//pu, range(-1,1), Base (Ibase*2sqrt(3)/3), 16bit Q15 signed
    );

    reg                     Switch;

    wire    signed  [15:0]  MultA1;
    wire    signed  [31:0]  Result1;
    wire    signed  [15:0]  Result1_c;

    wire    signed  [15:0]  MultA2;
    wire    signed  [31:0]  Result2;
    wire    signed  [15:0]  Result2_c;
    
    reg                     busy_pre;

    assign MultA1 = (Switch==1'b0)?COSval:SINval;
    assign MultA2 = (Switch==1'b0)?SINval:COSval;

HW_MULT_S1616 MultS1(         
    .MultA(MultA1),
    .MultB(IALPHA),
    .Result(Result1)//32bit Q30
    );

HW_MULT_S1616 MultS2(         
    .MultA(MultA2),
    .MultB(IBETA),
    .Result(Result2)//32bit Q30
    );
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            Switch <= 1'b0;
        else begin
            if(trig == 1'b1)
                Switch<=1'b1;
            else
                Switch <= 1'b0;
        end
    end
    
    assign Result1_c = Result1[30:15];
    assign Result2_c = Result2[30:15];
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            ID <= 16'd0;
        else begin
            if(trig == 1'b1)
                ID<=Result1_c+Result2_c;
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            IQ <= 16'd0;
        else begin
            if(Switch == 1'b1)
                IQ<=Result2_c-Result1_c;
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            finish <= 1'b0;
        else begin
            if(Switch == 1'b1)
                finish<=1'b1;
            else
                finish<=1'b0;
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            busy_pre <= 1'b0;
        else begin
            if(trig == 1'b1)
                busy_pre <= 1'b1;
            else if(finish==1'b1)
                busy_pre<=1'b0;
            else
                busy_pre<=busy_pre;
        end
    end
    
    assign busy = busy_pre || trig;

endmodule
