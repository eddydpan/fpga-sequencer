// read rotary encoder and output its value

module rotary_encoder (
        input logic         clk, // inputs
        input logic         button,
        input logic         signal_a,
        input logic         signal_b,
        output logic        button_pressed, // outputs
        output logic [2:0]  rotary_position // 3-bits for 8 notes. we assume that state 7 --> state 0
    );

    logic [2:0] counter, next_counter = 3'b000;


    always_ff @(posedge signal_a) begin 
        if (signal_b == 1'b0) begin
            if (counter == 3'b111) // wrap from state 7 --> state 0
                next_counter = 3'b000;
            else
                next_counter = counter + 3'b001;
        end else begin
            if (counter == 3'b000) // wrap from state 0 --> state 7
                    next_counter = 3'b111;
                else
                    next_counter = counter - 3'b001;
        end

    end

    always_ff @(posedge clk) 
        counter <= next_counter;

    assign rotary_position = counter;
    assign button_pressed = button;


endmodule