module lab2 (
input wire [3:0] x,
output wire [6:0] seg
);


	wire x3 = x[3];
	wire x2 = x[2];
	wire x1 = x[1];
	wire x0 = x[0];

	wire a_on = (x1 & x2) | (x1 & ~x3) | (x3 & ~x0) | (~x0 & ~x2) | (x0 & x2 & ~x3) | (x3 & ~x1 & ~x2);
	wire b_on = (~x0 & ~x2) | (~x2 & ~x3) | (x0 & x1 & ~x3) | (x0 & x3 & ~x1) | (~x0 & ~x1 & ~x3);
	wire c_on = (x0 & ~x1) | (x0 & ~x3) | (x2 & ~x3) | (x3 & ~x2) | (~x1 & ~x3);
	wire d_on = (x3 & ~x1) | (x0 & x1 & ~x2) | (x0 & x2 & ~x1) | (x1 & x2 & ~x0) | (~x0 & ~x2 & ~x3);
	
	/*
		e reduction
		e_on = (x1 & x3) | (x2 & x3) | (x1 & ~x0) | (~x0 & ~x2)
		postulate 4, distributive law. factor x3 from left half then factor ~x0 from right half
		e_on = (x3 & (x1 | x2)) | (~x0 & (x1 | ~x2))
	*/
	
	wire e_on = (x3 & (x1 | x2)) | (~x0 & (x1 | ~x2));
	wire f_on = (x1 & x3) | (x2 & ~x0) | (x3 & ~x2) | (~x0 & ~x1) | (x2 & ~x1 & ~x3);
	wire g_on = (x0 & x3) | (x1 & ~x0) | (x1 & ~x2) | (x3 & ~x2) | (x2 & ~x1 & ~x3);

	assign seg[6] = ~g_on;
	assign seg[5] = ~f_on;
	assign seg[4] = ~e_on;
	assign seg[3] = ~d_on;
	assign seg[2] = ~c_on;
	assign seg[1] = ~b_on;
	assign seg[0] = ~a_on;


endmodule