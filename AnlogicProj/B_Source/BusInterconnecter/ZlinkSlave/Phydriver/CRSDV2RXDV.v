module CRSDV2RXDV(
    input               clk,//input clk 50Mhz
    input               rst,//input rst,low active

    input               RMII_RXDVorCRSDV_pre,
    input       [1:0]   RMII_RXD_pre,

    output              RMII_RXDV,
    output      [1:0]   RMII_RXD 
    );

    wire    [2:0]   RX;
    reg     [2:0]   RX_dly1;
    reg     [2:0]   RX_dly2;

    assign RX = {RMII_RXDVorCRSDV_pre,RMII_RXD_pre};
    always@(posedge clk or negedge rst)begin
        if(~rst) begin
            RX_dly1<=3'b000;
            RX_dly2<=3'b000;
        end
        else begin
            RX_dly1<=RX;
            RX_dly2<=RX_dly1;
        end
    end

    reg             Datavalid;
    always@(posedge clk or negedge rst)begin
        if(~rst) begin
            Datavalid<=1'b0;
        end
        else begin
            if((RX==3'b101)&&(RX_dly1==3'b101))
                Datavalid<=1'b1;
            else if((RX[2]==1'b0)&&(RX_dly1[2]==1'b0))
                    Datavalid<=1'b0;
        end
    end

    assign RMII_RXDV = Datavalid;
    assign RMII_RXD = RX_dly2[1:0];


endmodule
