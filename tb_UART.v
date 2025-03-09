`timescale 1ns/1ps

module uart_tx_tb;
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx;
    wire tx_busy;

    // Clock parameters
    parameter CLK_PERIOD = 20; // 50MHz clock (20ns period)
    parameter BAUD_RATE = 9600;
    parameter BIT_PERIOD = 1000000000 / BAUD_RATE; // ns per bit

    // Instantiate the UART Transmitter
    uart_tx #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(9600)
    ) uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Clock Generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        tx_start = 0;
        tx_data = 8'h00;

        // Reset sequence
        #100;
        rst = 0;

        // Send first byte (0xA5)
        #1000;
        tx_data = 8'hA5;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Wait for transmission
        #100000;

        // Send second byte (0x3C)
        tx_data = 8'h3C;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Wait for transmission
        #100000;

        $stop;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | TX=%b | Busy=%b", $time, tx, tx_busy);
    end
endmodule
