// PWM modules

/*
 * Generate a PWM square wave tuned to note frequency
 */
module pwm_generator (
    input logic clk,
    input logic [15:0] pwm_interval,
    output logic pwm_out
);
    logic [15:0] pwm_count = 16'd0;
    logic wave;

    // Implement counter for timing transition in PWM output signal
    always_ff @(posedge clk) begin
        if (pwm_count == pwm_interval - 1) begin
            pwm_count <= 0;
            wave = ~wave;
        end
        else begin
            pwm_count <= pwm_count + 1;
        end
    end

    // Generate PWM output signal
    assign pwm_out = wave;

endmodule


/*
 * Decode note to note frequency
 */
module pwm_decoder (
    input logic clk,
    input logic [2:0] note,
    output logic [15:0] pwm_interval
);

    localparam [2:0] NOTE_C4 = 3'b000;
    localparam [2:0] NOTE_D4 = 3'b001;
    localparam [2:0] NOTE_E4 = 3'b011;
    localparam [2:0] NOTE_F4 = 3'b100;
    localparam [2:0] NOTE_G4 = 3'b110;
    localparam [2:0] NOTE_A4 = 3'b101;
    localparam [2:0] NOTE_B4 = 3'b010;
    localparam [2:0] NOTE_C5 = 3'b111;

    logic [15:0] interval;

    // set interval frequency based on note
    always_comb begin
        case (note)
            NOTE_C4: pwm_interval = 16'd22940;
            NOTE_D4: pwm_interval = 16'd20434;
            NOTE_E4: pwm_interval = 16'd18204;
            NOTE_F4: pwm_interval = 16'd17190;
            NOTE_G4: pwm_interval = 16'd15306;
            NOTE_A4: pwm_interval = 16'd13636;
            NOTE_B4: pwm_interval = 16'd12148;
            NOTE_C5: pwm_interval = 16'd11471;
            default: pwm_interval = 16'd5000;
        endcase
    end

    // assign pwm_interval = interval;

endmodule