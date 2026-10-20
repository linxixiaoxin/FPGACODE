module AccessLocalspcae(
    input                       clk,
    input                       rst,
    
    input                       D_AccessSource,
    input                       D_CS,
    input                       D_RDLWRH,
    input               [15:0]  D_ADDR,
    input               [15:0]  D_WRDATA,
    output  reg         [15:0]  D_RDDATA,
    output  reg                 D_FPGA_XDinValid,
    output  reg                 D_UserSpace_RDDATAVALID,
    output  reg                 D_UserSpace_WRACK,
    //Slave=============================inner regs space interface
    //public channel
    output                      RDLWRH,
    output              [15:0]  ADDR,
    output              [15:0]  WRDATA,
    
    output                      DebugReserve_CS,//Debug Reserve Space
    input               [15:0]  DebugReserve_RDDATA,
    output                      CurrentSample_CS,//CurrentSample channel 
    input               [15:0]  CurrentSample_RDDATA,
    output                      PositionSample_CS,//PositioonSample channel 
    input               [15:0]  PositionSample_RDDATA,
    output                      AxisesCurrentCtrler_CS,//AxisesCurrentCtrler channel 
    input               [15:0]  AxisesCurrentCtrler_RDDATA,
    output                      CarrierModuleCtrler_CS,//CarrierModuleCtrler channel 
    input               [15:0]  CarrierModuleCtrler_RDDATA,
    output                      IndirectRelevantSig_CS,//IndirectRelevantSig channel 
    input               [15:0]  IndirectRelevantSig_RDDATA,
    output                      SafetyMonitorModule_CS,//SafetyMonitorModule channel 
    input               [15:0]  SafetyMonitorModule_RDDATA,
    output                      OverAllControl_CS,//OverAllControl channel 
    input               [15:0]  OverAllControl_RDDATA   
    );
    localparam DebugReserve_BaseAddr        = 16'h0000;
    localparam DebugReserve_ENDAddr         = 16'h00FF;
    localparam CurrentSample_BaseAddr       = 16'h0100;
    localparam CurrentSample_ENDAddr        = 16'h01FF;
    localparam PositioonSample_BaseAddr     = 16'h0200;
    localparam PositioonSample_ENDAddr      = 16'h02FF;
    localparam AxisesCurrentCtrler_BaseAddr = 16'h0300;
    localparam AxisesCurrentCtrler_ENDAddr  = 16'h06FF;
    localparam CarrierModuleCtrler_BaseAddr = 16'h0700;
    localparam CarrierModuleCtrler_ENDAddr  = 16'h077F;
    localparam IndirectRelevantSig_BaseAddr = 16'h0780;
    localparam IndirectRelevantSig_ENDAddr  = 16'h07FF;
    localparam SafetyMonitorModule_BaseAddr = 16'h0800;
    localparam SafetyMonitorModule_ENDAddr  = 16'h087F;
    localparam OverAllControl_BaseAddr      = 16'h0880;
    localparam OverAllControl_ENDAddr       = 16'h08FF;
    
    
    //======Non delay============================================================================
    wire    DebugReserve_CS_0stclk;//Debug Reserve Space
    wire    CurrentSample_CS_0stclk;//CurrentSample channel 
    wire    PositionSample_CS_0stclk;//PositioonSample channel 
    wire    AxisesCurrentCtrler_CS_0stclk;//AxisesCurrentCtrler channel 
    wire    CarrierModuleCtrler_CS_0stclk;//CarrierModuleCtrler channel 
    wire    IndirectRelevantSig_CS_0stclk;//IndirectRelevantSig channel 
    wire    SafetyMonitorModule_CS_0stclk;//SafetyMonitorModule channel 
    wire    OverAllControl_CS_0stclk;//OverAllControl channel
    
    assign DebugReserve_CS_0stclk          = D_CS&&((D_ADDR>=DebugReserve_BaseAddr)&&(D_ADDR<=DebugReserve_ENDAddr));
    assign CurrentSample_CS_0stclk         = D_CS&&((D_ADDR>=CurrentSample_BaseAddr)&&(D_ADDR<=CurrentSample_ENDAddr));
    assign PositionSample_CS_0stclk        = D_CS&&((D_ADDR>=PositioonSample_BaseAddr)&&(D_ADDR<=PositioonSample_ENDAddr));
    assign AxisesCurrentCtrler_CS_0stclk   = D_CS&&((D_ADDR>=AxisesCurrentCtrler_BaseAddr)&&(D_ADDR<=AxisesCurrentCtrler_ENDAddr));
    assign CarrierModuleCtrler_CS_0stclk   = D_CS&&((D_ADDR>=CarrierModuleCtrler_BaseAddr)&&(D_ADDR<=CarrierModuleCtrler_ENDAddr));
    assign IndirectRelevantSig_CS_0stclk   = D_CS&&((D_ADDR>=IndirectRelevantSig_BaseAddr)&&(D_ADDR<=IndirectRelevantSig_ENDAddr));
    assign SafetyMonitorModule_CS_0stclk   = D_CS&&((D_ADDR>=SafetyMonitorModule_BaseAddr)&&(D_ADDR<=SafetyMonitorModule_ENDAddr));
    assign OverAllControl_CS_0stclk        = D_CS&&((D_ADDR>=OverAllControl_BaseAddr)&&(D_ADDR<=OverAllControl_ENDAddr));    
    
    
    //======1stclk delay============================================================================
    reg     AccessSource_1stclk;
    reg     D_CS_1stclk;
    reg     RDLWRH_1stclk;
    reg     [15:0]  WRDATA_1stclk;
    reg     [15:0]  ADDR_1stclk;
    
    reg     DebugReserve_CS_1stclk;
    reg     CurrentSample_CS_1stclk;
    reg     PositionSample_CS_1stclk;
    reg     AxisesCurrentCtrler_CS_1stclk;
    reg     CarrierModuleCtrler_CS_1stclk; 
    reg     IndirectRelevantSig_CS_1stclk;
    reg     SafetyMonitorModule_CS_1stclk;
    reg     OverAllControl_CS_1stclk;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RDLWRH_1stclk<=1'b0;
            WRDATA_1stclk<=16'd0;
            D_CS_1stclk<=1'b0;
            AccessSource_1stclk<=1'b0;
        end
        else begin
            RDLWRH_1stclk<=D_RDLWRH;
            WRDATA_1stclk<=D_WRDATA;
            D_CS_1stclk<=D_CS;
            AccessSource_1stclk<=D_AccessSource;
        end
    end


    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            DebugReserve_CS_1stclk<=1'b0;//Debug Reserve Space
            CurrentSample_CS_1stclk<=1'b0;//CurrentSample channel 
            PositionSample_CS_1stclk<=1'b0;//PositioonSample channel 
            AxisesCurrentCtrler_CS_1stclk<=1'b0;//AxisesCurrentCtrler channel 
            CarrierModuleCtrler_CS_1stclk<=1'b0;//CarrierModuleCtrler channel 
            IndirectRelevantSig_CS_1stclk<=1'b0;//IndirectRelevantSig channel 
            SafetyMonitorModule_CS_1stclk<=1'b0;//SafetyMonitorModule channel 
            OverAllControl_CS_1stclk<=1'b0;//OverAllControl channel
        end
        else begin
            DebugReserve_CS_1stclk<=DebugReserve_CS_0stclk;//Debug Reserve Space
            CurrentSample_CS_1stclk<=CurrentSample_CS_0stclk;//CurrentSample channel 
            PositionSample_CS_1stclk<=PositionSample_CS_0stclk;//PositioonSample channel 
            AxisesCurrentCtrler_CS_1stclk<=AxisesCurrentCtrler_CS_0stclk;//AxisesCurrentCtrler channel 
            CarrierModuleCtrler_CS_1stclk<=CarrierModuleCtrler_CS_0stclk;//CarrierModuleCtrler channel 
            IndirectRelevantSig_CS_1stclk<=IndirectRelevantSig_CS_0stclk;//IndirectRelevantSig channel 
            SafetyMonitorModule_CS_1stclk<=SafetyMonitorModule_CS_0stclk;//SafetyMonitorModule channel 
            OverAllControl_CS_1stclk<=OverAllControl_CS_0stclk;//OverAllControl channel
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            ADDR_1stclk<=16'd0;
        end
        else begin
            if(DebugReserve_CS_0stclk)      
                ADDR_1stclk<=D_ADDR-DebugReserve_BaseAddr;
            else if(CurrentSample_CS_0stclk)
                ADDR_1stclk<=D_ADDR-CurrentSample_BaseAddr;
            else if(PositionSample_CS_0stclk)
                ADDR_1stclk<=D_ADDR-PositioonSample_BaseAddr;
            else if(AxisesCurrentCtrler_CS_0stclk)
                ADDR_1stclk<=D_ADDR-AxisesCurrentCtrler_BaseAddr;
            else if(CarrierModuleCtrler_CS_0stclk)
                ADDR_1stclk<=D_ADDR-CarrierModuleCtrler_BaseAddr;
            else if(IndirectRelevantSig_CS_0stclk)
                ADDR_1stclk<=D_ADDR-IndirectRelevantSig_BaseAddr;
            else if(SafetyMonitorModule_CS_0stclk)
                ADDR_1stclk<=D_ADDR-SafetyMonitorModule_BaseAddr;
            else if(OverAllControl_CS_0stclk)
                ADDR_1stclk<=D_ADDR-OverAllControl_BaseAddr;
            else
                ADDR_1stclk<=16'd0;
        end
    end 
    
    assign RDLWRH = RDLWRH_1stclk;
    assign ADDR = ADDR_1stclk;
    assign WRDATA = WRDATA_1stclk;
    assign DebugReserve_CS=DebugReserve_CS_1stclk;
    assign CurrentSample_CS=CurrentSample_CS_1stclk;
    assign PositionSample_CS=PositionSample_CS_1stclk;
    assign AxisesCurrentCtrler_CS=AxisesCurrentCtrler_CS_1stclk;
    assign CarrierModuleCtrler_CS=CarrierModuleCtrler_CS_1stclk; 
    assign IndirectRelevantSig_CS=IndirectRelevantSig_CS_1stclk;
    assign SafetyMonitorModule_CS=SafetyMonitorModule_CS_1stclk;
    assign OverAllControl_CS=OverAllControl_CS_1stclk;     
    
    
    //Access sig out========
    //Access sig out========
    //Access sig out========
    //Access sig out========
    //Access sig out========
    //Access sig out========
    //==========//
    //==========//
    //Feedback sig in=======
    //Feedback sig in=======
    //Feedback sig in=======
    //Feedback sig in=======
    //Feedback sig in=======
    //Feedback sig in=======
    
    
    //======2stclk delay============================================================================
    reg     AccessSource_2stclk;
    reg     D_CS_2stclk;
    reg     RDLWRH_2stclk;
    
    reg     DebugReserve_CS_2stclk;
    reg     CurrentSample_CS_2stclk;
    reg     PositionSample_CS_2stclk;
    reg     AxisesCurrentCtrler_CS_2stclk;
    reg     CarrierModuleCtrler_CS_2stclk; 
    reg     IndirectRelevantSig_CS_2stclk;
    reg     SafetyMonitorModule_CS_2stclk;
    reg     OverAllControl_CS_2stclk;    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            RDLWRH_2stclk<=1'b0;
            D_CS_2stclk<=1'b0;
            AccessSource_2stclk<=1'b0;

            DebugReserve_CS_2stclk<=1'b0;
            CurrentSample_CS_2stclk<=1'b0;
            PositionSample_CS_2stclk<=1'b0;
            AxisesCurrentCtrler_CS_2stclk<=1'b0;
            CarrierModuleCtrler_CS_2stclk<=1'b0; 
            IndirectRelevantSig_CS_2stclk<=1'b0;
            SafetyMonitorModule_CS_2stclk<=1'b0;
            OverAllControl_CS_2stclk<=1'b0; 
        end
        else begin
            RDLWRH_2stclk<=RDLWRH_1stclk;
            D_CS_2stclk<=D_CS_1stclk;
            AccessSource_2stclk<=AccessSource_1stclk;
            
            DebugReserve_CS_2stclk<=DebugReserve_CS_1stclk;
            CurrentSample_CS_2stclk<=CurrentSample_CS_1stclk;
            PositionSample_CS_2stclk<=PositionSample_CS_1stclk;
            AxisesCurrentCtrler_CS_2stclk<=AxisesCurrentCtrler_CS_1stclk;
            CarrierModuleCtrler_CS_2stclk<=CarrierModuleCtrler_CS_1stclk; 
            IndirectRelevantSig_CS_2stclk<=IndirectRelevantSig_CS_1stclk;
            SafetyMonitorModule_CS_2stclk<=SafetyMonitorModule_CS_1stclk;
            OverAllControl_CS_2stclk<=OverAllControl_CS_1stclk;             
        end
    end 
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            D_RDDATA<=16'd0;
        end
        else begin
            if(D_CS_2stclk&&(RDLWRH_2stclk==1'b0))begin
                if(DebugReserve_CS_2stclk==1'b1)
                    D_RDDATA<=DebugReserve_RDDATA;
                else if(CurrentSample_CS_2stclk==1'b1)
                    D_RDDATA<=CurrentSample_RDDATA;
                else if(PositionSample_CS_2stclk==1'b1)
                    D_RDDATA<=PositionSample_RDDATA;
                else if(AxisesCurrentCtrler_CS_2stclk==1'b1)
                    D_RDDATA<=AxisesCurrentCtrler_RDDATA;
                else if(CarrierModuleCtrler_CS_2stclk==1'b1)
                    D_RDDATA<=CarrierModuleCtrler_RDDATA;
                else if(IndirectRelevantSig_CS_2stclk==1'b1)
                    D_RDDATA<=IndirectRelevantSig_RDDATA;
                else if(SafetyMonitorModule_CS_2stclk==1'b1)
                    D_RDDATA<=SafetyMonitorModule_RDDATA;
                else if(OverAllControl_CS_2stclk==1'b1)
                    D_RDDATA<=OverAllControl_RDDATA;                
                else
                    D_RDDATA<=16'd0;
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            D_FPGA_XDinValid<=1'b0;
        end
        else begin
            D_FPGA_XDinValid<=((AccessSource_2stclk==1'b0)&&(D_CS_2stclk==1'b1)&&(RDLWRH_2stclk==1'b0));
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            D_UserSpace_RDDATAVALID<=1'b0;
        end
        else begin
            D_UserSpace_RDDATAVALID<=((AccessSource_2stclk==1'b1)&&(D_CS_2stclk==1'b1)&&(RDLWRH_2stclk==1'b0));
        end
    end  

    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            D_UserSpace_WRACK<=1'b0;
        end
        else begin
            D_UserSpace_WRACK<=((AccessSource_2stclk==1'b1)&&(D_CS_2stclk==1'b1)&&(RDLWRH_2stclk==1'b1));
        end
    end

endmodule
