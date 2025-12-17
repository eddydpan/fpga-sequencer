`include "pwm.sv"

module audio_controller #(
    parameter CLK_FREQ = 12_000_000,
    parameter NUM_BEATS = 16,
    parameter PERIOD = 4
)(
    input logic clk,
    input logic[NUM_BEATS*4-1:0] beats, // TODO: dynamic buffer size based on NUM_BEATS
    output logic [$clog2(NUM_BEATS)-1:0] beat_count,
    output logic pwm_out,
);

    initial begin
        beat_count = 0;
    end
    
    localparam beat_clock_interval = PERIOD * (CLK_FREQ / NUM_BEATS);
    logic [31:0] clk_counter = 0;  // Counter for clock cycles
    logic [3:0] pitch;
    logic [15:0] pwm_interval;

    pwm_decoder u_pwm_decoder (
        .clk(clk),
        .note(pitch),
        .pwm_interval(pwm_interval)
    );

    pwm_generator u_pwm_generator(
        .clk(clk),
        .pwm_interval(pwm_interval),
        .pwm_out(pwm_out)
    );
    
    always @(posedge clk) begin
        // Increment clock counter
        clk_counter <= clk_counter + 1;
        
        // When counter reaches beat_clock_interval, move to next beat
        if (clk_counter >= beat_clock_interval - 1) begin
            clk_counter <= 0;
            
            // Increment beat_count and wrap at NUM_BEATS
            if (beat_count == NUM_BEATS - 1) begin
                beat_count <= 0;
            end else begin
                beat_count <= beat_count + 1;
            end
        end

        // Extract pitch for current beat from beats register
        pitch <= beats[beat_count*4 +: 4];
    end




endmodule