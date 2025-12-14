`include "pwm.sv"

module audio_controller #(
    parameter NUM_BEATS = 16
)(
    input logic clk,
    input logic[NUM_BEATS*4-1:0] beats, // TODO: dynamic buffer size based on NUM_BEATS
    output logic [$clog2(NUM_BEATS)-1:0] beat_count,
    output logic pwm_out 
);

    initial begin
        beat_count = 0;
    end
    
    localparam [31:0] beat_clock_interval = 12_000_000 / NUM_BEATS;
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
        // Clock divider based off beats
        if (clk % (beat_clock_interval) == 0) begin
            beat_count <= beat_count + 1;
        end
        // if (beat_count == NUM_BEATS - 1) begin
        //     beat_count <= 0;
        // end else begin
        //     beat_count <= beat_count + 1;
        // end

        pitch <= beats[beat_count*4 +: 4];

    end




endmodule