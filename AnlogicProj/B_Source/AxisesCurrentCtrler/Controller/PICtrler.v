/*
PICtrler PICtrler_inst(    
    .clk(),
    .rst(),
    .trig(),
    .busy(),
    .finish(),
    .Kp(),
    .Ki(),
    .Compensate(),
    .Limit(),
    .reference(),
    .feedback(),
    .UiAcc(),
    .UiAcc_new(),
    .PIResult()
    );
*/
module PICtrler(    
    input                       clk,
    input                       rst,
    input                       trig,//input pluse, active high
    output                      busy,//output level, active high
    output  reg                 finish,//output pluse, active high

    input       signed  [31:0]  Kp,//32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [31:0]  Ki,//32bit,Q15, pu , base = Ubase/Ibase
    input       signed  [15:0]  Compensate,//16bit,Q15, pu , base = Ubase,(-1,1)
    input       signed  [15:0]  Limit,//16bit,Q15, pu , base = Ubase,(0,1)
    
    input       signed  [15:0]  reference,//16bit,Q15, pu , base = Ibase,(-1,1)
    input       signed  [15:0]  feedback,//16bit,Q15, pu , base = Ibase,(-1,1)
    input       signed  [31:0]  UiAcc,//32bit Q30, pu , base = Ubase,(-1,1)
    
    output  reg signed  [31:0]  UiAcc_new,//32bit Q30, pu , base = Ubase,(-1,1)
    output  reg signed  [15:0]  PIResult//16bit,Q15, pu , base = Ubase,(-1,1)
    );    
    wire    signed  [31:0]  Limit32bit;
    assign Limit32bit = {Limit[15],Limit,15'h0000};
    wire    signed  [16:0]  reference_in;
    wire    signed  [16:0]  feedback_in;
    wire    signed  [16:0]  Err_pre;
    reg     signed  [16:0]  Err;
    assign reference_in = {reference[15],reference};
    assign feedback_in = {feedback[15],feedback};
    assign Err_pre = reference_in - feedback_in;
    
    reg     signed  [31:0]  MultA;
    wire    signed  [48:0]  Result;
    reg     signed  [48:0]  Result_dly;
    
    reg             [7:0]   CalCNT;
    
    reg     signed  [31:0]  MultResult_Limited;//limit Mult result to 32bit Q30, (-1,1);
    
    reg     signed  [31:0]  up;//32bit Q30 (-1,1)
    reg     signed  [31:0]  ui;//32bit Q30 (-1,1)
    wire    signed  [31:0]  uiacc_pre0;
    reg     signed  [31:0]  uiacc_pre;
    
    
    wire    signed  [17:0]  up_18bit;//18bit Q15,(-1,1)
    wire    signed  [17:0]  UiAcc_new_18bit;//18bit Q15,(-1,1)
    wire    signed  [17:0]  Compensate_18bit;//18bit Q15,(-1,1)
    
    wire    signed  [17:0]  PIResult_pre;
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Err<=17'd0;
        end
        else begin
            if(CalCNT==8'd0)
                Err<=Err_pre;
        end
    end   
    
HW_MULT_S3217 HW_MULT_S3217_inst(
    .MultA(MultA),
    .MultB(Err),
    .Result(Result)
    );
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Result_dly<=48'd0;
        end
        else begin
            Result_dly<=Result;
        end
    end 
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CalCNT<=8'd0;
        end
        else begin
            if(CalCNT==8'd0)begin
                if(trig==1'b1)
                    CalCNT<=8'd1;
            end
            else begin
                if(CalCNT<8'd6)
                    CalCNT<=CalCNT+1'b1;
                else
                    CalCNT<=8'd0;
            end
        end
    end
    
/*     always @ (Result_dly)begin//limit Mult result to 32bit Q30, (-1,1);
        if(Result_dly[48]==1'b0)begin//positive
            if(Result_dly[47:40]==8'h00)//
                MultResult_Limited<=Result_dly[41:10];//normal data
            else
                MultResult_Limited<=32'h3fffffff;//positive overflow
        end
        else begin//negative
            if(Result_dly[47:40]==8'hff)
                MultResult_Limited<=Result_dly[41:10];//normal data
            else
                MultResult_Limited<=32'hc0000000;//negative overflow			
        end
    end */
    always @ (Result_dly)begin//limit Mult result to 32bit Q30, (-1,1);
        if(Result_dly[48]==1'b0)begin//positive
            if(Result_dly[47:30]==18'h00000)//
                MultResult_Limited<=Result_dly[31:0];//normal data
            else
                MultResult_Limited<=32'h3fffffff;//positive overflow
        end
        else begin//negative
            if(Result_dly[47:30]==18'h3ffff)
                MultResult_Limited<=Result_dly[31:0];//normal data
            else
                MultResult_Limited<=32'hc0000000;//negative overflow			
        end
    end

    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            MultA<=32'd0;
        end
        else begin
            case(CalCNT)
            8'd0:MultA<=Kp;
            8'd1:MultA<=Ki;
            default:MultA<=32'd0;
            endcase
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            up<=32'd0;
            ui<=32'd0;
        end
        else begin
            if(CalCNT==8'd2)
                up<=MultResult_Limited;//32bit Q30, (-1,1);
                
            if(CalCNT==8'd3)
                ui<=MultResult_Limited;//32bit Q30, (-1,1);
        end
    end
    
    assign uiacc_pre0 = ui + UiAcc;
    
	always @ (posedge clk or negedge rst)begin
		if(!rst) 
			uiacc_pre<=32'd0;
		else begin
			if(CalCNT==8'd4)begin
                uiacc_pre<=uiacc_pre0;
			end
		end
	end
    
	always @ (posedge clk or negedge rst)begin
		if(!rst) 
			UiAcc_new<=32'd0;
		else begin
			if(CalCNT==8'd5)begin
                if(uiacc_pre[31]==1'b0)begin//positive
                    if(uiacc_pre[30]==1'b0)begin//normal data
                        if(uiacc_pre>Limit32bit)
                            UiAcc_new<=Limit32bit;
                        else
                            UiAcc_new<=uiacc_pre;
                    end
                    else//positive overflow
                        UiAcc_new<=Limit32bit;
                end
                else begin//negative
                    if(uiacc_pre[30]==1'b1)begin//normal data
                        if(uiacc_pre<(-Limit32bit))
                            UiAcc_new<=(-Limit32bit);
                        else
                            UiAcc_new<=uiacc_pre;
                    end
                    else//negative overflow
                        UiAcc_new<=(-Limit32bit);
                end
			end
		end
	end
    
    assign up_18bit = {up[30],up[30],up[30:15]};//18bit Q15,(-1,1)
    assign UiAcc_new_18bit = {UiAcc_new[30],UiAcc_new[30],UiAcc_new[30:15]};//18bit Q15,(-1,1)
    assign Compensate_18bit = {Compensate[15],Compensate[15],Compensate};//18bit Q15,(-1,1)
    
    assign PIResult_pre = up_18bit + UiAcc_new_18bit + Compensate_18bit;
    
	always @ (posedge clk or negedge rst)begin
		if(!rst) 
			PIResult<=16'd0;
		else begin
			if(CalCNT==8'd6)begin
                if(PIResult_pre[17]==1'b0)begin//positive
                    if(PIResult_pre[16:15]==2'b00)begin//normal data
                        if(PIResult_pre>Limit)
                            PIResult<=Limit;
                        else
                            PIResult<=PIResult_pre[15:0];
                    end
                    else//positive overflow
                        PIResult<=Limit;
                end
                else begin//negative
                    if(PIResult_pre[16:15]==2'b11)begin//normal data
                        if(PIResult_pre<(-Limit))
                            PIResult<=(-Limit);
                        else
                            PIResult<=PIResult_pre[15:0];
                    end
                    else//negative overflow
                        PIResult<=(-Limit);
                end
			end
		end
	end

    
	always @ (posedge clk or negedge rst)begin
		if(!rst) 
			finish<=1'b0;
		else begin
			if(CalCNT==8'd6)
                finish<=1'b1;
            else
                finish<=1'b0;
		end
	end
    
    assign busy = trig||(CalCNT!=8'd0);
    
endmodule         

