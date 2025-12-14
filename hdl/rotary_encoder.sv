// read rotary encoder and output its value

module rotary_encoder (
        input logic         clk, // inputs
        input logic         button,
        input logic         signal_a,
        input logic         signal_b,
        output logic        button_pressed, // outputs
        output logic [3:0]  rotary_position // 4-bits for 9 notes. we assume that state 8 --> state 0
    );

    logic [3:0] counter, next_counter = 4'b0001;


    always_ff @(posedge signal_a) begin 
        if (signal_b == 1'b0) begin
            if (counter == 4'b1000) // wrap from state 8 --> state 0
                next_counter = 4'b0001;
            else
                next_counter = counter + 4'b0001;
        end else begin
            if (counter == 4'b0001) // wrap from state 0 --> state 8
                    next_counter = 4'b1000;
                else
                    next_counter = counter - 4'b0001;
        end

    end

    always_ff @(posedge clk) 
        counter <= next_counter;

    assign rotary_position = counter;
    assign button_pressed = button;


endmodule