/*
SinCosCal SinCosCal_inst(
    .clk(),
    .rst(),
    .trig(),
    .busy(),
    .finish(),

    .ThetaIn(),
    .SINval(),
    .COSval()
    );

    Trig(include) to finish(include): 16 clk
*/
module SinCosCal(
    input                       clk,
    input                       rst,
    input                       trig,
    output                      busy,
    output  reg                 finish,
    
    input               [15:0]  ThetaIn,//16bit,Q16,unsigned, pu Base = 360degree 
    output  reg signed  [15:0]  SINval,//16bit,Q15,signed, pu Base =1 
    output  reg signed  [15:0]  COSval//16bit,Q15,signed, pu Base =1 
    );  
    
    reg signed     [15:0]   Theta;
    reg            [1:0]    quadrant;
    
    reg signed     [15:0]   A;
    reg signed     [15:0]   x_2n,y_2n;
    reg signed     [15:0]   xPyn,xMyn;
    reg signed     [15:0]   yPxn,yMxn;
    reg signed     [15:0]   zPa,zMa;
    
    reg            [7:0]    calcnt;
    reg signed     [15:0]   xl,yl;
    reg signed     [15:0]   zl;
    reg signed     [15:0]   xn,yn;
    reg signed     [15:0]   zn;
    
    reg                     state;
    
    always @(posedge clk or negedge rst)begin
        if(!rst) quadrant<=2'b00;
        else begin
            if(state==1)begin
                if(calcnt==8'd0)begin
                        if(ThetaIn<16'h4000)          quadrant<=2'b00;
                        else if(ThetaIn<16'h8000)     quadrant<=2'b01;
                        else if(ThetaIn<16'hC000)     quadrant<=2'b10;
                        else                           quadrant<=2'b11;
                end    
                else 
                    quadrant<=quadrant;
            end
        end
    end        
    
    always @ (ThetaIn)begin
        if(ThetaIn<16'h4000)          Theta=ThetaIn;
        else if(ThetaIn<16'h8000)     Theta=ThetaIn-16'h4000;
        else if(ThetaIn<16'hC000)     Theta=ThetaIn-16'h8000;
        else                          Theta=ThetaIn-16'hC000;
    end

        
    
    parameter       ARCTAN_1_2_0=16'h2000,
                    ARCTAN_1_2_1=16'h12E4,
                    ARCTAN_1_2_2=16'h09FC,
                    ARCTAN_1_2_3=16'h0511,
                    ARCTAN_1_2_4=16'h028B,
                    ARCTAN_1_2_5=16'h0146,
                    ARCTAN_1_2_6=16'h00A3,
                    ARCTAN_1_2_7=16'h0051,
                    ARCTAN_1_2_8=16'h0029,
                    ARCTAN_1_2_9=16'h0014,
                    ARCTAN_1_2_10=16'h000A,
                    ARCTAN_1_2_11=16'h0005,
                    ARCTAN_1_2_12=16'h0003,
                    ARCTAN_1_2_13=16'h0001,
                    ARCTAN_1_2_14=16'h0000;
                    
    parameter       K = 16'h4db9;
                    
    always @ (calcnt)begin
        case(calcnt)
            8'd0 : A=16'h0000;
            8'd1 : A=ARCTAN_1_2_0;
            8'd2 : A=ARCTAN_1_2_1;
            8'd3 : A=ARCTAN_1_2_2;
            8'd4 : A=ARCTAN_1_2_3;
            8'd5 : A=ARCTAN_1_2_4;
            8'd6 : A=ARCTAN_1_2_5;
            8'd7 : A=ARCTAN_1_2_6;
            8'd8 : A=ARCTAN_1_2_7;
            8'd9 : A=ARCTAN_1_2_8;
            8'd10 : A=ARCTAN_1_2_9;
            8'd11 : A=ARCTAN_1_2_10;
            8'd12 : A=ARCTAN_1_2_11;
            8'd13 : A=ARCTAN_1_2_12;
            8'd14 : A=ARCTAN_1_2_13;
            8'd15 : A=ARCTAN_1_2_14;
            default : A=16'h0000;
        endcase
    end
    
    
    ///////////////////////////////////
    
    always @ (calcnt,xl)begin
        case(calcnt)
            8'd1 : x_2n=xl;
            8'd2 : x_2n=xl>>>1;
            8'd3 : x_2n=xl>>>2;
            8'd4 : x_2n=xl>>>3;
            8'd5 : x_2n=xl>>>4;
            8'd6 : x_2n=xl>>>5;
            8'd7 : x_2n=xl>>>6;
            8'd8 : x_2n=xl>>>7;
            8'd9 : x_2n=xl>>>8;
            8'd10 : x_2n=xl>>>9;
            8'd11 : x_2n=xl>>>10;
            8'd12 : x_2n=xl>>>11;
            8'd13 : x_2n=xl>>>12;
            8'd14 : x_2n=xl>>>13;
            8'd15 : x_2n=xl>>>14;
            default:x_2n=0;
        endcase
    end
    
    always @ (calcnt,yl)begin
        case(calcnt)
            8'd1 : y_2n=yl;
            8'd2 : y_2n=yl>>>1;
            8'd3 : y_2n=yl>>>2;
            8'd4 : y_2n=yl>>>3;
            8'd5 : y_2n=yl>>>4;
            8'd6 : y_2n=yl>>>5;
            8'd7 : y_2n=yl>>>6;
            8'd8 : y_2n=yl>>>7;
            8'd9 : y_2n=yl>>>8;
            8'd10 : y_2n=yl>>>9;
            8'd11 : y_2n=yl>>>10;
            8'd12 : y_2n=yl>>>11;
            8'd13 : y_2n=yl>>>12;
            8'd14 : y_2n=yl>>>13;
            8'd15 : y_2n=yl>>>14;
            default:y_2n=0;
        endcase
    end
                    
    
    always @ (xl,y_2n)begin
        xPyn=xl+y_2n;
    end
    always @ (xl,y_2n)begin
        xMyn=xl-y_2n;
    end
    
    
    
    always @ (yl,x_2n)begin
        yPxn=yl+x_2n;
    end
    always @ (yl,x_2n)begin
        yMxn=yl-x_2n;
    end
    

    always @ (zl,A)begin
        zPa=zl+A;
    end
    always @ (zl,A)begin
        zMa=zl-A;
    end
    
    
    always @(posedge clk or negedge rst)begin
        if(!rst) state <= 1'b0;    
        else begin
            if(trig==1'b1) state<=1'b1;
            else begin
                if(calcnt<8'd15) state<=state;
                else state<=1'b0;
            end
        end
    end
    
    assign busy = state||trig;
    
    always @(posedge clk or negedge rst)begin
        if(!rst) finish <= 1'b0;    
        else begin
            finish <= (calcnt==8'd15);
        end
    end
    
    always @(posedge clk or negedge rst)begin
        if(!rst) calcnt <= 8'd0;    
        else begin
            if(state==1)begin
                if(calcnt<8'd15) calcnt<=calcnt+8'd1;
                else calcnt<=8'd0;
            end
            else calcnt <= 8'd0;
        end
    end
    

    always @(posedge clk or negedge rst)begin
        if(!rst) xl <= 16'h0000;    
        else begin
            if(state==1)begin
                if(calcnt==8'd0) xl <= K;    
                else xl<=xn;
            end
        end
    end
    
    always @(posedge clk or negedge rst)begin
        if(!rst) yl <= 16'h0000;    
        else begin
            if(state==1)begin
                if(calcnt==8'd0) yl <= 16'h0000;    
                else yl<=yn;
            end
        end
    end

    always @(posedge clk or negedge rst)begin
        if(!rst) zl <= 16'h0000;    
        else begin
            if(state==1)begin
                if(calcnt==8'd0) zl <= Theta;    
                else zl<=zn;
            end
        end
    end
    
    ///////////////////////////////////
    always @ (xPyn,xMyn,zl[15])begin
        if(zl[15]==1'b1) xn=xPyn;
        else xn=xMyn;
    end
    
    always @ (yPxn,yMxn,zl[15])begin
        if(zl[15]==1'b1) yn=yMxn;
        else yn=yPxn;
    end
    
    always @ (zPa,zMa,zl[15])begin
        if(zl[15]==1'b1) zn=zPa;
        else zn=zMa;
    end
    
    
    
    ///////////////////////////////////
    always @(posedge clk or negedge rst)begin
        if(!rst) SINval <= 16'h0000;    
        else begin
            if(calcnt==8'd15)begin
                case(quadrant)
                    2'b00 : SINval<=yn;
                    2'b01 : SINval<=xn;
                    2'b10 : SINval<=-yn;
                    2'b11 : SINval<=-xn;
                    default:SINval<=yn;
                endcase
            end
        end
    end
    
    always @(posedge clk or negedge rst)begin
        if(!rst) COSval <= 16'h0000;    
        else begin
            if(calcnt==8'd15)begin
                case(quadrant)
                    2'b00 : COSval<=xn;
                    2'b01 : COSval<=-yn;
                    2'b10 : COSval<=-xn;
                    2'b11 : COSval<=yn;
                    default:COSval<=xn;
                endcase
            end
        end
    end    
    
    
endmodule
