module seven_segment (
    input logic clk,
    input logic [7:0] note,
    output logic [6:0] seg_data,
    output logic decimal
);

localparam [3:0] NOTE_REST = 4'b0000;
localparam [3:0] NOTE_C4 = 4'b0001;
localparam [3:0] NOTE_D4 = 4'b0010;
localparam [3:0] NOTE_E4 = 4'b0011;
localparam [3:0] NOTE_F4 = 4'b0100;
localparam [3:0] NOTE_G4 = 4'b0101;
localparam [3:0] NOTE_A4 = 4'b0110;
localparam [3:0] NOTE_B4 = 4'b0111;
localparam [3:0] NOTE_C5 = 4'b1000;

localparam [7:0] C = 7'b1011001;
localparam [7:0] D = 7'b0111111;
localparam [7:0] E = 7'b1111001;
localparam [7:0] F = 7'b1110001;
localparam [7:0] G = 7'b1111101;
localparam [7:0] A = 7'b1110111;
localparam [7:0] B = 7'b1111111;
localparam [7:0] REST = 7'b0000000; // off 
    
always_comb begin
    decimal = 1'b0; // turn off decimal point
    case(note)
        NOTE_C4: seg_data = C;
        NOTE_D4: seg_data = D;
        NOTE_E4: seg_data = E;
        NOTE_F4: seg_data = F;
        NOTE_G4: seg_data = G;
        NOTE_A4: seg_data = A;
        NOTE_B4: seg_data = B;
        NOTE_C5: begin
            seg_data = C;
            decimal = 1'b1;
        end
        REST: seg_data = REST;
    endcase
end
endmodule