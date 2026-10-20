module RegSpcae_AxisesCurrentCtrler(
    input                       clk,
    input                       rst,
    //data & addr bus
    input                       CS,
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,
    output  reg         [15:0]  RDDATA,
    //inner reg interface
    output  reg         [15:0]  Axis1_DRef,
    output  reg         [31:0]  Axis1_DKp,
    output  reg         [31:0]  Axis1_DKi,
    output  reg         [15:0]  Axis1_DCompensate,
    output  reg         [15:0]  Axis1_QRef,
    output  reg         [31:0]  Axis1_QKp,
    output  reg         [31:0]  Axis1_QKi,
    output  reg         [15:0]  Axis1_QCompensate,
    output  reg         [15:0]  Axis1_LimitCircleRadius,
    output  reg                 Axis1_LimitMode_HDLQ,
    
    output  reg         [15:0]  Axis2_DRef,
    output  reg         [31:0]  Axis2_DKp,
    output  reg         [31:0]  Axis2_DKi,
    output  reg         [15:0]  Axis2_DCompensate,
    output  reg         [15:0]  Axis2_QRef,
    output  reg         [31:0]  Axis2_QKp,
    output  reg         [31:0]  Axis2_QKi,
    output  reg         [15:0]  Axis2_QCompensate,
    output  reg         [15:0]  Axis2_LimitCircleRadius,
    output  reg                 Axis2_LimitMode_HDLQ,

    output  reg         [15:0]  Axis3_DRef,
    output  reg         [31:0]  Axis3_DKp,
    output  reg         [31:0]  Axis3_DKi,
    output  reg         [15:0]  Axis3_DCompensate,
    output  reg         [15:0]  Axis3_QRef,
    output  reg         [31:0]  Axis3_QKp,
    output  reg         [31:0]  Axis3_QKi,
    output  reg         [15:0]  Axis3_QCompensate,
    output  reg         [15:0]  Axis3_LimitCircleRadius,
    output  reg                 Axis3_LimitMode_HDLQ,

    output  reg         [15:0]  Axis4_DRef,
    output  reg         [31:0]  Axis4_DKp,
    output  reg         [31:0]  Axis4_DKi,
    output  reg         [15:0]  Axis4_DCompensate,
    output  reg         [15:0]  Axis4_QRef,
    output  reg         [31:0]  Axis4_QKp,
    output  reg         [31:0]  Axis4_QKi,
    output  reg         [15:0]  Axis4_QCompensate,
    output  reg         [15:0]  Axis4_LimitCircleRadius,
    output  reg                 Axis4_LimitMode_HDLQ,
    
    input               [3:0]   Axises_CalEN,
    input               [3:0]   Axises_CurrentCtrlFinsih,
    input               [31:0]  DUiAcc_Active,
    input               [31:0]  QUiAcc_Active,
    
    input               [15:0]  Axis1_IALPHA,
    input               [15:0]  Axis1_IBETA,
    input               [15:0]  Axis1_ID,
    input               [15:0]  Axis1_IQ,
    output  reg         [31:0]  Axis1_DUiAcc_update,
    output  reg         [31:0]  Axis1_QUiAcc_update,
    input               [15:0]  Axis1_UD, 
    input               [15:0]  Axis1_UQ,
    input               [15:0]  Axis1_UALPHA, 
    input               [15:0]  Axis1_UBETA,
    output  reg                 Axis1_SvpwmInputSel,
    output  reg         [15:0]  Axis1_UALPHA_selfdef,
    output  reg         [15:0]  Axis1_UBETA_selfdef, 
    
    input               [15:0]  Axis2_IALPHA,
    input               [15:0]  Axis2_IBETA,
    input               [15:0]  Axis2_ID,
    input               [15:0]  Axis2_IQ,
    output  reg         [31:0]  Axis2_DUiAcc_update,
    output  reg         [31:0]  Axis2_QUiAcc_update,    
    input               [15:0]  Axis2_UD, 
    input               [15:0]  Axis2_UQ,
    input               [15:0]  Axis2_UALPHA, 
    input               [15:0]  Axis2_UBETA,
    output  reg                 Axis2_SvpwmInputSel,
    output  reg         [15:0]  Axis2_UALPHA_selfdef,
    output  reg         [15:0]  Axis2_UBETA_selfdef,     
    
    input               [15:0]  Axis3_IALPHA,
    input               [15:0]  Axis3_IBETA,
    input               [15:0]  Axis3_ID,
    input               [15:0]  Axis3_IQ,
    output  reg         [31:0]  Axis3_DUiAcc_update,
    output  reg         [31:0]  Axis3_QUiAcc_update,    
    input               [15:0]  Axis3_UD, 
    input               [15:0]  Axis3_UQ,
    input               [15:0]  Axis3_UALPHA, 
    input               [15:0]  Axis3_UBETA,
    output  reg                 Axis3_SvpwmInputSel,
    output  reg         [15:0]  Axis3_UALPHA_selfdef,
    output  reg         [15:0]  Axis3_UBETA_selfdef,     

    input               [15:0]  Axis4_IALPHA,
    input               [15:0]  Axis4_IBETA,
    input               [15:0]  Axis4_ID,
    input               [15:0]  Axis4_IQ,
    output  reg         [31:0]  Axis4_DUiAcc_update,
    output  reg         [31:0]  Axis4_QUiAcc_update,    
    input               [15:0]  Axis4_UD, 
    input               [15:0]  Axis4_UQ,
    input               [15:0]  Axis4_UALPHA, 
    input               [15:0]  Axis4_UBETA,
    output  reg                 Axis4_SvpwmInputSel,
    output  reg         [15:0]  Axis4_UALPHA_selfdef,
    output  reg         [15:0]  Axis4_UBETA_selfdef 
    );
    
    wire            RD;
    wire            WR;
    assign  RD = CS&&(RDLWRH==1'b0);
    assign  WR = CS&&(RDLWRH==1'b1);
    
    
    wire        [15:0]          Axis1_CTRLREG;
    wire        [15:0]          Axis2_CTRLREG;
    wire        [15:0]          Axis3_CTRLREG;
    wire        [15:0]          Axis4_CTRLREG;
    assign Axis1_CTRLREG = {Axis1_LimitMode_HDLQ,15'd0};
    assign Axis2_CTRLREG = {Axis2_LimitMode_HDLQ,15'd0};
    assign Axis3_CTRLREG = {Axis3_LimitMode_HDLQ,15'd0};
    assign Axis4_CTRLREG = {Axis4_LimitMode_HDLQ,15'd0};
   
    
            
    
    //regs Write===========================================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            Axis1_DKp<=32'd327670;
            Axis1_DKi<=32'd3276;
            Axis1_DCompensate<=16'd0;
            Axis1_QKp<=32'd327670;
            Axis1_QKi<=32'd3276;
            Axis1_QCompensate<=16'd0;
            Axis1_LimitCircleRadius<=16'd32767;
            Axis1_DRef<=16'd0;
            Axis1_QRef<=16'd0;
            Axis1_LimitMode_HDLQ<=1'b0;
            Axis1_SvpwmInputSel<=1'b0;
            Axis1_UALPHA_selfdef<=16'd0;
            Axis1_UBETA_selfdef<=16'd0;      
                
            Axis2_DKp<=32'd327670;
            Axis2_DKi<=32'd3276;
            Axis2_DCompensate<=16'd0;
            Axis2_QKp<=32'd327670;
            Axis2_QKi<=32'd3276;
            Axis2_QCompensate<=16'd0;
            Axis2_LimitCircleRadius<=16'd32767;
            Axis2_DRef<=16'd0;
            Axis2_QRef<=16'd0;
            Axis2_LimitMode_HDLQ<=1'b0;  
            Axis2_SvpwmInputSel<=1'b0;
            Axis2_UALPHA_selfdef<=16'd0;
            Axis2_UBETA_selfdef<=16'd0;              

            Axis3_DKp<=32'd327670;
            Axis3_DKi<=32'd3276;
            Axis3_DCompensate<=16'd0;
            Axis3_QKp<=32'd327670;
            Axis3_QKi<=32'd3276;
            Axis3_QCompensate<=16'd0;
            Axis3_LimitCircleRadius<=16'd32767;
            Axis3_DRef<=16'd0;
            Axis3_QRef<=16'd0;
            Axis3_LimitMode_HDLQ<=1'b0;
            Axis3_SvpwmInputSel<=1'b0;
            Axis3_UALPHA_selfdef<=16'd0;
            Axis3_UBETA_selfdef<=16'd0;              

            Axis4_DKp<=32'd327670;
            Axis4_DKi<=32'd3276;
            Axis4_DCompensate<=16'd0;
            Axis4_QKp<=32'd327670;
            Axis4_QKi<=32'd3276;
            Axis4_QCompensate<=16'd0;
            Axis4_LimitCircleRadius<=16'd32767;
            Axis4_DRef<=16'd0;
            Axis4_QRef<=16'd0;
            Axis4_LimitMode_HDLQ<=1'b0; 
            Axis4_SvpwmInputSel<=1'b0;
            Axis4_UALPHA_selfdef<=16'd0;
            Axis4_UBETA_selfdef<=16'd0;              
        end
        else begin
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0004:Axis1_DKp[31:16]<=WRDATA;
                16'h0005:Axis1_DKp[15:0]<=WRDATA;
                16'h0006:Axis1_DKi[31:16]<=WRDATA;
                16'h0007:Axis1_DKi[15:0]<=WRDATA;
                16'h0008:Axis1_DCompensate<=WRDATA;
                16'h0009:Axis1_QKp[31:16]<=WRDATA;
                16'h000A:Axis1_QKp[15:0]<=WRDATA;
                16'h000B:Axis1_QKi[31:16]<=WRDATA;
                16'h000C:Axis1_QKi[15:0]<=WRDATA;
                16'h000D:Axis1_QCompensate<=WRDATA;
                16'h000E:Axis1_LimitCircleRadius<=WRDATA;
                16'h000F:Axis1_DRef<=WRDATA;
                16'h0012:Axis1_QRef<=WRDATA;
                16'h0019:Axis1_LimitMode_HDLQ<=WRDATA[15];
                16'h0020:Axis1_SvpwmInputSel<=WRDATA[0];
                16'h0021:Axis1_UALPHA_selfdef<=WRDATA;
                16'h0022:Axis1_UBETA_selfdef<=WRDATA;                  
                
                16'h0084:Axis2_DKp[31:16]<=WRDATA;
                16'h0085:Axis2_DKp[15:0]<=WRDATA;
                16'h0086:Axis2_DKi[31:16]<=WRDATA;
                16'h0087:Axis2_DKi[15:0]<=WRDATA;
                16'h0088:Axis2_DCompensate<=WRDATA;
                16'h0089:Axis2_QKp[31:16]<=WRDATA;
                16'h008A:Axis2_QKp[15:0]<=WRDATA;
                16'h008B:Axis2_QKi[31:16]<=WRDATA;
                16'h008C:Axis2_QKi[15:0]<=WRDATA;
                16'h008D:Axis2_QCompensate<=WRDATA;
                16'h008E:Axis2_LimitCircleRadius<=WRDATA;
                16'h008F:Axis2_DRef<=WRDATA;
                16'h0092:Axis2_QRef<=WRDATA;
                16'h0099:Axis2_LimitMode_HDLQ<=WRDATA[15];
                16'h00A0:Axis2_SvpwmInputSel<=WRDATA[0];
                16'h00A1:Axis2_UALPHA_selfdef<=WRDATA;
                16'h00A2:Axis2_UBETA_selfdef<=WRDATA;                  

                16'h0104:Axis3_DKp[31:16]<=WRDATA;
                16'h0105:Axis3_DKp[15:0]<=WRDATA;
                16'h0106:Axis3_DKi[31:16]<=WRDATA;
                16'h0107:Axis3_DKi[15:0]<=WRDATA;
                16'h0108:Axis3_DCompensate<=WRDATA;
                16'h0109:Axis3_QKp[31:16]<=WRDATA;
                16'h010A:Axis3_QKp[15:0]<=WRDATA;
                16'h010B:Axis3_QKi[31:16]<=WRDATA;
                16'h010C:Axis3_QKi[15:0]<=WRDATA;
                16'h010D:Axis3_QCompensate<=WRDATA;
                16'h010E:Axis3_LimitCircleRadius<=WRDATA;
                16'h010F:Axis3_DRef<=WRDATA;
                16'h0112:Axis3_QRef<=WRDATA;
                16'h0119:Axis3_LimitMode_HDLQ<=WRDATA[15]; 
                16'h0120:Axis3_SvpwmInputSel<=WRDATA[0];
                16'h0121:Axis3_UALPHA_selfdef<=WRDATA;
                16'h0122:Axis3_UBETA_selfdef<=WRDATA;                   

                16'h0184:Axis4_DKp[31:16]<=WRDATA;
                16'h0185:Axis4_DKp[15:0]<=WRDATA;
                16'h0186:Axis4_DKi[31:16]<=WRDATA;
                16'h0187:Axis4_DKi[15:0]<=WRDATA;
                16'h0188:Axis4_DCompensate<=WRDATA;
                16'h0189:Axis4_QKp[31:16]<=WRDATA;
                16'h018A:Axis4_QKp[15:0]<=WRDATA;
                16'h018B:Axis4_QKi[31:16]<=WRDATA;
                16'h018C:Axis4_QKi[15:0]<=WRDATA;
                16'h018D:Axis4_QCompensate<=WRDATA;
                16'h018E:Axis4_LimitCircleRadius<=WRDATA;
                16'h018F:Axis4_DRef<=WRDATA;
                16'h0192:Axis4_QRef<=WRDATA;
                16'h0199:Axis4_LimitMode_HDLQ<=WRDATA[15];   
                16'h01A0:Axis4_SvpwmInputSel<=WRDATA[0];
                16'h01A1:Axis4_UALPHA_selfdef<=WRDATA;
                16'h01A2:Axis4_UBETA_selfdef<=WRDATA; 
                endcase
            end
        end
    end 
    
    //regs Read===========================================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            RDDATA<=16'd0;
        end
        else begin
            if(RD==1'b1)begin
                case(ADDR) 
                16'h0000:RDDATA<=Axis1_IALPHA;
                16'h0001:RDDATA<=Axis1_IBETA;
                16'h0002:RDDATA<=Axis1_ID;
                16'h0003:RDDATA<=Axis1_IQ;
                16'h0004:RDDATA<=Axis1_DKp[31:16];
                16'h0005:RDDATA<=Axis1_DKp[15:0];
                16'h0006:RDDATA<=Axis1_DKi[31:16];
                16'h0007:RDDATA<=Axis1_DKi[15:0];
                16'h0008:RDDATA<=Axis1_DCompensate;
                16'h0009:RDDATA<=Axis1_QKp[31:16];
                16'h000A:RDDATA<=Axis1_QKp[15:0];
                16'h000B:RDDATA<=Axis1_QKi[31:16];
                16'h000C:RDDATA<=Axis1_QKi[15:0];
                16'h000D:RDDATA<=Axis1_QCompensate;
                16'h000E:RDDATA<=Axis1_LimitCircleRadius;
                16'h000F:RDDATA<=Axis1_DRef;
                16'h0010:RDDATA<=Axis1_DUiAcc_update[31:16];
                16'h0011:RDDATA<=Axis1_DUiAcc_update[15:0];
                16'h0012:RDDATA<=Axis1_QRef;
                16'h0013:RDDATA<=Axis1_QUiAcc_update[31:16];
                16'h0014:RDDATA<=Axis1_QUiAcc_update[15:0];
                16'h0015:RDDATA<=Axis1_UD;
                16'h0016:RDDATA<=Axis1_UQ;
                16'h0017:RDDATA<=Axis1_UALPHA;
                16'h0018:RDDATA<=Axis1_UBETA;
                16'h0019:RDDATA<=Axis1_CTRLREG;
                16'h0020:RDDATA<={15'd0,Axis1_SvpwmInputSel};
                16'h0021:RDDATA<=Axis1_UALPHA_selfdef;
                16'h0022:RDDATA<=Axis1_UBETA_selfdef; 
                
                16'h0080:RDDATA<=Axis2_IALPHA;
                16'h0081:RDDATA<=Axis2_IBETA;
                16'h0082:RDDATA<=Axis2_ID;
                16'h0083:RDDATA<=Axis2_IQ;
                16'h0084:RDDATA<=Axis2_DKp[31:16];
                16'h0085:RDDATA<=Axis2_DKp[15:0];
                16'h0086:RDDATA<=Axis2_DKi[31:16];
                16'h0087:RDDATA<=Axis2_DKi[15:0];
                16'h0088:RDDATA<=Axis2_DCompensate;
                16'h0089:RDDATA<=Axis2_QKp[31:16];
                16'h008A:RDDATA<=Axis2_QKp[15:0];
                16'h008B:RDDATA<=Axis2_QKi[31:16];
                16'h008C:RDDATA<=Axis2_QKi[15:0];
                16'h008D:RDDATA<=Axis2_QCompensate;
                16'h008E:RDDATA<=Axis2_LimitCircleRadius;
                16'h008F:RDDATA<=Axis2_DRef;
                16'h0090:RDDATA<=Axis2_DUiAcc_update[31:16];
                16'h0091:RDDATA<=Axis2_DUiAcc_update[15:0];
                16'h0092:RDDATA<=Axis2_QRef;
                16'h0093:RDDATA<=Axis2_QUiAcc_update[31:16];
                16'h0094:RDDATA<=Axis2_QUiAcc_update[15:0];
                16'h0095:RDDATA<=Axis2_UD;
                16'h0096:RDDATA<=Axis2_UQ;
                16'h0097:RDDATA<=Axis2_UALPHA;
                16'h0098:RDDATA<=Axis2_UBETA;
                16'h0099:RDDATA<=Axis2_CTRLREG; 
                16'h00A0:RDDATA<={15'd0,Axis2_SvpwmInputSel};
                16'h00A1:RDDATA<=Axis2_UALPHA_selfdef;
                16'h00A2:RDDATA<=Axis2_UBETA_selfdef;                 

                16'h0100:RDDATA<=Axis3_IALPHA;
                16'h0101:RDDATA<=Axis3_IBETA;
                16'h0102:RDDATA<=Axis3_ID;
                16'h0103:RDDATA<=Axis3_IQ;
                16'h0104:RDDATA<=Axis3_DKp[31:16];
                16'h0105:RDDATA<=Axis3_DKp[15:0];
                16'h0106:RDDATA<=Axis3_DKi[31:16];
                16'h0107:RDDATA<=Axis3_DKi[15:0];
                16'h0108:RDDATA<=Axis3_DCompensate;
                16'h0109:RDDATA<=Axis3_QKp[31:16];
                16'h010A:RDDATA<=Axis3_QKp[15:0];
                16'h010B:RDDATA<=Axis3_QKi[31:16];
                16'h010C:RDDATA<=Axis3_QKi[15:0];
                16'h010D:RDDATA<=Axis3_QCompensate;
                16'h010E:RDDATA<=Axis3_LimitCircleRadius;
                16'h010F:RDDATA<=Axis3_DRef;
                16'h0110:RDDATA<=Axis3_DUiAcc_update[31:16];
                16'h0111:RDDATA<=Axis3_DUiAcc_update[15:0];
                16'h0112:RDDATA<=Axis3_QRef;
                16'h0113:RDDATA<=Axis3_QUiAcc_update[31:16];
                16'h0114:RDDATA<=Axis3_QUiAcc_update[15:0];
                16'h0115:RDDATA<=Axis3_UD;
                16'h0116:RDDATA<=Axis3_UQ;
                16'h0117:RDDATA<=Axis3_UALPHA;
                16'h0118:RDDATA<=Axis3_UBETA;
                16'h0119:RDDATA<=Axis3_CTRLREG;  
                16'h0120:RDDATA<={15'd0,Axis3_SvpwmInputSel};
                16'h0121:RDDATA<=Axis3_UALPHA_selfdef;
                16'h0122:RDDATA<=Axis3_UBETA_selfdef;                 

                16'h0180:RDDATA<=Axis4_IALPHA;
                16'h0181:RDDATA<=Axis4_IBETA;
                16'h0182:RDDATA<=Axis4_ID;
                16'h0183:RDDATA<=Axis4_IQ;
                16'h0184:RDDATA<=Axis4_DKp[31:16];
                16'h0185:RDDATA<=Axis4_DKp[15:0];
                16'h0186:RDDATA<=Axis4_DKi[31:16];
                16'h0187:RDDATA<=Axis4_DKi[15:0];
                16'h0188:RDDATA<=Axis4_DCompensate;
                16'h0189:RDDATA<=Axis4_QKp[31:16];
                16'h018A:RDDATA<=Axis4_QKp[15:0];
                16'h018B:RDDATA<=Axis4_QKi[31:16];
                16'h018C:RDDATA<=Axis4_QKi[15:0];
                16'h018D:RDDATA<=Axis4_QCompensate;
                16'h018E:RDDATA<=Axis4_LimitCircleRadius;
                16'h018F:RDDATA<=Axis4_DRef;
                16'h0190:RDDATA<=Axis4_DUiAcc_update[31:16];
                16'h0191:RDDATA<=Axis4_DUiAcc_update[15:0];
                16'h0192:RDDATA<=Axis4_QRef;
                16'h0193:RDDATA<=Axis4_QUiAcc_update[31:16];
                16'h0194:RDDATA<=Axis4_QUiAcc_update[15:0];
                16'h0195:RDDATA<=Axis4_UD;
                16'h0196:RDDATA<=Axis4_UQ;
                16'h0197:RDDATA<=Axis4_UALPHA;
                16'h0198:RDDATA<=Axis4_UBETA;
                16'h0199:RDDATA<=Axis4_CTRLREG; 
                16'h01A0:RDDATA<={15'd0,Axis4_SvpwmInputSel};
                16'h01A1:RDDATA<=Axis4_UALPHA_selfdef;
                16'h01A2:RDDATA<=Axis4_UBETA_selfdef;                 
           
                default:RDDATA<=16'd0;
                endcase
            end
        end
    end 
    
    

    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            Axis1_DUiAcc_update<=32'd0;
            Axis1_QUiAcc_update<=32'd0;
            Axis2_DUiAcc_update<=32'd0;
            Axis2_QUiAcc_update<=32'd0;
            Axis3_DUiAcc_update<=32'd0;
            Axis3_QUiAcc_update<=32'd0;
            Axis4_DUiAcc_update<=32'd0;
            Axis4_QUiAcc_update<=32'd0;            
        end
        else begin
            if((Axises_CalEN[0]==1'b1)&&(Axis1_SvpwmInputSel==1'b0))begin
                if(Axises_CurrentCtrlFinsih[0]==1'b1)begin
                    Axis1_DUiAcc_update<=DUiAcc_Active;
                    Axis1_QUiAcc_update<=QUiAcc_Active;
                end
            end
            else begin
                Axis1_DUiAcc_update<=32'd0;
                Axis1_QUiAcc_update<=32'd0;
            end
            
            if((Axises_CalEN[1]==1'b1)&&(Axis2_SvpwmInputSel==1'b0))begin
                if(Axises_CurrentCtrlFinsih[1]==1'b1)begin
                    Axis2_DUiAcc_update<=DUiAcc_Active;
                    Axis2_QUiAcc_update<=QUiAcc_Active;
                end
            end
            else begin
                Axis2_DUiAcc_update<=32'd0;
                Axis2_QUiAcc_update<=32'd0;
            end

            if((Axises_CalEN[2]==1'b1)&&(Axis3_SvpwmInputSel==1'b0))begin
                if(Axises_CurrentCtrlFinsih[2]==1'b1)begin
                    Axis3_DUiAcc_update<=DUiAcc_Active;
                    Axis3_QUiAcc_update<=QUiAcc_Active;
                end
            end
            else begin
                Axis3_DUiAcc_update<=32'd0;
                Axis3_QUiAcc_update<=32'd0;
            end

            if((Axises_CalEN[3]==1'b1)&&(Axis4_SvpwmInputSel==1'b0))begin
                if(Axises_CurrentCtrlFinsih[3]==1'b1)begin
                    Axis4_DUiAcc_update<=DUiAcc_Active;
                    Axis4_QUiAcc_update<=QUiAcc_Active;
                end
            end
            else begin
                Axis4_DUiAcc_update<=32'd0;
                Axis4_QUiAcc_update<=32'd0;
            end               
        end
    end
    
endmodule
