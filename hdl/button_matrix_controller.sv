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
    localparam debounce_cycles = 1200; // 12MHz clock -> 10ms debounce
    logic [1:0] row_scan = 0;       // Current row being scanned (0-3)
    logic [1:0] current_state = 2'b00;     // 0: set row, 1: read columns
    logic [$clog2(debounce_cycles)-1:0] clk_div = 0;       // Clock divider for slower scanning
    logic [3:0] col_sync0, col_sync1, col_sync2; // sychronized column inputs
    
    logic button_was_pressed = 1'b0;
    localparam [1:0] DRIVE = 2'b00;
    localparam [1:0] SETTLE = 2'b01;
    localparam [1:0] READ = 2'b10;

    // Row scanning: Set one row low at a time
    always_ff @(posedge clk) begin
        // Clock divider for debounce timing
        if (clk_div == debounce_cycles - 1) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div + 1;
        end

        // Only update scan on clk_div reset
        if (clk_div == 0) begin
            case(current_state)
                DRIVE: begin
                    // Set the row outputs
                    row_outputs <= 4'b1111;  // Default all high
                    case (row_scan)
                        2'b00: row_outputs[0] <= 1'b0;
                        2'b01: row_outputs[1] <= 1'b0;
                        2'b10: row_outputs[2] <= 1'b0;
                        2'b11: row_outputs[3] <= 1'b0;
                    endcase
                    current_state <= current_state + 2'b01;
                end
                SETTLE: begin
                    // just here to take up time doing nothing
                    current_state <= current_state + 2'b01;
                end
                READ: begin
                    button_pressed <= 1'b0;
                    // Read column inputs (LOW = button pressed on active row)
                    if (~col_sync2[0]) begin
                        button_index <= {row_scan, 2'b00};  // row*4 + 0
                        if (!button_was_pressed) button_pressed <= 1'b1;
                    end else if (~col_sync2[1]) begin
                        button_index <= {row_scan, 2'b01};  // row*4 + 1
                        if (!button_was_pressed) button_pressed <= 1'b1;
                    end else if (~col_sync2[2]) begin
                        button_index <= {row_scan, 2'b10};  // row*4 + 2
                        if (!button_was_pressed) button_pressed <= 1'b1;
                    end else if (~col_sync2[3]) begin
                        button_index <= {row_scan, 2'b11};  // row*4 + 3
                        if (!button_was_pressed) button_pressed <= 1'b1;
                    end
                    button_was_pressed <= (col_sync2 != 4'b1111);
                    // Move to next row
                    row_scan <= row_scan + 1;
                    current_state <= DRIVE;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        col_sync0 <= col_inputs;
        col_sync1 <= col_sync0;
        col_sync2 <= col_sync1;
    end

endmodule