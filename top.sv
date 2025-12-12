`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk,
    output logic    RGB_R,
    output logic    _48b
);
    
    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;

    initial begin
        pwm_value <= 1000; // 1000
    end

    // generates pwm output for red
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) pwm (
        .clk            (clk), 
        .pwm_value      (pwm_value), 
        .pwm_out        (pwm_out)
    );

    assign _48b = pwm_out;

endmodule