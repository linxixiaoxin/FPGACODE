module Slave100MHz_TopologyManage(
    input                   clk,
    input                   rst,
    //processed sigs
    input                   TXEN,
    input                   TXD,
    //Port0
    input                   RXDV0,
    input                   RXD0,
    output  reg             TXEN0,
    output  reg             TXD0,
    input                   Linkstate0,
    //Port1
    input                   RXDV1,
    input                   RXD1,
    output  reg             TXEN1,
    output  reg             TXD1,
    input                   Linkstate1
);

    
    
    always @ (posedge clk or negedge rst)begin
        if(!rst)begin
            TXEN0<=1'b0;
            TXD0<=1'b0;
            TXEN1<=1'b0;
            TXD1<=1'b0;            
        end
        else begin
            case({Linkstate0,Linkstate1})
            2'b00:begin
                TXEN0<=1'b0;
                TXD0<=1'b0;
                TXEN1<=1'b0;
                TXD1<=1'b0; 
            end
            2'b10:begin
                TXEN0<=TXEN;
                TXD0<=TXD;
                TXEN1<=1'b0;
                TXD1<=1'b0; 
            end
            2'b11:begin
                TXEN0<=RXDV1;
                TXD0<=RXD1;
                TXEN1<=TXEN;
                TXD1<=TXD; 
            end
            2'b01:begin
                TXEN0<=1'b0;
                TXD0<=1'b0;
                TXEN1<=RXDV1;
                TXD1<=RXD1; 
            end
            endcase
        end
    end

    
endmodule
