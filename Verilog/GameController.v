module GameController(
    input clk,
    input run_enable,
    input [31:0] rnd,
    input [1:0] key_edge,
    input [1:0] key_state,
    output reg [7:0] score,
    output reg [1:0] led_out,
    output reg [1:0] led_flashing_out
);

    // States
    localparam S_IDLE    = 3'd0;
    localparam S_PREPARE = 3'd1;
    localparam S_ACTIVE  = 3'd2;
    localparam S_RESULT  = 3'd3;

    reg [2:0] state;
    reg [31:0] main_counter;
    reg [31:0] active_target;
    reg [31:0] off_target;
    reg [22:0] flash_ctr;
    reg flash_state;
    reg [1:0] chosen_led;
	 reg [1:0] idle_off_select;

    wire any_key_edge = |key_edge;
	 
	 localparam MIN_ACTIVE = 32'd15000000;  // 0.3s
	 localparam MAX_ACTIVE = 32'd75000000; // 1.5s
	 
	 localparam OFF_0 = 32'd12500000;    // 0.25s
  	 localparam OFF_1 = 32'd25000000;    // 0.50s
	 localparam OFF_2 = 32'd50000000;    // 1.00s
	 localparam OFF_3 = 32'd75000000;    // 1.50s


    // compute active_target (combinational)
    always @(*) begin
        active_target = (score >= 33) ? MIN_ACTIVE : MIN_ACTIVE + ((MAX_ACTIVE - MIN_ACTIVE) * (99 - score) / 99);
 
		  case (rnd[1:0])
			  2'b00: off_target = OFF_0;
			  2'b01: off_target = OFF_1;
			  2'b10: off_target = OFF_2;
			  2'b11: off_target = OFF_3;
		 endcase
    end

    always @(posedge clk) begin
        if (!run_enable) begin
            state <= S_IDLE;
            score <= 8'd0;
            led_out <= 2'b00;
            led_flashing_out <= 2'b00;
            main_counter <= 32'd0;
            flash_ctr <= 23'd0;
            flash_state <= 1'b0;
            chosen_led <= 2'b00;
        end 
		  else begin
            case(state)
                  
						S_IDLE: begin
							 led_out <= 2'b00;
							 led_flashing_out <= 2'b00;
							 main_counter <= main_counter + 1;

							 // Sample rnd[1:0] once when entering S_IDLE or just before counting
							 if (main_counter == 0) begin
								  idle_off_select <= rnd[1:0];
							 end

							 // Compare with the fixed off_target based on sampled value
							 case (idle_off_select)
								  2'b00: off_target = OFF_0;
								  2'b01: off_target = OFF_1;
								  2'b10: off_target = OFF_2;
								  2'b11: off_target = OFF_3;
							 endcase

							 if (main_counter >= off_target) begin
								  chosen_led <= rnd[0] ? 2'b10 : 2'b01;
								  main_counter <= active_target;
								  state <= S_ACTIVE;
							 end
						end


                S_ACTIVE: begin
                    led_out <= chosen_led;
                    led_flashing_out <= chosen_led;

                    // correct press
                    if ((chosen_led==2'b01 && key_edge[0]) || (chosen_led==2'b10 && key_edge[1])) begin
                        if (score < 99) score <= score + 1;
                        main_counter <= 0;
                        state <= S_RESULT;
                    end
                    // wrong press
                    else if (any_key_edge) begin
                        if (score > 0) score <= score - 1;
                        main_counter <= 0;
                        state <= S_RESULT;
                    end
                    // timeout
                    else if (main_counter == 0) begin
                        if (score > 0) score <= score - 1;
                        state <= S_RESULT;
                    end else begin
                        main_counter <= main_counter - 1;
                    end
                end

                S_RESULT: begin
                    led_out <= 2'b00;
                    led_flashing_out <= 2'b00;
                    main_counter <= 0;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
