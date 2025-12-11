// Scans the 4x4 button matrix and detects button presses
// Row pins are outputs (driven low one at a time)
// Column pins are inputs (read to detect which button in active row is pressed)

module button_matrix_controller(
    input logic clk,
    input logic[3:0] col_inputs,    // Column inputs - pulled high, read as low when button pressed
    output logic[3:0] row_outputs,  // Row outputs - one driven low at a time
    output logic[3:0] button_index, // Index of detected button (0-15)
    output logic button_pressed     // High when a button is detected
);

    logic [1:0] row_scan = 0;       // Current row being scanned (0-3)
    logic [1:0] scan_state = 0;     // 0: set row, 1: read columns
    logic [15:0] clk_div = 0;       // Clock divider for slower scanning
    
    // Row scanning: Set one row low at a time
    always_ff @(posedge clk) begin
        clk_div <= clk_div + 1;
        
        // Only update scan on clock divider rollover (every 65536 clocks)
        if (clk_div == 0) begin
            if (scan_state == 0) begin
                // Set the row outputs
                row_outputs <= 4'b1111;  // Default all high
                case (row_scan)
                    2'b00: row_outputs[0] <= 1'b0;
                    2'b01: row_outputs[1] <= 1'b0;
                    2'b10: row_outputs[2] <= 1'b0;
                    2'b11: row_outputs[3] <= 1'b0;
                endcase
                scan_state <= 1;
            end else begin
                // Read column inputs (LOW = button pressed on active row)
                button_pressed <= 1'b0;
                
                if (~col_inputs[0]) begin
                    button_index <= {row_scan, 2'b00};  // row*4 + 0
                    button_pressed <= 1'b1;
                end else if (~col_inputs[1]) begin
                    button_index <= {row_scan, 2'b01};  // row*4 + 1
                    button_pressed <= 1'b1;
                end else if (~col_inputs[2]) begin
                    button_index <= {row_scan, 2'b10};  // row*4 + 2
                    button_pressed <= 1'b1;
                end else if (~col_inputs[3]) begin
                    button_index <= {row_scan, 2'b11};  // row*4 + 3
                    button_pressed <= 1'b1;
                end
                
                // Move to next row
                row_scan <= row_scan + 1;
                scan_state <= 0;
            end
        end
    end

endmodule