// Sequencer data model

module model #(
    parameter NUM_BEATS = 16
)(
    input logic clk,
    input logic[7:0] data_in, // 8 bits: 4 bits for beat index, 4 bits for pitch
    output logic[NUM_BEATS*4-1:0] beats // 64 bits: 16 beats x 4 bits each
);
    logic[3:0] beat_index;

    initial begin
        // Initialize all bits to 0 (no pitch on all beats)
        beats = {NUM_BEATS*4{1'b0}};
    end

    // Update beats on clock edge
    always_ff @(posedge clk) begin
        beat_index = data_in[3:0];
        // part-select operator
        beats[beat_index*4 +: 4] <= data_in[7:4];
    end
endmodule