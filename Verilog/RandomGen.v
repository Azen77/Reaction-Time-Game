// RandomGen.v
// 32-bit LFSR random generator
module RandomGen (
    input        clk,
    input        reset_n,   // active-low reset; pass run_enable
    output reg [31:0] rnd_out
);
    reg [31:0] lfsr;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            lfsr <= 32'hA5A5_A5A5; // seed
            rnd_out <= 32'hA5A5_A5A5;
        end else begin
            // taps: 32,22,2,1 (example primitive poly)
            lfsr <= { lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0] };
            rnd_out <= lfsr;
        end
    end
endmodule
