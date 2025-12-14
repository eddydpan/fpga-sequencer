`timescale 10ns/10ns
`include "rotary_encoder_test_top.sv"

module rotary_encoder_tb;

    logic clk = 0;
    logic _45a = 1'b1;
    logic _3b = 1'b1;
    logic _5a = 1'b1;

    top u0 (
        .clk            (clk), 
        ._49a             (_45a), 
        ._3b           (_3b), 
        ._5a           (_5a),
        .LED            (LED),
        .RGB_R          (RGB_R),
        .RGB_G          (RGB_G),
        .RGB_B          (RGB_B)
    );

    initial begin
        $dumpfile("rotary_encoder.vcd");
        $dumpvars(0, rotary_encoder_tb);
        #10000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end
    
    always begin
        #100
        _3b = ~_3b;
        #10
        _5a = ~_5a;

    end

endmodule

