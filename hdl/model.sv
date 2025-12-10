// Sequencer data model

module model(
    input logic clk,
    input logic[6:0] data_in, // 7 bits: 4 bits for beat index, 3 bits for pitch
    output logic[2:0] beats [0:15]
    // Add ports as needed  
);
    logic[3:0] beat_index;

    initial begin
        // Initialize all bits to 0
        beats = '{default:'0};
    end

    // Update beats on data_in change
    always_comb begin
        beat_index = data_in[3:0];
        beats[beat_index] = data_in[6:4];
    end
endmodule