`include "model.sv"
`include "button_matrix_controller.sv"
`include "audio_controller.sv"
`include "rotary_encoder.sv"
`include "seven_segment.sv"
`include "uart_tx.sv"

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
    output logic _48b, // audio output pin
    //{_0a, _5a, _9b, _6a, _4a, _49a, _3b}
    output logic _9b, // seven segment display segments
    output logic _6a,
    output logic _4a,
    output logic _2a,
    output logic _0a,
    output logic _5a,
    output logic _3b,
    output logic _49a,
    input logic _45a, // rotary encoder button
    input logic _44b, // rotary encoder output B
    input logic _43a, // rotary encoder output A
    output logic _13b, // UART TX pin
    output logic LED,
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);
    localparam PERIOD = 4;
    localparam NUM_BEATS = 16;
    localparam BEATS_BUFFER = $clog2(NUM_BEATS);
    localparam CLK_FREQ = 12_000_000; // 12 MHz
    // Instantiate model
    logic [7:0] data_in;
    logic [NUM_BEATS*4-1:0] beats; // 64 bit register: 16 beats x 4 bits each (pitch)
    logic [BEATS_BUFFER-1:0] beat_count; // 4 bits for 16 beats
    logic [$clog2(CLK_FREQ)-1:0] clk_count = 0;
    logic [3:0] seconds;
    logic [3:0] note;

    logic [3:0] rotary_position;
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
        .signal_a(_43a),
        .signal_b(_44b),
        .button_pressed(re_button_pressed),
        .rotary_position(rotary_position)
    );

    audio_controller #(
        .CLK_FREQ(CLK_FREQ),
        .NUM_BEATS(NUM_BEATS),
        .PERIOD(PERIOD)
    ) u_audio_controller(
        .clk(clk),
        .beats(beats),
        .beat_count(beat_count),
        .pwm_out(_48b),
        .pitch (note)
    );

    seven_segment u_seven_segment (
        .clk(clk),
        .note (note),
        .seg_data({_0a, _5a, _9b, _6a, _4a, _49a, _3b}), // GFEDCBA
        .decimal(_2a)
    );
    // Power-on reset for UART
    logic [7:0] reset_counter = 0;
    logic uart_rstn = 0;
    
    always_ff @(posedge clk) begin
        if (reset_counter < 8'd255) begin
            reset_counter <= reset_counter + 1;
            uart_rstn <= 0;
        end else begin
            uart_rstn <= 1;
        end
    end
    // UART signals
    logic button_pressed_prev = 0;
    logic tx_valid = 0;
    logic uart_sig;
    logic uart_ready;
    logic [7:0] uart_data;  // Separate register for UART transmission
    
    // Sync signal: send 0xFF when beat wraps to 0 (end of period)
    logic [BEATS_BUFFER-1:0] beat_count_prev = 0;
    logic send_sync = 0;

    uart_tx #(
        .DATA_WIDTH(8),
        .BAUD_RATE(9600),
        .CLK_FREQ(CLK_FREQ)
    ) uart_tx_inst (
        .sig(uart_sig),
        .data(uart_data),  // Use uart_data instead of data_in
        .valid(tx_valid),
        .ready(uart_ready),
        .clk(clk),
        .rstn(uart_rstn)
    );
    
    assign _13b = uart_sig;

    always_ff @(posedge clk) begin
        button_pressed_prev <= button_pressed;
        beat_count_prev <= beat_count;
        
        // Detect when beat wraps from 15 to 0 (end of period)
        if (beat_count == 0 && beat_count_prev == NUM_BEATS - 1) begin
            send_sync <= 1;
        end else begin
            send_sync <= 0;
        end
        
        // Priority: sync message, then button data
        if (send_sync && uart_ready) begin
            uart_data <= 8'hFF;  // Sync marker: all 1s
            tx_valid <= 1;
        end else if (button_pressed) begin
            // Update sequencer model only on button press
            data_in <= {rotary_position, button_index};
            
            // Send UART only on rising edge
            if (!button_pressed_prev && uart_ready) begin
                uart_data <= {rotary_position, button_index};
                tx_valid <= 1;
            end else begin
                tx_valid <= 0;
            end
        end else begin
            tx_valid <= 0;
        end
    end
    
    always_ff @(posedge clk) begin
        // Increment seconds counter
        if (clk_count == CLK_FREQ - 1) begin
            seconds <= seconds + 1;
            clk_count <= 0;
        end else begin
            clk_count <= clk_count + 1;
        end

    end
    // Hardware debugger: Map button_index bits directly to LEDs
    // This will help debug what values are actually being detected
    always_comb begin
        if (button_pressed) begin
            // Map button_index bits to RGB and LED
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