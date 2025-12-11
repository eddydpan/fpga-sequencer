`include "model.sv"
`include "button_matrix_controller.sv"

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
    output logic LED,
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);

    // Instantiate model
    logic[6:0] data_in;
    logic[47:0] beats; // 48 bits: 16 beats x 3 bits each

    model u_model (
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