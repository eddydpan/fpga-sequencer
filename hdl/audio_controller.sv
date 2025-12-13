module audio_controller #(
    parameter NUM_BEATS = 16
)(
    input logic clk,
    input logic[48:0] beats, // TODO: dynamic buffer size based on NUM_BEATS
    output logic [$clog2(NUM_BEATS)-1:0] beat_count,
    output logic pwm_out
);
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
        if (beat_count == NUM_BEATS - 1) begin
            beat_count <= 0;
        end else begin
            beat_count <= beat_count + 1;
        end

        pitch <= beats[beat_count*3 +: 3];

    end




endmodule