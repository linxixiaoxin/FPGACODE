/*
Sqrt32 Sqrt32_inst(
    .clk(),
    .rst(),
    .trig(),
    .busy(),
    .finish(),
    .DataIn(),
    .Result()
    );
*/
module Sqrt32(
    input                   clk,
    input                   rst,
    input                   trig,
    output                  busy,
    output  reg             finish,
    input           [31:0]  DataIn,
    output  reg     [15:0]  Result
);

/* wire    calcend;
reg     calcend_dly;
reg     calcen;
wire    [15:0] Result0;
SQRT_efinity u_SQRT_efinity(
.reset_n ( rst ),
.sysclk ( clk ),
.din ( DataIn ),
.calcen ( calcen ),
.clken ( 1'b1 ),
.vout ( Result0 ),
.calcend ( calcend )
);

always @ (posedge clk or negedge rst)begin
    if(!rst)
        calcen<=1'b0;
    else begin
        if(trig)
            calcen<=1'b1;
        else begin
            if(calcend==1'b1)
                calcen<=1'b0;
        end
    end
end

always @ (posedge clk or negedge rst)begin
    if(!rst)
        calcend_dly<=1'b0;
    else begin
        calcend_dly<=calcend;
    end
end

always @ (*)
    finish = calcend && (!calcend_dly);
always @ (*)
    Result = Result0; */

    reg     [15:0]  MultIN; 
    wire    [31:0]  Square;
    wire            COMPFlag;
    assign COMPFlag = (Square<=DataIn)?1'b1:1'b0;
HW_MULT_S1616 mult0(
    .MultA(MultIN),
    .MultB(MultIN),
    .Result(Square)
    );
    
    reg     [5:0]   CalState;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CalState<=6'd0;
        end
        else begin
            case(CalState)
            6'd0:begin
                if(trig)
                    CalState<=6'd1;
                else
                    CalState<=6'd0;
            end
            default:begin
                if(CalState>=6'd17)
                    CalState<=6'd0;
                else
                    CalState<=CalState+6'd1;
            end
            endcase
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            MultIN<=16'd0;
        end
        else begin
            case(CalState)
            6'd0:MultIN<=16'b1000_0000_0000_0000;
            6'd1:MultIN[15:14]<={COMPFlag,1'b1};
            6'd2:MultIN[14:13]<={COMPFlag,1'b1};
            6'd3:MultIN[13:12]<={COMPFlag,1'b1};
            6'd4:MultIN[12:11]<={COMPFlag,1'b1};
            6'd5:MultIN[11:10]<={COMPFlag,1'b1};
            6'd6:MultIN[10:9]<={COMPFlag,1'b1};
            6'd7:MultIN[9:8]<={COMPFlag,1'b1};
            6'd8:MultIN[8:7]<={COMPFlag,1'b1};
            6'd9:MultIN[7:6]<={COMPFlag,1'b1};
            6'd10:MultIN[6:5]<={COMPFlag,1'b1};
            6'd11:MultIN[5:4]<={COMPFlag,1'b1};
            6'd12:MultIN[4:3]<={COMPFlag,1'b1};
            6'd13:MultIN[3:2]<={COMPFlag,1'b1};
            6'd14:MultIN[2:1]<={COMPFlag,1'b1};
            6'd15:MultIN[1:0]<={COMPFlag,1'b1};
            6'd16:MultIN[0]<=COMPFlag;
            default:MultIN<=MultIN;
            endcase
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Result<=16'd0;
            finish<=1'b0;
        end
        else begin
            if(CalState==6'd17)begin
                Result<=MultIN;
                finish<=1'b1;
            end
            else begin
                Result<=Result;
                finish<=1'b0;
            end
        end
    end
    
    assign busy = trig ||(CalState!=6'd0);

endmodule
