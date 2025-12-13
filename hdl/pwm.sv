// PWM modules

/*
 * Generate a PWM square wave tuned to note frequency
 */
module pwm_generator (
    input logic clk,
    input int pwm_interval,
    output logic pwm_out
);
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
    output int pwm_interval
);

    localparam [2:0] NOTE_C4 = 3'b000;
    localparam [2:0] NOTE_D4 = 3'b001;
    localparam [2:0] NOTE_E4 = 3'b011;
    localparam [2:0] NOTE_F4 = 3'b100;
    localparam [2:0] NOTE_G4 = 3'b110;
    localparam [2:0] NOTE_A4 = 3'b101;
    localparam [2:0] NOTE_B4 = 3'b010;
    localparam [2:0] NOTE_C5 = 3'b111;

    // set interval frequency based on note
    always_comb begin
        int interval;
        case (note)
            NOTE_C4:
                interval = 22940;
            NOTE_D4:
                interval = 20434;
            NOTE_E4:
                interval = 18204;
            NOTE_F4:
                interval = 17190;
            NOTE_G4:
                interval = 15306;
            NOTE_A4:
                interval = 13636;
            NOTE_B4:
                interval = 12148;
            NOTE_C5:
                interval = 11471;
            default:
                interval = 5000;
        endcase
    end

    assign pwm_interval = interval;

endmodule