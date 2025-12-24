// ReactionGame.v
// Top-level for Reaction Time Game
// reset (active HIGH) freezes game and resets score

module ReactionGame(
    input        CLOCK_50,   // 50 MHz
    input        reset,      // physical reset switch (active HIGH -> freeze & clear)
    input  [1:0] KEY,        // push buttons (active-LOW)
    output [9:0] LEDR,       // LEDs
    output [6:0] HEX0,       // ones
    output [6:0] HEX1        // tens
);

    // run_enable true when reset switch is LOW
    wire run_enable = ~reset;

    // ---------------- button sync + edge detect ----------------
    reg [1:0] key_s1, key_s2, key_prev;
    always @(posedge CLOCK_50) begin
        if (!run_enable) begin
            key_s1   <= 2'b00;
            key_s2   <= 2'b00;
            key_prev <= 2'b00;
        end else begin
            key_s1   <= ~KEY;      // convert active-LOW to active-HIGH (1=pressed)
            key_s2   <= key_s1;
            key_prev <= key_s2;
        end
    end
    wire [1:0] key_edge = key_s2 & ~key_prev; // single-cycle press events
    wire any_key_edge = |key_edge;
    wire [1:0] key_state = key_s2; // stable pressed state

    // ---------------- random generator ----------------
    wire [31:0] rnd;
    RandomGen rng (
        .clk(CLOCK_50),
        .reset_n(run_enable), // pass run_enable as reset_n
        .rnd_out(rnd)
    );

    // ---------------- game controller ----------------
    wire [7:0] score;
    wire [1:0] led_out;          // steady-state LED values driven by controller (0/1)
    wire [1:0] led_flashing_out; // visible LED (flashing) output
	 assign LEDR[9:2] = 8'b0;             // all other LEDs off
    GameController ctrl (
        .clk(CLOCK_50),
        .run_enable(run_enable),
        .rnd(rnd),
        .key_edge(key_edge),
        .key_state(key_state),
        .score(score),
        .led_out(led_out),
        .led_flashing_out(led_flashing_out)
    );

    // Final LEDR output: controller drives LEDR (flashing applied inside controller)
    assign LEDR = run_enable ? led_flashing_out : 2'b00;

    // ---------------- score -> BCD -> 7-seg ----------------
    wire [3:0] tens, ones;
    bin2bcd b2b(.bin(score), .tens(tens), .ones(ones));
    lab2 seg0(.x(ones), .seg(HEX0));
    lab2 seg1(.x(tens), .seg(HEX1));

endmodule
