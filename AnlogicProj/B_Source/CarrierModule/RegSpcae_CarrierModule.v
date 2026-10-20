module RegSpcae_CarrierModule(
    input                       clk,
    input                       rst,
    //data & addr bus
    input                       CS,
    input                       RDLWRH,
    input               [15:0]  ADDR,
    input               [15:0]  WRDATA,
    output  reg         [15:0]  RDDATA,
    
    //inner reg interface
    output  reg                 Axis1_Bootstrap,
    output  reg                 Axis1_PWMEN,
    input                       Axis1_PWMUNLOCK,
    output  reg                 Axis2_Bootstrap,
    output  reg                 Axis2_PWMEN,
    input                       Axis2_PWMUNLOCK,
    output  reg                 Axis3_Bootstrap,
    output  reg                 Axis3_PWMEN,
    input                       Axis3_PWMUNLOCK,
    output  reg                 Axis4_Bootstrap,
    output  reg                 Axis4_PWMEN,
    input                       Axis4_PWMUNLOCK
    );
    
    wire            RD;
    wire            WR;
    assign  RD = CS&&(RDLWRH==1'b0);
    assign  WR = CS&&(RDLWRH==1'b1);
    
    wire    [15:0]  Axis1_PWMCTRLREG;
    assign Axis1_PWMCTRLREG = {Axis1_PWMUNLOCK,13'd0,Axis1_PWMEN,Axis1_Bootstrap};
    wire    [15:0]  Axis2_PWMCTRLREG;
    assign Axis2_PWMCTRLREG = {Axis2_PWMUNLOCK,13'd0,Axis2_PWMEN,Axis2_Bootstrap};
    wire    [15:0]  Axis3_PWMCTRLREG;
    assign Axis3_PWMCTRLREG = {Axis3_PWMUNLOCK,13'd0,Axis3_PWMEN,Axis3_Bootstrap};
    wire    [15:0]  Axis4_PWMCTRLREG;
    assign Axis4_PWMCTRLREG = {Axis4_PWMUNLOCK,13'd0,Axis4_PWMEN,Axis4_Bootstrap};    
    
    //regs Write===========================================================
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            Axis1_Bootstrap<=1'b0;
            Axis1_PWMEN<=1'b0;
        end
        else begin
            if(Axis1_PWMUNLOCK==1'b0)begin
                Axis1_Bootstrap<=1'b0;
                Axis1_PWMEN<=1'b0;
            end
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0000:begin
                    Axis1_Bootstrap<=WRDATA[0];
                    Axis1_PWMEN<=WRDATA[1];
                end
                endcase
            end
        end
    end
    
    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            Axis2_Bootstrap<=1'b0;
            Axis2_PWMEN<=1'b0;
        end
        else begin
            if(Axis2_PWMUNLOCK==1'b0)begin
                Axis2_Bootstrap<=1'b0;
                Axis2_PWMEN<=1'b0;
            end
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0010:begin
                    Axis2_Bootstrap<=WRDATA[0];
                    Axis2_PWMEN<=WRDATA[1];
                end
                endcase
            end
        end
    end

    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            Axis3_Bootstrap<=1'b0;
            Axis3_PWMEN<=1'b0;
        end
        else begin
            if(Axis3_PWMUNLOCK==1'b0)begin
                Axis3_Bootstrap<=1'b0;
                Axis3_PWMEN<=1'b0;
            end
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0020:begin
                    Axis3_Bootstrap<=WRDATA[0];
                    Axis3_PWMEN<=WRDATA[1];
                end
                endcase
            end
        end
    end 

    always @ (posedge clk or negedge rst)
    begin
        if(!rst)begin
            Axis4_Bootstrap<=1'b0;
            Axis4_PWMEN<=1'b0;
        end
        else begin
            if(Axis4_PWMUNLOCK==1'b0)begin
                Axis4_Bootstrap<=1'b0;
                Axis4_PWMEN<=1'b0;
            end
            if(WR==1'b1)begin
                case(ADDR) 
                16'h0030:begin
                    Axis4_Bootstrap<=WRDATA[0];
                    Axis4_PWMEN<=WRDATA[1];
                end
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
                16'h0000:RDDATA<=Axis1_PWMCTRLREG;
                16'h0010:RDDATA<=Axis2_PWMCTRLREG;
                16'h0020:RDDATA<=Axis3_PWMCTRLREG;
                16'h0030:RDDATA<=Axis4_PWMCTRLREG;
                default:RDDATA<=16'd0;
                endcase
            end
        end
    end 
endmodule
