/* 
SvpwmModulate SvpwmModulate_inst(    
    .clk(),
    .rst(),
    .trig(),
    .busy(),
    .finish(),
    .PreiodCNT(),
    .VoltageCircleLimit(),
    .Ualpha(),
    .Ubeta(),
    .DutyA(),
    .DutyB(),
    .DutyC()
    ); 
*/
module SvpwmModulate(    
    input                       clk,
    input                       rst,
    input                       trig,//input pluse, active high
    output                      busy,//output level, active high
    output  reg                 finish,//output pluse, active high
    //localparam Input/Output
    input               [15:0]  PreiodCNT,//half counter period(Carrier, up & down count)
    output      signed  [15:0]  VoltageCircleLimit,//Voltage circle limiting radius, pu, base 2/3*Udc(rated voltage), 16bit Q15
    //standard input/output
    input       signed  [15:0]  Ualpha,//Ualpha, pu, base 2/3*Udc(rated voltage), 16bit Q15
    input       signed  [15:0]  Ubeta,//Ualpha, pu, base 2/3*Udc(rated voltage), 16bit Q15
    output  reg         [15:0]  DutyA,//=PhaseA Duty cycle*PreiodCNT
    output  reg         [15:0]  DutyB,//=PhaseB Duty cycle*PreiodCNT
    output  reg         [15:0]  DutyC//=PhaseC Duty cycle*PreiodCNT
    );
    
    //Used to inform external input-module to limit Ualpha and Ubeta to the Voltage circle.
    assign     VoltageCircleLimit = 16'h6ED9;//sqrt(3)/3*Udc,pu, base 2/3*Udc(rated voltage), 16bit Q15

    localparam  CalStepCNT_NoincludeOvermodulation = 8'd10;
    reg             [7:0]   CalStep;
    reg     signed  [15:0]  MultA;
    reg     signed  [15:0]  MultB;
    wire    signed  [31:0]  Result;
    
    wire    signed  [15:0]  Ubeta_half;
    wire    signed  [15:0]  Ualpha_sqrt3_half;
    reg     signed  [15:0]  Vref1;
    reg     signed  [15:0]  Vref2;
    reg     signed  [15:0]  Vref3;
    
    reg             [2:0]   N;
    reg             [2:0]   Sector;
    
    reg     signed  [16:0]  x;//17bit Q15
    reg     signed  [16:0]  y;//17bit Q15
    reg     signed  [16:0]  z;//17bit Q15
    
    reg     signed  [16:0]  T1_pre;//17bit Q15, (T1_pre+T2_pre) maybe greater than 1
    reg     signed  [16:0]  T2_pre;//17bit Q15 (T1_pre+T2_pre) maybe greater than 1
    
    wire    signed  [16:0]  T1pT2_pre;//17bit Q15, T1_pre+T2_pre
    reg                     overmodulationFlag;
    
    reg     signed  [16:0]  T1;//17bit Q15, (T1+T2) less than 1
    reg     signed  [16:0]  T2;//17bit Q15, (T1+T2) less than 1
    wire    signed  [16:0]  T1T2_1left;//17bit Q15, 1-T1-T2, less than 1
    wire    signed  [16:0]  T1T2_1left_half;//17bit Q15,
    
    reg     signed  [16:0]  ta;
    reg     signed  [16:0]  tb;
    reg     signed  [16:0]  tc;
    
    reg             [15:0]  cmp1;
    reg             [15:0]  cmp2;
    reg             [15:0]  cmp3;
    
HW_MULT_S1616 HW_MULT_S1616_inst(
    .MultA(MultA),
    .MultB(MultB),
    .Result(Result)
    );
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            CalStep<=8'd0;
        else begin
            if(CalStep==8'd0)begin
                if(trig==1'b1)
                    CalStep<=8'd1;
            end
            else begin
                if(CalStep<=8'd5)
                    CalStep<=CalStep+1'b1;
                else if(CalStep==8'd6)begin
                    if(overmodulationFlag==1'b0)
                        CalStep<=CalStep+1'b1;
                    else begin//need add overmodulation finish-deal flag!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                        CalStep<=CalStep+1'b1;//temp deal!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    end
                end
                else if(CalStep<CalStepCNT_NoincludeOvermodulation)
                    CalStep<=CalStep+1'b1;
                else
                    CalStep<=8'd0;
            end
        end
    end
    
    always @ (*)begin
        case(CalStep)
        8'd0:begin
            MultA<=Ualpha;
            MultB<=16'h6ED9;//sqrt(3)/2, 16bit Q15
        end
        8'd1:begin
            MultA<=Vref1;
            MultB<=16'h49E6;//2*sqrt(3)/3, 16bit Q14
        end
        8'd2:begin
            MultA<=Vref2;
            MultB<=16'h49E6;//2*sqrt(3)/3, 16bit Q14
        end
        8'd3:begin
            MultA<=Vref3;
            MultB<=16'h49E6;//2*sqrt(3)/3, 16bit Q14
        end
        
        8'd8:begin
            MultA<=cmp1;
            MultB<=PreiodCNT;//16bit Q0
        end  
        8'd9:begin
            MultA<=cmp2;//16bit Q15
            MultB<=PreiodCNT;//16bit Q0
        end  
        8'd10:begin
            MultA<=cmp3;//16bit Q15
            MultB<=PreiodCNT;//16bit Q0
        end          
        default:begin
            MultA<=16'd0;
            MultB<=16'd0;
        end
        endcase
    end
    
    assign Ubeta_half = {Ubeta[15],Ubeta[15:1]};
    assign Ualpha_sqrt3_half = Result[30:15];
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Vref1<=16'd0;
            Vref2<=16'd0;
            Vref3<=16'd0;
        end
        else begin
            if(CalStep==8'd0)begin
                Vref1<=Ubeta;
                Vref2<=Ubeta_half+Ualpha_sqrt3_half;
                Vref3<=Ubeta_half-Ualpha_sqrt3_half;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            N<=3'd0;
        end
        else begin
            if(CalStep==8'd1)begin
                N<={Vref2[15],Vref3[15],~Vref1[15]};
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            x<=17'd0;
            y<=17'd0;
            z<=17'd0;
        end
        else begin
            if(CalStep==8'd1)begin
                x<=Result[30:14];
            end
            if(CalStep==8'd2)begin
                y<=Result[30:14];
            end
            if(CalStep==8'd3)begin
                z<=Result[30:14];
            end            
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            T1_pre<=17'd0;
            T2_pre<=17'd0;
            Sector<=3'd0;    
        end
        else begin
            if(CalStep==8'd4)begin
                case(N)
                3'd1:begin
                    T1_pre<=z;
                    T2_pre<=y;
                    Sector<=3'd1;
                end            
                3'd2:begin
                    T1_pre<=y;
                    T2_pre<=-x;
                    Sector<=3'd5;                
                end            
                3'd3:begin
                    T1_pre<=-z;
                    T2_pre<=x;
                    Sector<=3'd0;                
                end            
                3'd4:begin
                    T1_pre<=-x;
                    T2_pre<=z;
                    Sector<=3'd3;                
                end            
                3'd5:begin
                    T1_pre<=x;
                    T2_pre<=-y;
                    Sector<=3'd2;                
                end            
                3'd6:begin
                    T1_pre<=-y;
                    T2_pre<=-z;
                    Sector<=3'd4;                
                end            
                default:begin
                    T1_pre<=17'd0;
                    T2_pre<=17'd0;
                    Sector<=3'd0;                    
                end            
                endcase    
            end
        end
    end
    
    assign T1pT2_pre = T1_pre + T2_pre;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            overmodulationFlag<=1'b0;
        end
        else begin
            if(CalStep==8'd5)begin
                if(T1pT2_pre>=$signed(17'h07fff))//T1+T2>1(Q15)
                    overmodulationFlag<=1'b1;
                else
                    overmodulationFlag<=1'b0;
            end
        end
    end
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            T1<=17'd0;
            T2<=17'd0;
        end
        else begin
            if(CalStep==8'd6)begin
                if(overmodulationFlag==1'b0)begin
                    T1<=T1_pre;
                    T2<=T2_pre;
                end
                else begin//need add overmodulation finish-deal result!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    T1<=T1_pre;//temp deal!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    T2<=T2_pre;//temp deal!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                end
            end
        end
    end
    
    
    //according to T1 and T2 , cal duty clcye of each phase
    assign T1T2_1left = $signed(17'h07fff) - T1 -T2;//1-T1-T2
    assign T1T2_1left_half = {2'd0,T1T2_1left[15:1]};
    always @ (*)begin
        ta<=T1T2_1left_half;
        tb<=T1T2_1left_half+T1;
        tc<=T1T2_1left_half+T1+T2;
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            cmp1<=16'd0;
            cmp2<=16'd0;
            cmp3<=16'd0;
        end
        else begin
            if(CalStep==8'd7)begin
                case(Sector)
                3'd0:begin
                    cmp1=ta[15:0];
                    cmp2=tb[15:0];
                    cmp3=tc[15:0];
                end
                3'd1:begin
                    cmp1=tb[15:0];
                    cmp2=ta[15:0];
                    cmp3=tc[15:0];
                end
                3'd2:begin
                    cmp1=tc[15:0];
                    cmp2=ta[15:0];
                    cmp3=tb[15:0];
                end
                3'd3:begin
                    cmp1=tc[15:0];
                    cmp2=tb[15:0];
                    cmp3=ta[15:0];
                end
                3'd4:begin
                    cmp1=tb[15:0];
                    cmp2=tc[15:0];
                    cmp3=ta[15:0];
                end
                3'd5:begin
                    cmp1=ta[15:0];
                    cmp2=tc[15:0];
                    cmp3=tb[15:0];
                end
                default:begin
                    cmp1=0;
                    cmp2=0;
                    cmp3=0;
                end
                endcase
            end
        end
    end  


    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DutyA<=16'd0;
            DutyB<=16'd0;
            DutyC<=16'd0;
        end
        else begin
            if(CalStep==8'd8)begin
                DutyA<=PreiodCNT-Result[30:15];
            end
            if(CalStep==8'd9)begin
                DutyB<=PreiodCNT-Result[30:15];
            end
            if(CalStep==8'd10)begin
                DutyC<=PreiodCNT-Result[30:15];
            end            
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            finish<=1'b0;
        end
        else begin
            finish<=(CalStep==CalStepCNT_NoincludeOvermodulation); 
        end
    end
    //assign finish = (CalStep==CalStepCNT_NoincludeOvermodulation);
    assign busy = (CalStep!=8'd0)||trig;
    
endmodule