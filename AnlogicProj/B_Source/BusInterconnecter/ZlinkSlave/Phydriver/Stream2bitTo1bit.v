module Stream2bitTo1bit(
    input               RMII_REFCLK,
    input               RMII_RXDV_EXT,
    input       [1:0]   RMII_RXD_EXT,

    input               clk,
    input               rst,
    output  reg         RXDV,
    output              RXD
    );

    //====================RMII_REFCLK colck area===============================================
    reg [4:0]   WRADDR;
    reg [4:0]   WRADDR_hold;
    always @ (posedge RMII_REFCLK or negedge rst)begin
        if(!rst)begin
            WRADDR<=5'd0;
            WRADDR_hold<=5'd0;
        end
        else begin
            if(RMII_RXDV_EXT)
                WRADDR<=WRADDR+1'b1;
            else
                WRADDR<=5'd0;
            
            if(RMII_RXDV_EXT)
                WRADDR_hold<=WRADDR;
        end
    end
    
    
    //====================RMII_REFCLK - async - Local 100Mhz===========================================
    wire        RDDATA_H;
    wire        RDDATA_L;
    reg [5:0]   RDADDR;

SimpleDualPortRAM 
    #(
    .DATAWIDTH(1),
    .ADDRESSWIDTH(5),
    .DATANum(32)
    )
    SimpleDualPortRAM_H(
    .WRclk(RMII_REFCLK),
    .WRADDR(WRADDR),
    .WRDATA(RMII_RXD_EXT[1]),
    .WR(RMII_RXDV_EXT),
    .RDclk(clk),
    .RDADDR(RDADDR[5:1]),
    .RDDATA(RDDATA_H),
    .RD(1'b1)
    );
SimpleDualPortRAM 
    #(
    .DATAWIDTH(1),
    .ADDRESSWIDTH(5),
    .DATANum(32)
    )
    SimpleDualPortRAM_L(
    .WRclk(RMII_REFCLK),
    .WRADDR(WRADDR),
    .WRDATA(RMII_RXD_EXT[0]),
    .WR(RMII_RXDV_EXT),
    .RDclk(clk),
    .RDADDR(RDADDR[5:1]),
    .RDDATA(RDDATA_L),
    .RD(1'b1)
    );
    //==delay for buffer
    reg RMII_RXDV_EXT_atRMII_REFCLK_1;
    reg RMII_RXDV_EXT_atRMII_REFCLK_2;
    always @ (posedge RMII_REFCLK or negedge rst)begin//delay for buffer
        if(!rst)begin
            RMII_RXDV_EXT_atRMII_REFCLK_1<=1'b0;
            RMII_RXDV_EXT_atRMII_REFCLK_2<=1'b0;
        end
        else begin
            RMII_RXDV_EXT_atRMII_REFCLK_1<=RMII_RXDV_EXT;
            RMII_RXDV_EXT_atRMII_REFCLK_2<=RMII_RXDV_EXT_atRMII_REFCLK_1;
        end
    end
    
    //==data sync
    reg RMII_RXDV_EXT0_atclk_1;
    reg RMII_RXDV_EXT0_atclk_2;
    reg RMII_RXDV_EXT0_atclk_3;
    wire RMII_RXDV0_Redge;
    wire RMII_RXDV0_Fedge;
    
    reg RMII_RXDV_EXT2_atclk_1;
    reg RMII_RXDV_EXT2_atclk_2;
    reg RMII_RXDV_EXT2_atclk_3;
    wire RMII_RXDV2_Redge;
    wire RMII_RXDV2_Fedge;
    
    reg [4:0] ENDADDR;
    
    always @ (posedge clk or negedge rst)begin//async sample
        if(!rst)begin
            RMII_RXDV_EXT0_atclk_1<=1'b0;
            RMII_RXDV_EXT0_atclk_2<=1'b0;
            RMII_RXDV_EXT0_atclk_3<=1'b0;
        end
        else begin
            RMII_RXDV_EXT0_atclk_1<=RMII_RXDV_EXT;
            RMII_RXDV_EXT0_atclk_2<=RMII_RXDV_EXT0_atclk_1;
            RMII_RXDV_EXT0_atclk_3<=RMII_RXDV_EXT0_atclk_2;
        end
    end
    assign RMII_RXDV0_Redge = RMII_RXDV_EXT0_atclk_2 && !RMII_RXDV_EXT0_atclk_3;
    assign RMII_RXDV0_Fedge = !RMII_RXDV_EXT0_atclk_2 && RMII_RXDV_EXT0_atclk_3;
    
    always @ (posedge clk or negedge rst)begin//async sample
        if(!rst)begin
            RMII_RXDV_EXT2_atclk_1<=1'b0;
            RMII_RXDV_EXT2_atclk_2<=1'b0;
            RMII_RXDV_EXT2_atclk_3<=1'b0;
        end
        else begin
            RMII_RXDV_EXT2_atclk_1<=RMII_RXDV_EXT_atRMII_REFCLK_2;
            RMII_RXDV_EXT2_atclk_2<=RMII_RXDV_EXT2_atclk_1;
            RMII_RXDV_EXT2_atclk_3<=RMII_RXDV_EXT2_atclk_2;
        end
    end
    assign RMII_RXDV2_Redge = RMII_RXDV_EXT2_atclk_2 && !RMII_RXDV_EXT2_atclk_3;
    assign RMII_RXDV2_Fedge = !RMII_RXDV_EXT2_atclk_2 && RMII_RXDV_EXT2_atclk_3;
    

    always @ (posedge clk or negedge rst)begin//async sample by hankshake sig
        if(!rst)begin
            ENDADDR<=5'd0;
        end
        else begin
            if(RMII_RXDV0_Fedge)
                ENDADDR<=WRADDR_hold;
        end
    end
    
    
 //====================Local 100Mhz colck area===============================================
    reg JudgeArea;
    reg TransEN;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            JudgeArea<=1'b0;
        else begin
            if(RMII_RXDV0_Fedge)
                JudgeArea<=1'b1;
            else if(RMII_RXDV0_Redge)
                JudgeArea<=1'b0;
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            TransEN<=1'b0;
        else begin
            if(TransEN==1'b0)begin
                if(RMII_RXDV2_Redge)
                    TransEN<=1'b1;
            end
            else begin
                if(JudgeArea&&(RDADDR[5:1]==ENDADDR)&&(RDADDR[0]==1'b1))
                    TransEN<=1'b0;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RDADDR<=6'd0;
        end
        else begin
            if(TransEN)
                RDADDR<=RDADDR+1'b1;
            else
                RDADDR<=6'd0;
        end
    end
    
    reg BitSel;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RXDV<=1'b0;
            BitSel<=1'b0;
        end
        else begin
            RXDV<=TransEN;
            BitSel<=RDADDR[0];
        end
    end
    
    assign RXD = (BitSel==1'b0)?RDDATA_H:RDDATA_L;
    
endmodule
