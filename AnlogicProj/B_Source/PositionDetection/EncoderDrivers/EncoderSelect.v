module EncoderSelect(
    input                   clk_20Mhz,//20Mhz
    input                   clk,//100Mhz
    input                   rst,
    input                   RequestTrig,
    
    input           [3:0]   AngleDriverSel,
    
    input                   CalibrationEN,
    output          [3:0]   CalibrationState,
    output                  ENCNoResponsPluse,
    output                  ENCCRCERRPluse,
    
    input                   DMC_IN,//485 TX
    output                  DMC_OUT,//485 RX
    output                  DMC_DE,//485 EN
    output                  BISSCCLK,
    
    input                   PluseA,
    input                   PluseB,
    input                   PluseZ,
    
    output  reg     [31:0]  MechanicalPosition,
    output  reg             PositionValid
    );
    
    reg             SigValid_Common;
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            SigValid_Common<=1'b0;
        else begin
            SigValid_Common<=RequestTrig;
        end
    end
    

//======DMC Position=================================================   
    wire    [31:0]  DMC_MechanicalPosition;
    wire            DMC_SigValid;
    wire            DMC_DE_pre;
LiteDMCProtocol_NonStandardCalibration LiteDMCProtocol(
    .clk(clk),
    .rst(rst),
    
    .CalibrationEN(CalibrationEN),
    .CalibrationState(CalibrationState),
    .ENCNoResponsPluse(ENCNoResponsPluse),
    .ENCCRCERRPluse(ENCCRCERRPluse),
    .RequestTrig(RequestTrig&&(AngleDriverSel==4'd1)),
    .PositionFB(DMC_MechanicalPosition),
    .DataValid(DMC_SigValid),
    
    .DMC_IN(DMC_IN),//485 TX
    .DMC_OUT(DMC_OUT),//485 RX
    .DMC_DE(DMC_DE_pre)//485 EN
    );
    assign DMC_DE = (AngleDriverSel==4'd1)?DMC_DE_pre:1'b0;
    
//======ABZ Position================================================= 
    wire    [31:0]  ABZ_MechanicalPosition;
    
ABZDriver ABZDriver(
    .clk(clk),
    .rst(rst),
    
    .PluseA(PluseA),
    .PluseB(PluseB),
    .PluseZ(PluseZ),
    
    .PluseCounter(ABZ_MechanicalPosition)
    );
    
//======BISSC Position===============================================
    wire    [31:0]  BISSC_MechanicalPosition;
    wire            BISSC_SigValid;
LiteBISSCProtocol LiteBISSCProtocol(
    .clk(clk),//100Mhz
    .rst(rst),
    
    .RequestTrig(RequestTrig),
    .PositionFB(BISSC_MechanicalPosition),
    .DataValid(BISSC_SigValid),
    
    .BISS_DATAIN(DMC_IN),
    .BISS_CLK(BISSCCLK)
    );
    
//======Position Selector============================================    
    always @ (posedge clk or negedge rst)begin
        if(!rst)
            MechanicalPosition<=32'd0;
        else begin
            case(AngleDriverSel)
            4'd0:begin
                MechanicalPosition<=32'd0;//reserve
                PositionValid<=SigValid_Common;
            end
            4'd1:begin
                MechanicalPosition<=DMC_MechanicalPosition;
                PositionValid<=DMC_SigValid;
            end
            4'd2:begin
                MechanicalPosition<=ABZ_MechanicalPosition;
                PositionValid<=SigValid_Common;
            end
            4'd3:begin
                MechanicalPosition<=BISSC_MechanicalPosition;
                PositionValid<=BISSC_SigValid;
            end
            default:begin
                MechanicalPosition<=32'd0;//reserve
                PositionValid<=SigValid_Common;
            end
            endcase
        end  
    end
    
    
    
endmodule