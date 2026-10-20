module AsyncBusInterface_Renesas (
    input                   clk,
    input                   rst,
    
    input                   XCS,
    input                   XRD,
    input                   XWE,
    input           [15:0]  XDin,
    output          [15:0]  XDout,
    input           [15:0]  XA,

    output                  FPGA_RE,
    output                  FPGA_WE,
    output          [15:0]  FPGA_XA,
    output          [15:0]  FPGA_XDout,
    input                   FPGA_XDinValid,
    input           [15:0]  FPGA_XDin
    );
    
    reg             XCS_dly1;
    reg             XRD_dly1;
    reg             XWE_dly1;
    reg     [15:0]  XA_dly1;
    reg     [15:0]  XDin_dly1;
    
    reg             XCS_sync;
    reg             XRD_sync;
    reg             XWE_sync;
    reg     [15:0]  XA_sync;
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
            XA_dly1<=16'd0;
            XDin_dly1<=16'd0;
    
            XCS_sync<=1'b1;
            XRD_sync<=1'b1;
            XWE_sync<=1'b1;
            XA_sync<=16'd0;
            XDin_sync<=16'd0;
            
            XRD_sync_dly<=1'b1;
            XWE_sync_dly<=1'b1;         
        end
        else begin
            XCS_dly1<=XCS;
            XRD_dly1<=XRD || XCS;
            XWE_dly1<=XWE || XCS;
            XA_dly1<=XA;
            XDin_dly1<=XDin;
    
            XCS_sync<=XCS_dly1;
            XRD_sync<=XRD_dly1;
            XWE_sync<=XWE_dly1;
            XA_sync<=XA_dly1;
            XDin_sync<=XDin_dly1;
            
            XCS_sync_dly<=XCS_sync;
            XRD_sync_dly<=XRD_sync;
            XWE_sync_dly<=XWE_sync;             
        end
    end
    
    
    assign FPGA_RE = (XRD_sync==1'b0)&&(XRD_sync_dly==1'b1);
    assign FPGA_WE = (XWE_sync==1'b1)&&(XWE_sync_dly==1'b0);
    
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
                FPGA_XA_lock<=XA_sync;
        end
    end
    
    assign FPGA_XA = ((FPGA_RE_Nedge)||(FPGA_WE_Nedge))?XA_sync:FPGA_XA_lock;
    assign FPGA_XDout = XDin_sync;
    
    //三态门实现双向总线
    //assign XD = ((!XRD) && (!XCS))? DataLocked:{16{1'bz}};
    assign XDout = DataLocked;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            DataLocked_pre<=16'd0;
        else begin
            if(FPGA_XDinValid==1'b1)
                DataLocked_pre<=FPGA_XDin;
        end
    end
    
    assign DataLocked = (FPGA_XDinValid==1'b1)?FPGA_XDin:DataLocked_pre;
    
    
    
endmodule
