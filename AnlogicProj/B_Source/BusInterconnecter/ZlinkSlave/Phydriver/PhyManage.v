module PhyManage(
    input               clk,//input clk 100Mhz
    input               rst,//input rst,low active
    input       [4:0]   PhyAddress,
    output  reg         Linkstate,
    output  reg [21:0]  PHY_ID,
    output              MDC,//1Mhz clk, normal high
    inout               MDIO
    );
    wire            trigMDC;
    wire            MDCFinish;
    reg     [1:0]   RWcode;
    reg     [4:0]   regaddress;
    reg     [15:0]  WR_RegData;
    wire    [15:0]  RD_RegData;
    wire            DataValid;

PhyManageDriver U0(
    .clk(clk),//input clk 50Mhz
    .rst(rst),//input rst,low active
    .trig(trigMDC),
    .finished(MDCFinish),//process finish pluse,1clk(50Mhz)
    .DataValid(DataValid),

    .RWcode(RWcode),//2'b10read 2'b01write
    .PhyAddress(PhyAddress),
    .RegAddress(regaddress),

    .WR_RegData(WR_RegData),
    .RD_RegData(RD_RegData),

    .MDC(MDC),//1Mhz clk, normal high
    .MDIO(MDIO)
    );

    //FMS========================================================================
    parameter   Idel            =   8'd0;
    parameter   RDID0           =   8'd1;
    parameter   RDID1           =   8'd2;
    parameter   PHYDetect       =   8'd3;

    parameter   PHYnormal_WRCtrlReg    =        8'd10;
    parameter   PHYnormal_RDLinkState        =            8'd11;
    parameter   PHYnormal_wait  =   8'd12;


    //parameter   PHY8201_WR1                 =  8'd20;
    //parameter   PHY8201_WR2                 =  8'd21;
    //parameter   PHY8201_RDLinkState         =  8'd28;
    //parameter   PHY8201_wait                =  8'd29;

    reg     [7:0]   StateCurrent;
    reg     [7:0]   StateNext;

    always @ (posedge clk or negedge rst)begin
        if(!rst)
            StateCurrent<=Idel;
        else
            StateCurrent<=StateNext;
    end

    always @ (*)begin
        case(StateCurrent)
            Idel:begin
                StateNext<=RDID0;
            end

            RDID0:begin
                if(MDCFinish)
                    StateNext<=RDID1;
                else
                    StateNext<=RDID0;
            end

            RDID1:begin
                if(MDCFinish)
                    StateNext<=PHYDetect;
                else
                    StateNext<=RDID1;
            end

            PHYDetect:begin
                case(PHY_ID)

                    default:StateNext<=PHYnormal_WRCtrlReg;
                endcase
            end

            PHYnormal_WRCtrlReg:begin
                if(MDCFinish)
                    StateNext<=PHYnormal_RDLinkState;
                else
                    StateNext<=PHYnormal_WRCtrlReg;
            end

            PHYnormal_RDLinkState:begin
                if(MDCFinish)
                    StateNext<=PHYnormal_wait;
                else
                    StateNext<=PHYnormal_RDLinkState;
            end

            PHYnormal_wait:begin
                if(MDCFinish)
                    StateNext<=PHYnormal_RDLinkState;
                else
                    StateNext<=PHYnormal_wait;
            end


            default:StateNext<=Idel;
        endcase

    end


    assign trigMDC = (StateCurrent!=StateNext);


    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RWcode<=2'b10;
            regaddress<=5'd0;
            WR_RegData<=16'd0;
        end
        else begin
            case(StateCurrent)
                RDID0:begin//RD reg2
                    RWcode<=2'b10;
                    regaddress<=5'd2;
                    WR_RegData<=16'd0;
                end
                RDID1:begin//RD reg3
                    RWcode<=2'b10;
                    regaddress<=5'd3;
                    WR_RegData<=16'd0;
                end

                PHYnormal_WRCtrlReg:begin//WR reg0
                    RWcode<=2'b01;
                    regaddress<=5'd0;
                    WR_RegData<=16'h3300;//en AutoNegotiation
                end

                PHYnormal_RDLinkState:begin//RD reg1
                    RWcode<=2'b10;
                    regaddress<=5'd1;
                    WR_RegData<=16'd0;
                end

                default:begin//RD reg 1;
                    RWcode<=2'b10;
                    regaddress<=5'd1;
                    WR_RegData<=16'd0;
                end 
            endcase
        end
    end

    //======================================Regs update
    //PHY_ID
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            PHY_ID<=15'd0;
        else begin
            if((MDCFinish)&&(StateCurrent==RDID0))
                PHY_ID[21:6]<=RD_RegData;
            else if((MDCFinish)&&(StateCurrent==RDID1))
                    PHY_ID[5:0]<=RD_RegData[15:10];
        end
    end

    //Linkstate
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            Linkstate<=1'b0;
        else begin
            if((MDCFinish)&&(StateCurrent==PHYnormal_RDLinkState))
                Linkstate<=RD_RegData[2] && DataValid;
        end
    end



endmodule

