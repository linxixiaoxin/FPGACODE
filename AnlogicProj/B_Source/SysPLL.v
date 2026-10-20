module SysPLL (
    input               clk, 
    input               reset, 
    output  reg         reset_sync,
    output              Clk_50Mhz,
    output              Clk_100Mhz,
    output              Clk_20Mhz,
    input               SysResetSig
    );

    reg     [5:0]   reset_init = 6'b00_0000;
    wire            init = reset_init[5];
    always@(posedge clk or negedge reset)begin
        if(~reset) 
            reset_init<=6'd0;
        else
        begin
            if(!init)
                reset_init <= reset_init + 1'b1;
        end
    end
    ESCPLL ESCPLL_inst (
    .areset ( !init ),
    .inclk0 ( clk ),
    .c0 ( Clk_50Mhz ),
    .c1 ( Clk_100Mhz),
    .c2 ( Clk_20Mhz )
    ); 

    reg             reset_sync1;
    reg             reset_sync2;
    always @(posedge Clk_50Mhz or negedge reset) begin
    if(!reset) begin
    reset_sync1 <= 0;
    reset_sync2 <= 0;
    end
    else begin
    reset_sync1 <= 1;
    reset_sync2 <= reset_sync1;
    end
    end
    
    reg             SysResetSig_sync1;
    reg             SysResetSig_sync2;
    always @(posedge Clk_50Mhz or negedge reset) begin
        if(!reset) begin
        SysResetSig_sync1 <= 0;
        SysResetSig_sync2 <= 0;
        end
        else begin
        SysResetSig_sync1 <= SysResetSig;
        SysResetSig_sync2 <= SysResetSig_sync1;
        end
    end
    
    reg [7:0]   Counter;
    reg         CounterEN;
    localparam Counter_SET = 8'd200;
    localparam Counter_Reset = 8'd100;
    always @(posedge Clk_50Mhz or negedge reset) begin
        if(!reset) begin
            Counter <= 8'd0;
            CounterEN<=1'b1;
        end
        else begin
            if(SysResetSig_sync2==1'b1)
                CounterEN<=1'b1;
            else begin
                if(Counter==Counter_SET)
                    CounterEN<=1'b0;
            end
            
            if(CounterEN)begin
                if(Counter<Counter_SET)
                    Counter<=Counter+1'b1;
                else
                    Counter<=Counter_SET;
            end
            else
                Counter <= 8'd0;
        end
    end
    
    
    

    always @(posedge Clk_50Mhz or negedge reset_sync2) begin
        if(!reset_sync2)
        reset_sync <= 0;
        else begin
            if(Counter)
                reset_sync <= 0;
            else begin
                if(Counter>=Counter_Reset)
                    reset_sync <= 0;
                else
                    reset_sync <= reset;
            end
        end
    end


    endmodule
