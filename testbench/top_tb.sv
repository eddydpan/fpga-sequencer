`timescale 1us/1ns
`include "hdl/top.sv"

module top_tb;

    logic clk = 0;
    logic LED, RGB_R, RGB_G, RGB_B;
    logic _39a, _38b, _41a, _42b;  // Column inputs
    logic _36b, _37a, _29b, _31b;  // Row outputs
    logic _48b;  // Audio output
    logic _45a, _44b, _43a;  // Rotary encoder
    logic _13b;  // UART TX output

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
        ._48b           (_48b),
        ._45a           (_45a),
        ._44b           (_44b),
        ._43a           (_43a),
        ._13b           (_13b),
        .LED            (LED), 
        .RGB_R          (RGB_R), 
        .RGB_G          (RGB_G), 
        .RGB_B          (RGB_B)
    );

    // Default: all inputs high (no buttons pressed)
    initial begin
        _39a = 1;
        _38b = 1;
        _41a = 1;
        _42b = 1;
        _45a = 1;  // Rotary encoder button not pressed
        _43a = 0;
        _44b = 0;
    end

    initial begin
        $dumpfile("testbench/top.vcd");
        $dumpvars(0, top_tb);
        
        // Run for 1.2 seconds
        #1200000;
        $finish;
    end

    // Clock generation (12 MHz: period = 83.33ns ≈ 0.08333us)
    always begin
        #0.041665;  // Half period
        clk = ~clk;
    end

endmodule

