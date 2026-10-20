/*
HW_MULT_S1616 HW_MULT_S1616_inst(
    .MultA(),
    .MultB(),
    .Result()
    );
*/
module HW_MULT_S1616 (         
    input   signed  [15:0]  MultA,
    input   signed  [15:0]  MultB,
    output  signed  [31:0]  Result
);
    //Hardware Multiplier
    assign Result = MultA * MultB;

endmodule
