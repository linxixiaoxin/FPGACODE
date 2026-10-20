/*
HW_MULT_U1616 HW_MULT_U1616_inst(
    .MultA(),
    .MultB(),
    .Result()
    );
*/
module HW_MULT_U1616(         
    input       [15:0]  MultA,
    input       [15:0]  MultB,
    output      [31:0]  Result
);
    //Hardware Multiplier
    assign Result = MultA * MultB;

endmodule
