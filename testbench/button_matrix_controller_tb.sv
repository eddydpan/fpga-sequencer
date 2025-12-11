`timescale 1ns/1ps

module button_matrix_controller_tb;
    logic clk;
    logic[3:0] col_inputs;
    logic[3:0] row_outputs;
    logic[3:0] button_index;
    logic button_pressed;
    
    // Instantiate the button matrix controller
    button_matrix_controller dut (
        .clk(clk),
        .col_inputs(col_inputs),
        .row_outputs(row_outputs),
        .button_index(button_index),
        .button_pressed(button_pressed)
    );
    
    // Clock generation (100MHz = 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Simulate the keypad matrix behavior
    // When a row is driven low and a button is pressed, the corresponding column goes low
    logic[15:0] button_state;  // State of all 16 buttons (1 = pressed)
    
    always_comb begin
        // Default: all columns high (no button pressed)
        col_inputs = 4'b1111;
        
        // Check which row is active (driven low)
        case (row_outputs)
            4'b1110: begin  // Row 0 active
                if (button_state[0])  col_inputs[0] = 0;  // Button 0
                if (button_state[1])  col_inputs[1] = 0;  // Button 1
                if (button_state[2])  col_inputs[2] = 0;  // Button 2
                if (button_state[3])  col_inputs[3] = 0;  // Button 3
            end
            4'b1101: begin  // Row 1 active
                if (button_state[4])  col_inputs[0] = 0;  // Button 4
                if (button_state[5])  col_inputs[1] = 0;  // Button 5
                if (button_state[6])  col_inputs[2] = 0;  // Button 6
                if (button_state[7])  col_inputs[3] = 0;  // Button 7
            end
            4'b1011: begin  // Row 2 active
                if (button_state[8])  col_inputs[0] = 0;  // Button 8
                if (button_state[9])  col_inputs[1] = 0;  // Button 9
                if (button_state[10]) col_inputs[2] = 0;  // Button 10
                if (button_state[11]) col_inputs[3] = 0;  // Button 11
            end
            4'b0111: begin  // Row 3 active
                if (button_state[12]) col_inputs[0] = 0;  // Button 12
                if (button_state[13]) col_inputs[1] = 0;  // Button 13
                if (button_state[14]) col_inputs[2] = 0;  // Button 14
                if (button_state[15]) col_inputs[3] = 0;  // Button 15
            end
        endcase
    end
    
    // Test stimulus
    initial begin
        $dumpfile("button_matrix_controller.vcd");
        $dumpvars(0, button_matrix_controller_tb);
        
        // Initialize - no buttons pressed
        button_state = 16'h0000;
        
        // Wait for a few scan cycles
        #200;
        
        // Test 1: Press button 0 (row 0, col 0)
        $display("Test 1: Press button 0");
        button_state[0] = 1;
        #100;
        if (button_pressed && button_index == 0) 
            $display("  PASS: Button 0 detected");
        else
            $display("  FAIL: Expected button 0, got index=%d pressed=%b", button_index, button_pressed);
        button_state[0] = 0;
        #100;
        
        // Test 2: Press button 5 (row 1, col 1)
        $display("Test 2: Press button 5");
        button_state[5] = 1;
        #100;
        if (button_pressed && button_index == 5)
            $display("  PASS: Button 5 detected");
        else
            $display("  FAIL: Expected button 5, got index=%d pressed=%b", button_index, button_pressed);
        button_state[5] = 0;
        #100;
        
        // Test 3: Press button 10 (row 2, col 2)
        $display("Test 3: Press button 10");
        button_state[10] = 1;
        #100;
        if (button_pressed && button_index == 10)
            $display("  PASS: Button 10 detected");
        else
            $display("  FAIL: Expected button 10, got index=%d pressed=%b", button_index, button_pressed);
        button_state[10] = 0;
        #100;
        
        // Test 4: Press button 15 (row 3, col 3)
        $display("Test 4: Press button 15");
        button_state[15] = 1;
        #100;
        if (button_pressed && button_index == 15)
            $display("  PASS: Button 15 detected");
        else
            $display("  FAIL: Expected button 15, got index=%d pressed=%b", button_index, button_pressed);
        button_state[15] = 0;
        #100;
        
        // Test 5: Multiple buttons (should detect first in priority)
        $display("Test 5: Multiple buttons pressed");
        button_state[7] = 1;
        button_state[8] = 1;
        #200;
        $display("  Detected indices while both pressed:");
        button_state[7] = 0;
        button_state[8] = 0;
        #100;
        
        // Test 6: Verify no false positives
        $display("Test 6: No buttons pressed");
        button_state = 16'h0000;
        #200;
        if (!button_pressed)
            $display("  PASS: No false button detection");
        else
            $display("  FAIL: False button detected: index=%d", button_index);
        
        $display("\nSimulation complete");
        $finish;
    end
    
    // Monitor button detections
    always @(posedge clk) begin
        if (button_pressed) begin
            $display("  [%0t] Button %0d detected (row=%b)", $time, button_index, row_outputs);
        end
    end

endmodule
