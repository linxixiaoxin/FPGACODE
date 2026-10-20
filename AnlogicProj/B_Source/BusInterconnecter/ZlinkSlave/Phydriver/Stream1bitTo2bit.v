module Stream1bitTo2bit(
    input               clk,
    input               rst,
    input               TXEN,
    input               TXD,

    input               RMII_REFCLK,
    output  reg         RMII_TXEN_EXT,
    output      [1:0]   RMII_TXD_EXT
    );
    //====================Local 100Mhz colck area===============================================
    reg [5:0]   WRADDR;
    reg [5:0]   WRADDR_hold;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            WRADDR<=6'd0;
            WRADDR_hold<=6'd0;
        end
        else begin
            if(TXEN)
                WRADDR<=WRADDR+1'b1;
            else
                WRADDR<=6'd0;
                
            if(TXEN)
                WRADDR_hold<=WRADDR;
        end
    end
    
    //====================Local 100Mhz - async - RMII_REFCLK===========================================
    wire        RDDATA_H;
    wire        RDDATA_L;
    reg [4:0]   RDADDR;
SimpleDualPortRAM 
    #(
    .DATAWIDTH(1),
    .ADDRESSWIDTH(5),
    .DATANum(32)
    )
    SimpleDualPortRAM_H(
    .WRclk(clk),
    .WRADDR(WRADDR[5:1]),
    .WRDATA(TXD),
    .WR(TXEN&&(WRADDR[0]==1'b1)),
    .RDclk(RMII_REFCLK),
    .RDADDR(RDADDR),
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
    .WRclk(clk),
    .WRADDR(WRADDR[5:1]),
    .WRDATA(TXD),
    .WR(TXEN&&(WRADDR[0]==1'b0)),
    .RDclk(RMII_REFCLK),
    .RDADDR(RDADDR),
    .RDDATA(RDDATA_L),
    .RD(1'b1)
    );
    
    //==delay for buffer
    wire [1:0] TXsigOrg;
    assign TXsigOrg = {TXEN,TXD};
    
    reg [1:0] TXsig[0:5];
    always @ (posedge clk or negedge rst)begin//async sample
        if(!rst)begin
            TXsig[0]<=2'd0;
            TXsig[1]<=2'd0;
            TXsig[2]<=2'd0;
            TXsig[3]<=2'd0;
            TXsig[4]<=2'd0;
            TXsig[5]<=2'd0;
        end
        else begin
            TXsig[0]<=TXsigOrg;
            TXsig[1]<=TXsig[0];
            TXsig[2]<=TXsig[1];
            TXsig[3]<=TXsig[2];
            TXsig[4]<=TXsig[3];
            TXsig[5]<=TXsig[4];
        end
    end
    
    //==data sync
    reg TXENorg_atREFCLK_1;
    reg TXENorg_atREFCLK_2;
    reg TXENorg_atREFCLK_3;
    wire TXENorg_Redge;
    wire TXENorg_Fedge;
    
    reg TXEN5_atREFCLK_1;
    reg TXEN5_atREFCLK_2;
    reg TXEN5_atREFCLK_3;
    wire TXEN5_Redge;
    wire TXEN5_Fedge;
    
    reg [4:0] ENDADDR;
    
    always @ (posedge RMII_REFCLK or negedge rst)begin
        if(!rst)begin
            TXENorg_atREFCLK_1<=1'b0;
            TXENorg_atREFCLK_2<=1'b0;
            TXENorg_atREFCLK_3<=1'b0;
        end
        else begin
            TXENorg_atREFCLK_1<=TXsigOrg[1];
            TXENorg_atREFCLK_2<=TXENorg_atREFCLK_1;
            TXENorg_atREFCLK_3<=TXENorg_atREFCLK_2;
        end
    end
    assign TXENorg_Redge = TXENorg_atREFCLK_2 && !TXENorg_atREFCLK_3;
    assign TXENorg_Fedge = !TXENorg_atREFCLK_2 && TXENorg_atREFCLK_3;
    
    always @ (posedge RMII_REFCLK or negedge rst)begin
        if(!rst)begin
            TXEN5_atREFCLK_1<=1'b0;
            TXEN5_atREFCLK_2<=1'b0;
            TXEN5_atREFCLK_3<=1'b0;
        end
        else begin
            TXEN5_atREFCLK_1<=TXsig[5][1];
            TXEN5_atREFCLK_2<=TXEN5_atREFCLK_1;
            TXEN5_atREFCLK_3<=TXEN5_atREFCLK_2;
        end
    end
    assign TXEN5_Redge = TXEN5_atREFCLK_2 && !TXEN5_atREFCLK_3;
    assign TXEN5_Fedge = !TXEN5_atREFCLK_2 && TXEN5_atREFCLK_3;
    
    always @ (posedge RMII_REFCLK or negedge rst)begin//async sample by hankshake sig
        if(!rst)begin
            ENDADDR<=5'd0;
        end
        else begin
            if(TXENorg_Fedge)
                ENDADDR<=WRADDR_hold[5:1];
        end
    end
    
    //====================RMII_REFCLK colck area===============================================
    reg JudgeArea;
    reg TransEN;
    
    always @ (posedge RMII_REFCLK or negedge rst)begin
        if(!rst)
            JudgeArea<=1'b0;
        else begin
            if(TXENorg_Fedge)
                JudgeArea<=1'b1;
            else if(TXENorg_Redge)
                JudgeArea<=1'b0;
        end
    end
    
    always @ (posedge RMII_REFCLK or negedge rst)begin
        if(!rst)
            TransEN<=1'b0;
        else begin
            if(TransEN==1'b0)begin
                if(TXEN5_Redge)
                    TransEN<=1'b1;
            end
            else begin
                if(JudgeArea&&(RDADDR==ENDADDR))
                    TransEN<=1'b0;
            end
        end
    end

    always @ (posedge RMII_REFCLK or negedge rst)begin
        if(!rst)begin
            RDADDR<=5'd0;
        end
        else begin
            if(TransEN)
                RDADDR<=RDADDR+1'b1;
            else
                RDADDR<=5'd0;
        end
    end
    
    always @ (posedge RMII_REFCLK or negedge rst)begin
        if(!rst)begin
            RMII_TXEN_EXT<=1'b0;
        end
        else begin
            RMII_TXEN_EXT<=TransEN;
        end
    end
    
    assign RMII_TXD_EXT = {RDDATA_L,RDDATA_H};
    
endmodule
