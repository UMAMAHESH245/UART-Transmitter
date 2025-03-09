module uart_tx #(
    parameter CLK_FREQ = 50000000, // Input Clock Frequency (e.g., 50MHz)
    parameter BAUD_RATE = 9600     // Baud Rate
)(
    input wire clk,          // System Clock
    input wire rst,          // Reset
    input wire tx_start,     // Start transmission
    input wire [7:0] tx_data,// Data to transmit
    output reg tx,           // UART transmit output
    output reg tx_busy       // Transmitter busy flag
);

    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE; // Clocks per bit
    localparam BIT_COUNTER_WIDTH = $clog2(BIT_PERIOD); // Counter width

    reg [BIT_COUNTER_WIDTH-1:0] bit_counter;
    reg [3:0] bit_index;
    reg [9:0] shift_reg; // 1 start bit + 8 data bits + 1 stop bit
    reg transmitting;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1;  // Idle state is high
            tx_busy <= 1'b0;
            bit_counter <= 0;
            bit_index <= 0;
            transmitting <= 1'b0;
        end else if (tx_start && !transmitting) begin
            // Load shift register: {stop, data, start}
            shift_reg <= {1'b1, tx_data, 1'b0};
            tx_busy <= 1'b1;
            transmitting <= 1'b1;
            bit_counter <= 0;
            bit_index <= 0;
        end else if (transmitting) begin
            if (bit_counter == BIT_PERIOD - 1) begin
                bit_counter <= 0;
                tx <= shift_reg[0]; // Transmit LSB first
                shift_reg <= shift_reg >> 1;
                bit_index <= bit_index + 1;

                if (bit_index == 9) begin
                    transmitting <= 1'b0;
                    tx_busy <= 1'b0;
                end
            end else begin
                bit_counter <= bit_counter + 1;
            end
        end
    end
endmodule
