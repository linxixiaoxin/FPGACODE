module MultiAccessPreDeal(
    input                       clk,
    input                       rst,
    //Master1===========================Async Bus
    input                       FPGA_RE,
    input                       FPGA_WE,
    input               [15:0]  FPGA_XA,
    input               [15:0]  FPGA_XDout,
    output                      FPGA_XDinValid,
    output              [15:0]  FPGA_XDin,
    //Master2===========================StandardDebugModule Interface
    input                       UserSpace_RD,//next Access wait 'UserSpace_RDDATAVALID' ack
    input                       UserSpace_WR,//next Access wait 'UserSpace_WRACK' ack
    input               [15:0]  UserSpace_ADDR,
    input               [15:0]  UserSpace_WRDATA,
    output              [15:0]  UserSpace_RDDATA,
    output                      UserSpace_RDDATAVALID,//at least delay 'UserSpace_RD' 1 clk
    output                      UserSpace_WRACK,//at least delay 'UserSpace_WR' 1 clk
    //Active port
    output  reg                 D_AccessSource,
    output  reg                 D_CS,
    output  reg                 D_RDLWRH,
    output  reg         [15:0]  D_ADDR,
    output  reg         [15:0]  D_WRDATA,
    input               [15:0]  D_RDDATA,
    input                       D_FPGA_XDinValid,
    input                       D_UserSpace_RDDATAVALID,
    input                       D_UserSpace_WRACK
    );
    
    //======Master1
    assign FPGA_XDinValid = D_FPGA_XDinValid;
    assign FPGA_XDin = D_RDDATA;
    
    wire                Mst1_CS;
    wire                Mst1_RDLWRH;
    wire        [15:0]  Mst1_ADDR;
    wire        [15:0]  Mst1_WRDATA;
    
    assign Mst1_CS = FPGA_RE||FPGA_WE;
    assign Mst1_RDLWRH = FPGA_WE;
    assign Mst1_ADDR = FPGA_XA;
    assign Mst1_WRDATA = FPGA_XDout;
    
    //======Master2
    assign UserSpace_RDDATAVALID = D_UserSpace_RDDATAVALID;
    assign UserSpace_WRACK = D_UserSpace_WRACK;
    assign UserSpace_RDDATA = D_RDDATA;
    
    wire                Mst2_CS_pre;
    wire                Mst2_RDLWRH_pre;
    wire        [15:0]  Mst2_ADDR_pre;
    wire        [15:0]  Mst2_WRDATA_pre;
    assign Mst2_CS_pre = UserSpace_RD||UserSpace_WR;
    assign Mst2_RDLWRH_pre = UserSpace_WR;
    assign Mst2_ADDR_pre = UserSpace_ADDR;
    assign Mst2_WRDATA_pre = UserSpace_WRDATA;
    
    reg                 Mst2_CS_pre_dly;
    reg                 Mst2_RDLWRH_pre_dly;
    reg         [15:0]  Mst2_ADDR_pre_dly;
    reg         [15:0]  Mst2_WRDATA_pre_dly;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Mst2_CS_pre_dly<=1'b0;
            Mst2_RDLWRH_pre_dly<=1'b0;
            Mst2_ADDR_pre_dly<=16'd0;
            Mst2_WRDATA_pre_dly<=16'd0;
        end
        else begin
            Mst2_CS_pre_dly<=Mst2_CS_pre;
            Mst2_RDLWRH_pre_dly<=Mst2_RDLWRH_pre;
            Mst2_ADDR_pre_dly<=Mst2_ADDR_pre;
            Mst2_WRDATA_pre_dly<=Mst2_WRDATA_pre;
        end
    end
    
    wire                CollisionDetect;
    reg                 CollisionDetect_dly;
    assign CollisionDetect = Mst1_CS && Mst2_CS_pre;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            CollisionDetect_dly<=1'b0;
        else begin
            CollisionDetect_dly<=CollisionDetect;
        end
    end
    
    wire                Mst2_CS;
    wire                Mst2_RDLWRH;
    wire        [15:0]  Mst2_ADDR;
    wire        [15:0]  Mst2_WRDATA;    
    
    assign Mst2_CS      = (CollisionDetect?1'b0:Mst2_CS_pre)      ||  (CollisionDetect_dly?Mst2_CS_pre_dly:1'b0);
    assign Mst2_RDLWRH  = (CollisionDetect?1'b0:Mst2_RDLWRH_pre)  ||  (CollisionDetect_dly?Mst2_RDLWRH_pre_dly:1'b0);
    assign Mst2_ADDR    = (CollisionDetect_dly?Mst2_ADDR_pre_dly:Mst2_ADDR_pre);
    assign Mst2_WRDATA  = (CollisionDetect_dly?Mst2_WRDATA_pre_dly:Mst2_WRDATA_pre);
    
    always @ (*)begin
        
        D_CS = Mst1_CS || Mst2_CS;
        
        if(Mst1_CS)begin
            D_AccessSource = 1'b0;
            D_RDLWRH = Mst1_RDLWRH;
            D_ADDR = Mst1_ADDR;
            D_WRDATA = Mst1_WRDATA;
        end
        else begin
            if(Mst2_CS)begin
                D_AccessSource = 1'b1;
                D_RDLWRH = Mst2_RDLWRH;
                D_ADDR = Mst2_ADDR;
                D_WRDATA = Mst2_WRDATA;
            end
            else begin
                D_AccessSource = 1'b0;
                D_RDLWRH = Mst1_RDLWRH;
                D_ADDR = Mst1_ADDR;
                D_WRDATA = Mst1_WRDATA;
            end
        end
    end
/*     always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            D_CS<=1'b0;
            D_AccessSource <= 1'b0;
            D_RDLWRH <= 1'b0;
            D_ADDR <= 16'd0;
            D_WRDATA <= 16'd0;
        end
        else begin
            D_CS <= (Mst1_CS || Mst2_CS);
            if(Mst1_CS)begin
                D_AccessSource <= 1'b0;
                D_RDLWRH <= Mst1_RDLWRH;
                D_ADDR <= Mst1_ADDR;
                D_WRDATA <= Mst1_WRDATA;
            end
            else begin
                if(Mst2_CS)begin
                    D_AccessSource <= 1'b1;
                    D_RDLWRH <= Mst2_RDLWRH;
                    D_ADDR <= Mst2_ADDR;
                    D_WRDATA <= Mst2_WRDATA;
                end
                else begin
                    D_AccessSource <= 1'b0;
                    D_RDLWRH <= Mst1_RDLWRH;
                    D_ADDR <= Mst1_ADDR;
                    D_WRDATA <= Mst1_WRDATA;
                end
            end
        end
    end */    

endmodule
