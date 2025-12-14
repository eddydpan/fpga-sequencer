`timescale 1us/1ns
`include "hdl/top.sv"

module top_tb;

    logic clk = 0;
    logic LED, RGB_R, RGB_G, RGB_B;
    logic _39a, _38b, _41a, _42b;  // Column inputs
    logic _36b, _37a, _29b, _31b;  // Row outputs
    logic _44b;

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
        ._44b           (_44b),  
        .LED            (LED), 
        .RGB_R          (RGB_R), 
        .RGB_G          (RGB_G), 
        .RGB_B          (RGB_B)
    );

    // Default: all column inputs high (no buttons pressed)
    initial begin
        _39a = 1;
        _38b = 1;
        _41a = 1;
        _42b = 1;
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

