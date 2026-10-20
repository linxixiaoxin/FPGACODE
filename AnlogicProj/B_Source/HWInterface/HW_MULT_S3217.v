/*
HW_MULT_S3217 HW_MULT_S3217_inst(
    .MultA(),
    .MultB(),
    .Result()
    );
*/
module HW_MULT_S3217 (         
    input   signed  [31:0]  MultA,
    input   signed  [16:0]  MultB,
    output  signed  [48:0]  Result
);
    //Hardware Multiplier
    assign Result = MultA * MultB;

endmodule
