`include "pwm.sv"

// PWM top level module

module top #(
    parameter PWM_INTERVAL = 22940      // CLK frequency is 12MHz, so 1,200 cycles is 100us
                                        // this is N in freq = clk/(2N)
)(
    input logic     clk,
    output logic    RGB_R,
    output logic    _48b
);
    
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;


    // generates pwm output for speaker
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm (
        .clk            (clk),
        .pwm_out        (pwm_out)
    );

    assign _48b = pwm_out;

endmodule