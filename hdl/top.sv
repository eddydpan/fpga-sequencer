`include "model.sv"
`include "button_matrix_controller.sv"
`include "audio_controller.sv"
`include "rotary_encoder.sv"

module top(
    input logic clk,
    input logic _39a, 
    input logic _38b, 
    input logic _41a, 
    input logic _42b, // button col inputs
    output logic _36b, 
    output logic _37a, 
    output logic _29b, 
    output logic _31b, // row pin outputs for matrix scanning
    output logic _44b, // audio output pin
    input logic _45a, // rotary encoder button
    input logic _3b, // rotary encoder output B
    input logic _5a, // rotary encoder output A
    output logic LED,
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);
    localparam NUM_BEATS = 16;
    localparam BEATS_BUFFER = $clog2(NUM_BEATS);
    localparam CLK_FREQ = 12_000_000; // 12 MHz
    // Instantiate model
    logic[7:0] data_in;
    logic[NUM_BEATS*4-1:0] beats; // 64 bit register: 16 beats x 4 bits each (pitch)
    logic[BEATS_BUFFER-1:0] beat_count; // 4 bits for 16 beats
    logic [$clog2(CLK_FREQ)-1:0] clk_count = 0;

    logic [2:0] rotary_position;
    logic re_button_pressed;

    model #(
        .NUM_BEATS(NUM_BEATS)
    ) u_model (
        .clk(clk),
        .data_in(data_in),
        .beats(beats)
    );
    
    logic[3:0] button_index; // 4 bits for 16 buttons
    logic button_pressed;
    
    button_matrix_controller u_button_matrix_controller (
        .clk(clk),
        .col_inputs({_42b, _41a, _38b, _39a}),
        .row_outputs({_31b, _29b, _37a, _36b}),
        .button_index(button_index),
        .button_pressed(button_pressed)
    );

    rotary_encoder u_rotary_encoder(
        .clk(clk),
        .button(_45a),
        .signal_a(_5a),
        .signal_b(_3b),
        .button_pressed(re_button_pressed),
        .rotary_position(rotary_position)
    );

    audio_controller #(
        .NUM_BEATS(NUM_BEATS)
    ) u_audio_controller(
        .clk(clk),
        .beats(beats),
        .beat_count(beat_count),
        .pwm_out(_44b)
    );
    
    always_ff @(posedge clk) begin
        // Increment seconds counter
        if (clk_count == CLK_FREQ - 1) begin
            seconds <= seconds + 1;
            clk_count <= 0;
        end else begin
            clk_count <= clk_count + 1;
        end

        if (button_pressed) begin
            // Concatenate rotary encoder position and button index to form data_in
            // data_in is {4 bits of pitch, 4 bits of beat index}
            data_in <= {rotary_position, button_index}; // TODO: map pitch bits w/ rotary encoder #3
        end

    end
    // Hardware debugger: Map button_index bits directly to LEDs
    // This will help debug what values are actually being detected
    always_comb begin
        if (button_pressed) begin
            // Map button_index bits to RGB and LED
            // bit[0] -> RGB_R (inverted: 0=on)
            // bit[1] -> RGB_G (inverted: 0=on)
            // bit[2] -> RGB_B (inverted: 0=on)
            // bit[3] -> LED (inverted: 0=on)
            RGB_R = ~button_index[0];
            RGB_G = ~button_index[1];
            RGB_B = ~button_index[2];
            LED = ~button_index[3];
        end else begin
            // No button pressed: all LEDs off (high)
            RGB_R = 1;
            RGB_G = 1;
            RGB_B = 1;
            LED = 1;
        end
    end

    

endmodule