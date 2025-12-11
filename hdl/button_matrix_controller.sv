// Scans the 4x4 button matrix and debounces button presses

module u_button_matrix_controller(
    input logic clk,
    input logic[3:0] col_inputs, // button col inputs
    output logic[3:0] row_outputs, // button row outputs
    output logic[3:0] button_index // 4 bits: 4 bits for beat index
);

    logic [1:0] row;
    logic [1:0] col;

    // Read column inputs

    // Row scanning outputs

    // Store button_index as output

endmodule