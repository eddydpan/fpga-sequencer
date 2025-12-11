`include "model.sv"
`include "button_matrix_controller.sv"

module top (
    input logic clk,
    input logic _39a, _38b, _41a, _42b, // button col inputs
    output logic _36b, _37a, _29b, _31b, // row pin outputs for matrix scanning
    output logic LED,
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);

    // Instantiate model
    logic[6:0] data_in;
    logic[2:0] beats [0:15];

    model u_model (
        .clk(clk),
        .data_in(data_in),
        .beats(beats)
    );

    logic [1:0] row;
    logic [1:0] col;
    logic [3:0] beat_index;

    // 4x4 Button matrix input
    // Map button inputs to row and column
    assign row = _31b ? 2'b00 :
            _29b ? 2'b01 :
            _37a ? 2'b10 :
            _36b ? 2'b11 : 2'b00;

    assign col = _39a ? 2'b00 :
            _38b ? 2'b01 :
            _41a ? 2'b10 :
            _42b ? 2'b11 : 2'b00;

    // Map row and col to beat index and pitch
    assign beat_index = (row * 4) + col;
    
    logic[3:0] button_index; // 4 bits for 16 buttons
    button_matrix_controller u_button_matrix_controller (
        .clk(clk),
        .col_inputs({_39a, _38b, _41a, _42b}),
        .row_outputs({_31b, _29b, _37a, _36b}),
        .button_index(button_index)
    );
endmodule