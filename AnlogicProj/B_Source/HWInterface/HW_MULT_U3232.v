/*
HW_MULT_U3232 HW_MULT_U3232_inst(
    .MultA(),
    .MultB(),
    .Result()
    );
*/
module HW_MULT_U3232(         
    input       [31:0]  MultA,
    input       [31:0]  MultB,
    output      [63:0]  Result
);
    //Hardware Multiplier
    assign Result = MultA * MultB;

endmodule
