module FA(
	output S,Cout,
	input A,B,Cin 
);
	
	assign S = A ^ B ^ Cin;
	assign Cout = ((A^B) & Cin) | (A & B);
endmodule