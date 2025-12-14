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
        if (pwm_interval == 16'd0) begin
            pwm_count <= 16'd0;
            wave <= 1'b0;
        end
        else if ((pwm_count == pwm_interval - 1)) begin
            pwm_count <= 0;
            wave <= ~wave;
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
    input logic [3:0] note,
    output logic [15:0] pwm_interval
);
    localparam [3:0] NOTE_REST = 4'b0000;
    localparam [3:0] NOTE_C4 = 4'b0001;
    localparam [3:0] NOTE_D4 = 4'b0010;
    localparam [3:0] NOTE_E4 = 4'b0011;
    localparam [3:0] NOTE_F4 = 4'b0100;
    localparam [3:0] NOTE_G4 = 4'b0101;
    localparam [3:0] NOTE_A4 = 4'b0110;
    localparam [3:0] NOTE_B4 = 4'b0111;
    localparam [3:0] NOTE_C5 = 4'b1000;


    logic [15:0] interval;

    // set interval frequency based on note
    always_comb begin
        case (note)
            NOTE_REST: pwm_interval = 16'd0;
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

endmodule