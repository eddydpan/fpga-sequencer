`include "model.sv"
`include "button_matrix_controller.sv"
`include "audio_controller.sv"
`include "rotary_encoder.sv"
`include "cycle_timer.sv"
`include "i2c_master.sv"

module top(
    input logic clk,
    input logic _39a, 
    input logic _38b, 
    input logic _41a, 
    input logic _42b, // button col inputs
    output logic _36b, 
    output logic _37a, 
    output logic _29b, 
    output logic _31b, // row pin outputs for matrix scanning
    output logic _48b, // audio output pin
    input logic _45a, // rotary encoder button
    input logic _44b, // rotary encoder output B
    input logic _43a, // rotary encoder output A
    inout _4a, // I2C SCL
    inout _6a, // I2C SDA
    output logic LED,
    output logic RGB_R, 
    output logic RGB_G, 
    output logic RGB_B
);
    localparam PERIOD = 10'd4;
    localparam NUM_BEATS = 16;
    localparam BEATS_BUFFER = $clog2(NUM_BEATS);
    localparam CLK_FREQ = 12_000_000; // 12 MHz
    // Instantiate model
    logic [7:0] data_in;
    logic [NUM_BEATS*4-1:0] beats; // 64 bit register: 16 beats x 4 bits each (pitch)
    logic [BEATS_BUFFER-1:0] beat_count; // 4 bits for 16 beats
    logic [$clog2(CLK_FREQ)-1:0] clk_count = 0;
    logic [3:0] seconds;

    logic [3:0] rotary_position;
    logic re_button_pressed;

    model #(
        .NUM_BEATS(NUM_BEATS)
    ) u_model (
        .clk(clk),
        .data_in(data_in),
        .beats(beats)
    );
    
    logic[3:0] button_index; // 4 bits for 16 buttons
    logic button_pressed;
    
    button_matrix_controller u_button_matrix_controller (
        .clk(clk),
        .col_inputs({_42b, _41a, _38b, _39a}),
        .row_outputs({_31b, _29b, _37a, _36b}),
        .button_index(button_index),
        .button_pressed(button_pressed)
    );

    rotary_encoder u_rotary_encoder(
        .clk(clk),
        .button(_45a),
        .signal_a(_43a),
        .signal_b(_44b),
        .button_pressed(re_button_pressed),
        .rotary_position(rotary_position)
    );

    audio_controller #(
        .CLK_FREQ(CLK_FREQ),
        .NUM_BEATS(NUM_BEATS),
        .PERIOD(PERIOD)
    ) u_audio_controller(
        .clk(clk),
        .beats(beats),
        .beat_count(beat_count),
        .pwm_out(_48b)
    );

    // I2C Master for NeoTrellis communication
    logic i2c_enable;
    logic i2c_read_write; // 0=write, 1=read
    logic [39:0] i2c_mosi_data; // 5 bytes: [offset_high, offset_low, R, G, B]
    logic [15:0] i2c_register_address;
    logic [6:0] i2c_device_address;
    logic [15:0] i2c_divider;
    logic [39:0] i2c_miso_data;
    logic i2c_busy;

    // For NeoTrellis: we need 5 data bytes [offset_high, offset_low, R, G, B]
    // For pixel 1 (offset = 1*3 = 3) with blue color (R=0, G=0, B=255):
    // Data = [0x00, 0x03, 0x00, 0x00, 0xFF]
    // In 40-bit format (MSB first): 0x00_03_00_00_FF
    i2c_master #(
        .NUMBER_OF_DATA_BYTES(5),       // offset_high, offset_low, R, G, B
        .NUMBER_OF_REGISTER_BYTES(2),   // Register address 0x0E04
        .ADDRESS_WIDTH(7),              // 7-bit I2C address
        .CHECK_FOR_CLOCK_STRETCHING(0), // Disable for simplicity
        .CLOCK_STRETCHING_MAX_COUNT(0)
    ) u_i2c_master (
        .clock(clk),
        .reset_n(1'b1),                 // Always enabled for now
        .enable(i2c_enable),
        .read_write(i2c_read_write),
        .mosi_data(i2c_mosi_data),      // Connected to FSM-controlled signal
        .register_address(i2c_register_address),
        .device_address(i2c_device_address),
        .divider(i2c_divider),
        .miso_data(i2c_miso_data),
        .busy(i2c_busy),
        .external_serial_data(_6a),     // SDA
        .external_serial_clock(_4a)     // SCL
    );
    
    // I2C Control FSM
    typedef enum logic [2:0] {
        I2C_IDLE,
        I2C_WRITE_PIXEL,
        I2C_WAIT_WRITE,
        I2C_SHOW,
        I2C_WAIT_SHOW,
        I2C_DONE
    } i2c_state_t;
    
    i2c_state_t i2c_state;
    logic startup_done;

    always_ff @(posedge clk) begin
        // Increment seconds counter
        if (clk_count == CLK_FREQ - 1) begin
            seconds <= seconds + 1;
            clk_count <= 0;
        end else begin
            clk_count <= clk_count + 1;
        end

        // I2C FSM to write blue color to pixel 1 on startup
        case (i2c_state)
            I2C_IDLE: begin
                i2c_enable <= 1'b0;
                if (!startup_done) begin
                    // Initialize I2C parameters
                    i2c_device_address <= 7'h2E;           // NeoTrellis address
                    i2c_read_write <= 1'b0;                // Write
                    i2c_register_address <= 16'h0E04;      // SEESAW_NEOPIXEL_BUF
                    // Pixel 1 (offset = 1*3 = 3), blue color (R=0, G=0, B=255)
                    i2c_mosi_data <= 40'h00_03_00_00_FF;
                    // I2C clock divider: 12MHz / (100kHz * 4) = 30
                    // The i2c_master divides by (divider+1), and has 4 phases per bit
                    // So for 100kHz I2C: 12MHz / (100kHz * 4) - 1 = 29
                    i2c_divider <= 16'd29;
                    i2c_state <= I2C_WRITE_PIXEL;
                end
            end
            
            I2C_WRITE_PIXEL: begin
                i2c_enable <= 1'b1;                        // Start transaction
                i2c_state <= I2C_WAIT_WRITE;
            end
            
            I2C_WAIT_WRITE: begin
                i2c_enable <= 1'b0;                        // Deassert enable
                if (!i2c_busy) begin                       // Wait for completion
                    i2c_register_address <= 16'h0E05;      // SEESAW_NEOPIXEL_SHOW
                    i2c_mosi_data <= 40'h00_00_00_00_00;   // No data for show command
                    i2c_state <= I2C_SHOW;
                end
            end
            
            I2C_SHOW: begin
                i2c_enable <= 1'b1;                        // Start show command
                i2c_state <= I2C_WAIT_SHOW;
            end
            
            I2C_WAIT_SHOW: begin
                i2c_enable <= 1'b0;
                if (!i2c_busy) begin
                    startup_done <= 1'b1;
                    i2c_state <= I2C_DONE;
                end
            end
            
            I2C_DONE: begin
                // Stay here, pixel is set
            end
        endcase

        if (button_pressed) begin
            // Concatenate rotary encoder position and button index to form data_in
            // data_in is {4 bits of pitch, 4 bits of beat index}
            data_in <= {rotary_position, button_index}; // TODO: map pitch bits w/ rotary encoder #3
        end

    end
    // Hardware debugger: Show I2C FSM state and button presses
    always_comb begin
        if (button_pressed) begin
            // Map button_index bits to RGB and LED
            RGB_R = ~button_index[0];
            RGB_G = ~button_index[1];
            RGB_B = ~button_index[2];
            LED = ~button_index[3];
        end else begin
            // Show I2C state machine progress on LEDs
            // RGB_R: ON when in WRITE_PIXEL or WAIT_WRITE
            // RGB_G: ON when in SHOW or WAIT_SHOW
            // RGB_B: ON when DONE (stays on after completion)
            // LED: ON when I2C is busy
            case (i2c_state)
                I2C_IDLE: begin
                    RGB_R = 1; RGB_G = 1; RGB_B = 1; LED = 1;
                end
                I2C_WRITE_PIXEL, I2C_WAIT_WRITE: begin
                    RGB_R = 0; RGB_G = 1; RGB_B = 1; LED = ~i2c_busy;
                end
                I2C_SHOW, I2C_WAIT_SHOW: begin
                    RGB_R = 1; RGB_G = 0; RGB_B = 1; LED = ~i2c_busy;
                end
                I2C_DONE: begin
                    RGB_R = 1; RGB_G = 1; RGB_B = 0; LED = 1;
                end
                default: begin
                    RGB_R = 1; RGB_G = 1; RGB_B = 1; LED = 1;
                end
            endcase
        end
    end

    

endmodule