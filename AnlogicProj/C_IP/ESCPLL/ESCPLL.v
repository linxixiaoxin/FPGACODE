
module ESCPLL (
	areset,
	inclk0,
	c0,
	c1,
	c2);

	input	  areset;
	input	  inclk0;
	output	  c0;
	output	  c1;
	output	  c2;

AnlogicPLL AnlogicPLL(
    .refclk(inclk0),
    .reset(areset),
    .clk0_out(c0),
    .clk1_out(c1),
    .clk2_out(c2) 
    );

endmodule


