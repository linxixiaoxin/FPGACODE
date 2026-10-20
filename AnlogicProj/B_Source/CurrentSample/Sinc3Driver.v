// Sinc3 Filter
// Analog Devices AD7401 Datasheet

/*`Data is read on negative clk edge*/
module Sinc3Driver (
    input                       clk20Mhz, 
    input                       clk100Mhz,
    input                       rst, 
    input                       mdata1, 
    input                       polarity,//define Driver to Motor is positive, value is 1;Motor to Driver is negetive, value is 0   
    input       signed  [15:0]  Offset,
    output  reg signed  [15:0]  DataOut
    );
wire    signed  [16:0]  DataOutpre0;
wire    signed  [16:0]  DataOutpre1;

wire    signed  [16:0]  Offset_expand;
wire    signed  [16:0]  Dataotput_expand;
    
    
//integer location; 
//integer info_file;
wire         [24:0]         ip_data1;                           
reg          [24:0]         acc1;
reg          [24:0]         acc2;
reg          [24:0]         acc3;                          
reg                         DataValid;
reg                         sample_finish_oc;
////////////////ram ///////////////////////////////////
reg          [6:0]          count_ram;
reg          [24:0]         ram_acc3 ;
reg          [24:0]         ram_diff1;
reg          [24:0]         ram_diff2;
reg          [0:0]          wren     ;
reg          [6:0]          wraddress;
reg          [6:0]          rdaddress;
reg          [0:0]          rden     ;
reg          [24:0]         ram_diff3;
reg         [24:0]         ram_acc3_d2,ram_diff1_d2;
wire  [24:0]   ram_diff2_d2;
reg  [24:0]  WRDATAIN;
wire [24:0]  RDDATAOUT;
reg  [24:0]  acc3_Lock;


/*Perform the Sinc ACTION*/

assign ip_data1 = (mdata1==0)?25'd0:25'd1; /* change from a 0 to a -1 for 2's comp */


/*ACCUMULATOR (INTEGRATOR) Perform the accumulation (IIR) at the speed of the modulator.
Z = one sample delay MCLKIN = modulators conversion bit rate */

//always @ (negedge clk20Mhz or negedge rst)
always @ (posedge clk20Mhz or negedge rst)
begin
if (~rst)
	begin /*initialize acc registers on rst*/ 
		acc1 <= 0; 
		acc2 <= 0; 
		acc3 <= 0; 
	end 
else 
	begin /*perform accumulation process*/ 
		acc1 <= acc1 + ip_data1; 
		acc2 <= acc2 + acc1; 
		acc3 <= acc3 + acc2; 
	end
end

/*DECIMATION STAGE (MCLKIN/ WORD_CLK) */
//initialize the RAM content   //
/////////////////////////////////////////////////////
reg            initialize;
always @(posedge clk20Mhz or negedge rst)
 if(~rst)
    count_ram           <= 'd0;
 else if(initialize==1'b0)
    count_ram           <= count_ram + 1'b1; 
    
    

	
assign ram_diff2_d2 = RDDATAOUT;//after RD 3st,RDDATAOUT always ram_diff2_d2;
always @ (posedge clk20Mhz or negedge rst)  //for the overcurrent check use 2 order filter
begin
if(~rst) 
	begin 
     ram_acc3           <= 'd0;  
	 ram_diff1          <= 'd0;
	 ram_diff2          <= 'd0;
     wren               <= 1'b0;	 
	 wraddress          <= 'd0;
	 rdaddress          <= 'd0;
	 rden               <= 'd0;
	 ram_diff3          <= 'd0; 
	 DataValid      <= 1'b0;
	 initialize         <= 1'b1;
     
     WRDATAIN <=24'd0;
     acc3_Lock<=24'd0;
	end
else if(initialize)
    begin
     WRDATAIN <=24'd0;
	 wren               <= 1'b1;	 
	 wraddress          <= wraddress + 1'b1;
	 if(wraddress==7'h7f)
	  initialize         <= 1'b0;
	end
else if(count_ram[2:0]==3'd0)begin//RD1
	 rdaddress          <= {3'd0,count_ram[6:3]};
	 rden               <= 1'b1;
end
else if(count_ram[2:0]==3'd1)begin//RD2
	 rdaddress          <= {3'd0,count_ram[6:3]}+7'd32;
	 rden               <= 1'b1;
end
else if(count_ram[2:0]==3'd2)begin//RD3, lock ram_acc3_d2
	 rdaddress          <= {3'd0,count_ram[6:3]}+7'd64;
	 rden               <= 1'b1;
     
     ram_acc3_d2        <= RDDATAOUT;
end
else if(count_ram[2:0]==3'd3)begin//lock ram_diff1_d2, lock acc3
	 rdaddress          <= 7'd0;
	 rden               <= 1'b0;
     
     ram_diff1_d2       <= RDDATAOUT;
     acc3_Lock          <= acc3;
end
else if(count_ram[2:0]==3'd4)begin//ram_acc3_d2,ram_diff1_d2,ram_diff2_d2(RDDATAOUT),acc3_Lock all valid
    ram_acc3           <= acc3_Lock;  
    ram_diff1          <= acc3_Lock-ram_acc3_d2;
    ram_diff2          <= acc3_Lock-ram_acc3_d2-ram_diff1_d2;
    ram_diff3          <= acc3_Lock-ram_acc3_d2-ram_diff1_d2-ram_diff2_d2; 
    
    wren               <=  1'b1;
    wraddress          <= {3'd0,count_ram[6:3]};
    WRDATAIN           <= acc3_Lock;
end
else if(count_ram[2:0]==3'd5)begin
    wren               <=  1'b1;
    wraddress          <= {3'd0,count_ram[6:3]}+7'd32;
    WRDATAIN           <= ram_diff1;
end
else if(count_ram[2:0]==3'd6)begin
    wren               <=  1'b1;
    wraddress          <= {3'd0,count_ram[6:3]}+7'd64;
    WRDATAIN           <= ram_diff2;
    
    DataValid 	        <= 1'b1;
end
else if(count_ram[2:0]==3'd7)begin
    wren               <= 1'b0;
    wraddress          <= 7'd0;
    
    DataValid 	        <= 1'b0;
end
else begin
   rden                 <= 1'b0;
   wren                 <= 1'b0;
   DataValid        <= 1'b0;
end

end
  
SimpleDualPortRAM 
    #(
    .DATAWIDTH(25),
    .ADDRESSWIDTH(7),
    .DATANum(128)
    )
    SimpleDualPortRAM(
    .WRclk(clk20Mhz),
    .WRADDR(wraddress),
    .WRDATA(WRDATAIN),
    .WR(wren),
    .RDclk(clk20Mhz),
    .RDADDR(rdaddress),
    .RDDATA(RDDATAOUT),
    .RD(rden)
    );    
    
//==========Data sync===============================


reg     DataValid_sync0;
reg     DataValid_sync1;
reg     DataValid_sync2;
wire    DataValid_100Mz;
always @ (posedge clk100Mhz or negedge rst)begin
    if(!rst)begin
        DataValid_sync0<=1'b0;
        DataValid_sync1<=1'b0;
        DataValid_sync2<=1'b0;
    end
    else begin
        DataValid_sync0<=DataValid;
        DataValid_sync1<=DataValid_sync0;
        DataValid_sync2<=DataValid_sync1;
    end
end
assign DataValid_100Mz = (DataValid_sync1==1'b1)&&(DataValid_sync2==1'b0);

assign DataOutpre0 = ram_diff3[21:5]; 
assign DataOutpre1 = (polarity==1'b1)?(DataOutpre0 - $signed(17'd32768)):($signed(17'd32768)-DataOutpre0);
assign Offset_expand = {Offset[15],Offset};
assign Dataotput_expand = DataOutpre1 + Offset_expand;

    always @ (posedge clk100Mhz or negedge rst)begin
        if(!rst)begin
            DataOut<=16'd0;
        end
        else begin
            if(DataValid_100Mz==1'b1)begin
                case(Dataotput_expand[16:15])
                2'b10:begin
                    DataOut<=$signed(16'd32767);
                end
                2'b01:begin
                    DataOut<=$signed(-16'd32767);
                end
                default:begin
                    DataOut<=Dataotput_expand[15:0];
                end
                endcase
            end
        end
    end



 
    

    
endmodule
