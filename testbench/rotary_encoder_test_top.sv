`include "rotary_encoder.sv"

// change on-board leds based on rotary encoder output
module top(
    input logic clk,
    input logic _45a, // rotary encoder button
    input logic _3b, // rotary encoder output B
    input logic _5a, // rotary encoder output A
    output logic LED,
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);

    localparam GREEN = 2'b00;
    localparam BLUE = 2'b01;
    localparam RED = 2'b10;

    // Declare state variables
    logic [1:0] current_state = GREEN;
    logic [1:0] next_state = GREEN;
    logic [2:0] rotary_position;
    logic [2:0] previous_position; // 4 bits for 16 buttons
    logic button_pressed;

    // Declare next output variables
    logic next_red, next_green, next_blue, red, green, blue = 1'b1;
    
    
    rotary_encoder u_rotary_encoder (
        .clk            (clk), // inputs
        .button         (_45a),
        .signal_a       (_5a),
        .signal_b       (_3b),
        .button_pressed (button_pressed), // outputs
        .rotary_position(rotary_position) // 3-bits for 8 notes. we assume that state 7 --> state 0
    );


    // FSM for debugging using onboard LEDs. copied from FSM in iceBlinkPico
    // Register the next state of the FSM
    always_ff @(posedge clk) begin
        current_state <= next_state;
        previous_position <= rotary_position;
    end

    // Compute the next state of the FSM

    // rgb one direction, and bgr the other direction
    // always_comb begin
        // if (rotary_position != previous_position) begin // encoder has been rotated
        //     if (rotary_position > previous_position) begin // rotated in increasing direction [cw]
        //         if (current_state >= 2'b10) // wraps from state 2 --> state 0
        //             next_state = 2'b00;
        //         else
        //             next_state = current_state + 2'b01;
        //     end else begin // rotated in decreasing direction [ccw]
        //         if (current_state <= 2'b00) // wraps from state 0 --> state 2
        //             next_state = 2'b10;
        //         else
        //             next_state = current_state - 2'b01;
        //     end
        // end else
        //     next_state = current_state;
        // end


        // max cw is RED and max ccw is BLUE
    always_comb begin
        if (rotary_position != previous_position) begin // encoder has been rotated
            if (rotary_position > previous_position) begin // rotated in increasing direction [cw]
                if (current_state >= 2'b10) // wraps from state 2 --> state 0
                    next_state = 2'b10;
                else
                    next_state = current_state + 2'b01;
            end else begin // rotated in decreasing direction [ccw]
                if (current_state <= 2'b00) // wraps from state 0 --> state 2
                    next_state = 2'b00;
                else
                    next_state = current_state - 2'b01;
            end
        end else
            next_state = current_state;
    end

    // Compute next output values
    always_comb begin
        next_red = 1'b0;
        next_green = 1'b0;
        next_blue = 1'b0;
        case (current_state)
            GREEN:
                next_green = 1'b1;
            BLUE:
                next_blue = 1'b1;
            RED:
                next_red = 1'b1;
        endcase
    end

    
    // // Register the FSM outputs
    // always_ff @(posedge clk) begin
    //     red <= next_red;
    //     green <= next_green;
    //     blue <= next_blue;
    // end


    assign RGB_R = ~next_red;
    assign RGB_G = ~next_green;
    assign RGB_B = ~next_blue;
    assign LED = ~button_pressed;


endmodule