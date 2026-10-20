//SLAVE SPI only support Mode3
//mode3:POL= 1,PHA=1
//when bus is idel SCLK is '1'
//Data is sampled at riging edge of SCK,
//Data changed at falling edge of SCK
module SlaveSPICtrl(    
    input               SPI_SEL,
    input               SPI_CLK,
    input               SPI_MOSI,
    output  reg         SPI_MISO,
    
    input               clk,
    input               rst,
    output  reg         WR,
    output  reg         RD,
    output      [15:0]  ADDR,
    output      [15:0]  WRDATA,
    input       [15:0]  RDDATA,
    input               RDDATAValid
);
    reg [15:0]  RDDATALockpre;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RDDATALockpre<=16'd0;
        end
        else begin
            if(RDDATAValid)
                RDDATALockpre<=RDDATA;
        end        
    end
    wire[15:0]  RDDATALocked;
    assign RDDATALocked = RDDATAValid?RDDATA:RDDATALockpre;
    
    //==SPI side=====================================================================
    wire rst_sel_N;
    assign rst_sel_N = rst && (!SPI_SEL);
    
    reg [7:0] BitCNT;
    always @ (posedge SPI_CLK or negedge rst_sel_N)begin
        if(!rst_sel_N)
            BitCNT<=8'd0;
        else begin
            BitCNT<=BitCNT+8'd1;
        end
    end
    
    reg [15:0]  ADDR_SPI;
    reg [1:0]   CMD_SPI;
    reg [15:0]  DATAIN_SPI;
    reg         AccessMsgValid;
    always @ (posedge SPI_CLK or negedge rst_sel_N)begin
        if(!rst_sel_N)begin
            ADDR_SPI<=16'd0;
            CMD_SPI<=2'b00;
            AccessMsgValid<=1'b0;
        end
        else begin
            case(BitCNT)
            8'd0:ADDR_SPI[15]<=SPI_MOSI;
            8'd1:ADDR_SPI[14]<=SPI_MOSI;
            8'd2:ADDR_SPI[13]<=SPI_MOSI;
            8'd3:ADDR_SPI[12]<=SPI_MOSI;
            8'd4:ADDR_SPI[11]<=SPI_MOSI;
            8'd5:ADDR_SPI[10]<=SPI_MOSI;
            8'd6:ADDR_SPI[9]<=SPI_MOSI;
            8'd7:ADDR_SPI[8]<=SPI_MOSI;
            8'd8:ADDR_SPI[7]<=SPI_MOSI;
            8'd9:ADDR_SPI[6]<=SPI_MOSI;
            8'd10:ADDR_SPI[5]<=SPI_MOSI;
            8'd11:ADDR_SPI[4]<=SPI_MOSI;
            8'd12:ADDR_SPI[3]<=SPI_MOSI;
            8'd13:ADDR_SPI[2]<=SPI_MOSI;
            8'd14:ADDR_SPI[1]<=SPI_MOSI;
            8'd15:ADDR_SPI[0]<=SPI_MOSI;
            8'd16:CMD_SPI[1]<=SPI_MOSI;
            8'd17:CMD_SPI[0]<=SPI_MOSI;
            8'd18:AccessMsgValid<=1'b1;
            // 8'd19:
            // 8'd20:
            // 8'd21:
            // 8'd22:
            // 8'd23:
            8'd24:DATAIN_SPI[15]<=SPI_MOSI;
            8'd25:DATAIN_SPI[14]<=SPI_MOSI;
            8'd26:DATAIN_SPI[13]<=SPI_MOSI;
            8'd27:DATAIN_SPI[12]<=SPI_MOSI;
            8'd28:DATAIN_SPI[11]<=SPI_MOSI;
            8'd29:DATAIN_SPI[10]<=SPI_MOSI;
            8'd30:DATAIN_SPI[9]<=SPI_MOSI;
            8'd31:DATAIN_SPI[8]<=SPI_MOSI;
            8'd32:DATAIN_SPI[7]<=SPI_MOSI;
            8'd33:DATAIN_SPI[6]<=SPI_MOSI;
            8'd34:DATAIN_SPI[5]<=SPI_MOSI;
            8'd35:DATAIN_SPI[4]<=SPI_MOSI;
            8'd36:DATAIN_SPI[3]<=SPI_MOSI;
            8'd37:DATAIN_SPI[2]<=SPI_MOSI;
            8'd38:DATAIN_SPI[1]<=SPI_MOSI;
            8'd39:DATAIN_SPI[0]<=SPI_MOSI;
            endcase
        end
    end
    
    always @ (posedge SPI_CLK or negedge rst_sel_N)begin
        if(!rst_sel_N)begin
            SPI_MISO<=1'b1;
        end
        else begin
            case(BitCNT)
            8'd23:SPI_MISO<=RDDATALocked[15];
            8'd24:SPI_MISO<=RDDATALocked[14];
            8'd25:SPI_MISO<=RDDATALocked[13];
            8'd26:SPI_MISO<=RDDATALocked[12];
            8'd27:SPI_MISO<=RDDATALocked[11];
            8'd28:SPI_MISO<=RDDATALocked[10];
            8'd29:SPI_MISO<=RDDATALocked[9];
            8'd30:SPI_MISO<=RDDATALocked[8];
            8'd31:SPI_MISO<=RDDATALocked[7];
            8'd32:SPI_MISO<=RDDATALocked[6];
            8'd33:SPI_MISO<=RDDATALocked[5];
            8'd34:SPI_MISO<=RDDATALocked[4];
            8'd35:SPI_MISO<=RDDATALocked[3];
            8'd36:SPI_MISO<=RDDATALocked[2];
            8'd37:SPI_MISO<=RDDATALocked[1];
            8'd38:SPI_MISO<=RDDATALocked[0];
            endcase
        end
    end
    
    //==Inner side=====================================================================

    
    reg SPI_SEL_dly1;
    reg SPI_SEL_dly2;
    reg SPI_SEL_dly3;
    reg AccessMsgValid_dly1;
    reg AccessMsgValid_dly2;
    reg AccessMsgValid_dly3;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            AccessMsgValid_dly1<=1'b0;
            AccessMsgValid_dly2<=1'b0;
            AccessMsgValid_dly3<=1'b0;
            SPI_SEL_dly1<=1'b1;
            SPI_SEL_dly2<=1'b1;
            SPI_SEL_dly3<=1'b1;
        end
        else begin
            AccessMsgValid_dly1<=AccessMsgValid;
            AccessMsgValid_dly2<=AccessMsgValid_dly1;
            AccessMsgValid_dly3<=AccessMsgValid_dly2;
            SPI_SEL_dly1<=SPI_SEL;
            SPI_SEL_dly2<=SPI_SEL_dly1;
            SPI_SEL_dly3<=SPI_SEL_dly2;            
        end        
    end
    
    wire    AccessMsgValid_syncpluse;
    assign AccessMsgValid_syncpluse = AccessMsgValid_dly2&&(!AccessMsgValid_dly3);
    
    wire    SPItrans_endPluse;
    assign SPItrans_endPluse = SPI_SEL_dly2&&(!SPI_SEL_dly3);
    
    reg [15:0]  ADDR_lock;
    reg [1:0]   CMD_lock;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            ADDR_lock<=16'd0;
            CMD_lock<=2'b00;
        end
        else begin
            if(AccessMsgValid_syncpluse)begin
                ADDR_lock<=ADDR_SPI;
                CMD_lock<=CMD_SPI;
            end
        end        
    end
    
    assign ADDR = ADDR_lock;
    assign WRDATA = DATAIN_SPI;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RD<=1'b0;
        end
        else begin
            if(AccessMsgValid_syncpluse)begin
                case(CMD_SPI)
                2'b00:RD<=1'b0;
                2'b01:RD<=1'b1;
                2'b10:RD<=1'b0;
                2'b11:RD<=1'b1;
                endcase
            end
            else
                RD<=1'b0;
        end        
    end
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            WR<=1'b0;
        end
        else begin
            if(SPItrans_endPluse)begin
                case(CMD_lock)
                2'b00:WR<=1'b0;
                2'b01:WR<=1'b0;
                2'b10:WR<=1'b1;
                2'b11:WR<=1'b1;
                endcase
            end
            else
                WR<=1'b0;
        end        
    end
    
    

endmodule
