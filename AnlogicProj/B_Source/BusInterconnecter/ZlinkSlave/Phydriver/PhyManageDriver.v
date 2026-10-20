module PhyManageDriver(
    input               clk,//input clk 100Mhz
    input               rst,//input rst,low active
    input               trig,
    output              finished,//process finish pluse,1clk(100Mhz)
    output  reg         DataValid,

    input       [1:0]   RWcode,
    input       [4:0]   PhyAddress,
    input       [4:0]   RegAddress,

    input       [15:0]  WR_RegData,
    output  reg [15:0]  RD_RegData,

    output              MDC,//1Mhz clk, normal high
    inout               MDIO
    );

    wire    [7:0]   ActivePluseCNT;
    wire            ActivePluse;
PhyManageMDC U0(
    .clk(clk),//input clk 100Mhz
    .rst(rst),//input rst,low active
    .trig(trig),
    .finished(finished),//process finish pluse,1clk(100Mhz)

    .ActivePluseCNT(ActivePluseCNT),
    .ActivePluse(ActivePluse),

    .MDC(MDC)//1Mhz clk, normal high
    );


    reg             TriStateCtrl;
    reg             MDO;
    wire            MDI;
    assign MDIO = (TriStateCtrl==1'b1)? MDO : 1'bz;
    assign MDI = MDIO;

    wire    [31:0]  DataDeal;
    assign DataDeal = {2'b01,RWcode,PhyAddress,RegAddress,2'b10,WR_RegData};
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            MDO<=1'b1;
        else begin
            if(ActivePluse)begin
                if(ActivePluseCNT<=8'd31)
                    MDO<=1'b1;
                else if(ActivePluseCNT<=8'd63)
                        MDO<=DataDeal[8'd63-ActivePluseCNT];
                    else
                        MDO<=1'b1;
            end
        end
    end

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            TriStateCtrl<=1'b0;
        else begin
            if(ActivePluse==1'b1)begin
                case(ActivePluseCNT)
                    8'd0:TriStateCtrl<=1'b1;
                    8'd46:begin
                        if(RWcode==2'b01)//write(01)
                            TriStateCtrl<=1'b1;
                        else//read(10)
                            TriStateCtrl<=1'b0;
                    end
                    8'd64:TriStateCtrl<=1'b0;
                endcase
            end
        end
    end


    always @ (posedge clk or negedge rst)begin
        if(!rst)
            RD_RegData<=16'd0;
        else begin
            if((RWcode==2'b10)&&(ActivePluse==1'b1))begin//Read
                if((ActivePluseCNT>=8'd48)&&(ActivePluseCNT<=8'd63))
                    RD_RegData[8'd63-ActivePluseCNT]<=MDI;
            end
        end
    end

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            DataValid<=1'b0;
        else begin
            if((ActivePluse==1'b1)&&(ActivePluseCNT==8'd48))
                DataValid<=!MDI;
        end
    end


endmodule

