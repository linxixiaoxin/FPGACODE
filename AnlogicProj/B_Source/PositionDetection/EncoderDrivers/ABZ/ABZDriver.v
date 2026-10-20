module ABZDriver(
    input                   clk,
    input                   rst,
    
    input                   PluseA,
    input                   PluseB,
    input                   PluseZ,
    
    output  reg     [31:0]  PluseCounter
    );
    
    reg             PluseA_dly1;
    reg             PluseB_dly1;
    reg             PluseZ_dly1;
    reg             PluseA_Sync;
    reg             PluseB_Sync;
    reg             PluseZ_Sync;
    reg             PluseA_SyncDly;
    reg             PluseB_SyncDly;
    reg             PluseZ_SyncDly;
    wire            PluseA_Redge;
    wire            PluseA_Nedge;
    wire            PluseB_Redge;
    wire            PluseB_Nedge;
    wire            PluseZ_Redge;
    
    wire            CountPluse;
    reg             CountPluse_Act;
    
    wire    [1:0]   PluseState;
    reg     [1:0]   PluseState_Last;
    
    reg     [1:0]   CountDir;//CountDir[1]:EN, CountDir[0]:DIR
    
    reg     [15:0]  Zcount;
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            PluseA_dly1<=1'b0;
            PluseB_dly1<=1'b0;
            PluseZ_dly1<=1'b0;
            PluseA_Sync<=1'b0;
            PluseB_Sync<=1'b0;
            PluseZ_Sync<=1'b0;
            PluseA_SyncDly<=1'b0;
            PluseB_SyncDly<=1'b0;
            PluseZ_SyncDly<=1'b0;           
        end
        else begin
            PluseA_dly1<=PluseA;
            PluseB_dly1<=PluseB;
            PluseZ_dly1<=PluseZ;
            PluseA_Sync<=PluseA_dly1;
            PluseB_Sync<=PluseB_dly1;
            PluseZ_Sync<=PluseZ_dly1;
            PluseA_SyncDly<=PluseA_Sync;
            PluseB_SyncDly<=PluseB_Sync;
            PluseZ_SyncDly<=PluseZ_Sync;                
        end
    end
    
    assign PluseA_Redge = PluseA_Sync && (!PluseA_SyncDly);
    assign PluseA_Nedge = (!PluseA_Sync) && PluseA_SyncDly;
    assign PluseB_Redge = PluseB_Sync && (!PluseB_SyncDly);
    assign PluseB_Nedge = (!PluseB_Sync) && PluseB_SyncDly;
    assign PluseZ_Redge = PluseZ_Sync && (!PluseZ_SyncDly);
    
    assign CountPluse = PluseA_Redge||PluseA_Nedge||PluseB_Redge||PluseB_Nedge;
    
    
    assign PluseState = {PluseA_Sync,PluseB_Sync};
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            PluseState_Last<=2'b00;
        end
        else begin
            if(CountPluse)
                PluseState_Last<=PluseState;
        end
    end
    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CountDir<=2'b10;
        end
        else begin
            if(CountPluse)begin
                case(PluseState)
                2'b10:begin
                    case(PluseState_Last)
                    2'b11:CountDir<=2'b00;
                    2'b00:CountDir<=2'b01;
                    default:CountDir<=2'b10;
                    endcase
                end
                2'b11:begin
                    case(PluseState_Last)
                    2'b10:CountDir<=2'b01;
                    2'b01:CountDir<=2'b00;
                    default:CountDir<=2'b10;
                    endcase
                end
                2'b01:begin
                    case(PluseState_Last)
                    2'b11:CountDir<=2'b01;
                    2'b00:CountDir<=2'b00;
                    default:CountDir<=2'b10;
                    endcase
                end
                2'b00:begin
                    case(PluseState_Last)
                    2'b10:CountDir<=2'b00;
                    2'b01:CountDir<=2'b01;
                    default:CountDir<=2'b10;
                    endcase
                end
                endcase
            end
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            CountPluse_Act<=1'b0;
        end
        else begin
            CountPluse_Act<=CountPluse;
        end
    end
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            PluseCounter<=32'h7FFFFFFF;
        end
        else begin
            if(PluseZ_Redge)
                PluseCounter<=32'h00000000;
            else begin
                if(CountPluse_Act)begin
                    if(CountDir[1]==1'b0)begin
                        if(CountDir[0]==1'b1)//inc
                            PluseCounter<=PluseCounter+1'b1;
                        else//dec
                            PluseCounter<=PluseCounter-1'b1;
                    end
                    else
                        PluseCounter<=PluseCounter;
                end
            end
        end
    end
    

    
    
    
endmodule