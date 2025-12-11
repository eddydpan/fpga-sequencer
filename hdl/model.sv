// Sequencer data model

module model(
    input logic clk,
    input logic[6:0] data_in, // 7 bits: 4 bits for beat index, 3 bits for pitch
    output logic[47:0] beats // 48 bits: 16 beats × 3 bits each
    // Add ports as needed  
);
    logic[3:0] beat_index;

    initial begin
        // Initialize all bits to 0
        beats = 48'b0;
    end

    // Update beats on clock edge
    always_ff @(posedge clk) begin
        beat_index = data_in[3:0];
        beats[beat_index*3 +: 3] <= data_in[6:4];
    end
endmodule