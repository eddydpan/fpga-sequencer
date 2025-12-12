`timescale 10ns/10ns
`include "../hdl/top.sv"

module top_tb;

    logic clk = 0;
    logic LED, RGB_R, RGB_G, RGB_B;
    logic _39a, _38b, _41a, _42b;  // Column inputs
    logic _36b, _37a, _29b, _31b;  // Row outputs

    top u0 (
        .clk            (clk),
        ._39a           (_39a),
        ._38b           (_38b),
        ._41a           (_41a),
        ._42b           (_42b),
        ._36b           (_36b),
        ._37a           (_37a),
        ._29b           (_29b),
        ._31b           (_31b),
        .LED            (LED), 
        .RGB_R          (RGB_R), 
        .RGB_G          (RGB_G), 
        .RGB_B          (RGB_B)
    );

    // Simulate the button matrix hardware
    // When a row is driven low and a button is "pressed", pull the corresponding column low
    logic [15:0] buttons_pressed = 16'b0;  // Bit mask for which buttons are pressed
    
    always_comb begin
        // Default: columns pulled high (no button pressed)
        _39a = 1;
        _38b = 1;
        _41a = 1;
        _42b = 1;
        
        // Check each row output and simulate button matrix behavior
        if (~_36b) begin  // Row 0 active
            if (buttons_pressed[0]) _39a = 0;  // Button 0
            if (buttons_pressed[1]) _38b = 0;  // Button 1
            if (buttons_pressed[2]) _41a = 0;  // Button 2
            if (buttons_pressed[3]) _42b = 0;  // Button 3
        end
        if (~_37a) begin  // Row 1 active
            if (buttons_pressed[4]) _39a = 0;  // Button 4
            if (buttons_pressed[5]) _38b = 0;  // Button 5
            if (buttons_pressed[6]) _41a = 0;  // Button 6
            if (buttons_pressed[7]) _42b = 0;  // Button 7
        end
        if (~_29b) begin  // Row 2 active
            if (buttons_pressed[8]) _39a = 0;   // Button 8
            if (buttons_pressed[9]) _38b = 0;   // Button 9
            if (buttons_pressed[10]) _41a = 0;  // Button 10
            if (buttons_pressed[11]) _42b = 0;  // Button 11
        end
        if (~_31b) begin  // Row 3 active
            if (buttons_pressed[12]) _39a = 0;  // Button 12
            if (buttons_pressed[13]) _38b = 0;  // Button 13
            if (buttons_pressed[14]) _41a = 0;  // Button 14
            if (buttons_pressed[15]) _42b = 0;  // Button 15
        end
    end

    initial begin
        $dumpfile("testbench/top.vcd");
        $dumpvars(0, top_tb);
        
        // Simulate button presses
        #1000;
        $display("Pressing button 5");
        buttons_pressed[5] = 1;
        
        #50000;
        $display("Releasing button 5");
        buttons_pressed[5] = 0;
        
        #1000;
        $display("Pressing button 10");
        buttons_pressed[10] = 1;
        
        #50000;
        $display("Releasing button 10");
        buttons_pressed[10] = 0;
        
        #10000;
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule

