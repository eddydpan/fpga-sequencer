`timescale 10ns/10ns
`include "top.sv"

module pwm_tb;

    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    logic RGB_R;
    logic _48b;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk), 
        .RGB_R          (RGB_R),
        ._48b           (_48b)
    );

    initial begin
        $dumpfile("pwm.vcd");
        $dumpvars(0, pwm_tb);
        #80000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
