module BusTimingConv_DataAddrMultiplex_Async (
    input                   clk,
    input                   rst,
    
    input                   XCS,
    input                   XRD,
    input                   XWE,
    input           [15:0]  XDin,
    output          [15:0]  XDout,
    input                   Nadv,

    output                  FPGA_RE,
    output                  FPGA_WE,
    output  reg     [15:0]  FPGA_XA,
    output          [15:0]  FPGA_XDout,
    input                   FPGA_XDinValid,
    input           [15:0]  FPGA_XDin
    );
    
    reg             XCS_dly1;
    reg             XRD_dly1;
    reg             XWE_dly1;
    reg             Nadv_dly1;
    reg     [15:0]  XDin_dly1;
    
    reg             XCS_dly2;
    reg             XRD_dly2;
    reg             XWE_dly2;
    reg             Nadv_dly2;
    reg     [15:0]  XDin_dly2;
    
    reg             XCS_dly3;
    reg             XRD_dly3;
    reg             XWE_dly3;
    reg             Nadv_dly3;
    reg     [15:0]  XDin_dly3;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            XCS_dly1<=1'b1;
            XRD_dly1<=1'b1;
            XWE_dly1<=1'b1;
            Nadv_dly1<=1'b1;
            XDin_dly1<=16'd0;
            
            XCS_dly2<=1'b1;
            XRD_dly2<=1'b1;
            XWE_dly2<=1'b1; 
            Nadv_dly2<=1'b1;
            XDin_dly2<=16'd0;
            
            XCS_dly3<=1'b1;
            XRD_dly3<=1'b1;
            XWE_dly3<=1'b1; 
            Nadv_dly3<=1'b1;    
            XDin_dly3<=16'd0;
        end
        else begin
            XCS_dly1<=XCS;
            XRD_dly1<=XRD;
            XWE_dly1<=XWE;
            Nadv_dly1<=Nadv;
            XDin_dly1<=XDin;
            
            XCS_dly2<=XCS_dly1;
            XRD_dly2<=XRD_dly1;
            XWE_dly2<=XWE_dly1;
            Nadv_dly2<=Nadv_dly1;
            XDin_dly2<=XDin_dly1;
            
            XCS_dly3<=XCS_dly2;
            XRD_dly3<=XRD_dly2;
            XWE_dly3<=XWE_dly2; 
            Nadv_dly3<=Nadv_dly2;    
            XDin_dly3<=XDin_dly2;            
        end
    end
    
    wire XCS_Nedge;
    assign XCS_Nedge = (XCS_dly2==1'b0)&&(XCS_dly3==1'b1);
    wire XWE_Nedge;
    assign XWE_Nedge = (XWE_dly2==1'b1)&&(XWE_dly3==1'b0);
    wire XRD_Nedge;
    assign XRD_Nedge = (XRD_dly1==1'b0)&&(XRD_dly2==1'b1);
    wire Nadv_Nedge;
    assign Nadv_Nedge = (Nadv_dly2==1'b0)&&(Nadv_dly3==1'b1);
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            FPGA_XA<=16'd0;
        end
        else begin    
            if(Nadv_Nedge)
                FPGA_XA<=XDin_dly2;
        end
    end
    
    assign FPGA_XDout = XDin_dly2;
    
/*     reg FPGA_WE_pre0;
    reg FPGA_WE_pre1;
    reg FPGA_WE_pre2;
    reg FPGA_WE_pre3;
    reg FPGA_WE_pre4;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            FPGA_WE_pre0<=1'b0;
            FPGA_WE_pre1<=1'b0;
            FPGA_WE_pre2<=1'b0;
            FPGA_WE_pre3<=1'b0;
            FPGA_WE_pre4<=1'b0;          
            FPGA_WE<=1'b0;  
        end
        else begin
            FPGA_WE_pre0<=XWE_Nedge;
            FPGA_WE_pre1<=FPGA_WE_pre0;
            FPGA_WE_pre2<=FPGA_WE_pre1;
            FPGA_WE_pre3<=FPGA_WE_pre2;
            FPGA_WE_pre4<=FPGA_WE_pre3;            
            FPGA_WE<=XWE_Nedge;            
        end
    end */
    assign FPGA_WE=XWE_Nedge; 
/*     reg FPGA_RE_pre0;
    reg FPGA_RE_pre1;
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            FPGA_RE_pre0<=1'b0;
            FPGA_RE_pre1<=1'b0;
            FPGA_RE<=1'b0;  
        end
        else begin
            FPGA_RE_pre0<=XRD_Nedge;
            FPGA_RE_pre1<=FPGA_RE_pre0;
            FPGA_RE<=XRD_Nedge;            
        end
    end */
    assign FPGA_RE = XRD_Nedge;
    
    reg     [15:0]  DataLocked_pre;
    wire    [15:0]  DataLocked;    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            DataLocked_pre<=16'd0;
        else begin
            if(FPGA_XDinValid==1'b1)
                DataLocked_pre<=FPGA_XDin;
        end
    end
    assign DataLocked = (FPGA_XDinValid==1'b1)?FPGA_XDin:DataLocked_pre;
    assign XDout = DataLocked;
    
endmodule

/* module BusTimingConv_DataAddrMultiplex_Async (
    input                   clk,
    input                   rst,
    
    input                   XCS,
    input                   XRD,
    input                   XWE,
    input           [15:0]  XDin,
    output          [15:0]  XDout,
    input                   Nadv,

    output  reg             FPGA_RE,
    output  reg             FPGA_WE,
    output          [15:0]  FPGA_XA,
    output          [15:0]  FPGA_XDout,
    input                   FPGA_XDinValid,
    input           [15:0]  FPGA_XDin
    );
    
    reg             XCS_dly1;
    reg             XRD_dly1;
    reg             XWE_dly1;
    reg     [15:0]  XDin_dly1;
    
    reg             XCS_sync;
    reg             XRD_sync;
    reg             XWE_sync;
    reg     [15:0]  XDin_sync;
    
    reg             XCS_sync_dly;    
    reg             XRD_sync_dly;
    reg             XWE_sync_dly;
 
    reg             FPGA_RE_dly;
    reg     [15:0]  DataLocked_pre;
    wire    [15:0]  DataLocked;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            XCS_dly1<=1'b1;
            XRD_dly1<=1'b1;
            XWE_dly1<=1'b1;
            XDin_dly1<=16'd0;
    
            XCS_sync<=1'b1;
            XRD_sync<=1'b1;
            XWE_sync<=1'b1;
            XDin_sync<=16'd0;
            
            XRD_sync_dly<=1'b1;
            XWE_sync_dly<=1'b1;         
        end
        else begin
            XCS_dly1<=XCS;
            XRD_dly1<=XRD;
            XWE_dly1<=XWE;
            XDin_dly1<=XDin;
    
            XCS_sync<=XCS_dly1;
            XRD_sync<=XRD_dly1;
            XWE_sync<=XWE_dly1;
            XDin_sync<=XDin_dly1;
            
            XCS_sync_dly<=XCS_sync;
            XRD_sync_dly<=XRD_sync;
            XWE_sync_dly<=XWE_sync;             
        end
    end
    
    

    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            FPGA_RE<=1'b0;
            FPGA_WE<=1'b0;
        end
        else begin
            FPGA_RE <= ((XRD_sync==1'b0)&&(XRD_sync_dly==1'b1))&&(XCS_sync_dly==1'b0);
            FPGA_WE <= ((XWE_sync==1'b1)&&(XWE_sync_dly==1'b0))&&(XCS_sync_dly==1'b0);
        end
    end
    
    
    wire    FPGA_RE_Nedge;
    wire    FPGA_WE_Nedge;
    assign FPGA_RE_Nedge = (XRD_sync==1'b0)&&(XRD_sync_dly==1'b1);
    assign FPGA_WE_Nedge = (XWE_sync==1'b0)&&(XWE_sync_dly==1'b1);
    
    reg [15:0]  FPGA_XA_lock;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            FPGA_XA_lock<=16'd0;
        else begin
            if((FPGA_RE_Nedge)||(FPGA_WE_Nedge))
                FPGA_XA_lock<=XDin_sync;
        end
    end
    assign FPGA_XA = ((FPGA_RE_Nedge)||(FPGA_WE_Nedge))?XDin_sync:FPGA_XA_lock;
    
    assign FPGA_XDout = XDin_sync;
    
    //==================================
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            DataLocked_pre<=16'd0;
        else begin
            if(FPGA_XDinValid==1'b1)
                DataLocked_pre<=FPGA_XDin;
        end
    end
    
    assign DataLocked = (FPGA_XDinValid==1'b1)?FPGA_XDin:DataLocked_pre;
    
    assign XDout = DataLocked;
    
endmodule
 */