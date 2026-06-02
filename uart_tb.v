`timescale 1ns / 1ps

module uart_tx_tb;

    reg reset;
    reg clk;
    reg tx_start;
    reg [7:0] tx_data;
    
    wire tx;
    wire tx_busy;
    wire rx;
    
    assign rx = tx;
    // Instantiate UART TX
    uart_tx uut (
        .reset(reset),
        .clk(clk),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );
    
    uart_rx uut1 (
        .reset(reset),
        .clk(clk),
        .rx(rx),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

    // Clock generation
    always #5 clk = ~clk;
    
    
    // Multiple byte task
    
    task send_byte;
        input [7:0] data;
        
    begin
        wait(tx_busy == 0);
        
        tx_data = data;

        @(posedge clk);
        tx_start = 1;
    
        @(posedge clk);
        tx_start = 0;
    end
    endtask
    initial
    begin

        // Initialize
        clk = 0;
        reset = 1;
        tx_start = 0;
        // Apply reset
        #20;
        reset = 0;
        
        send_byte(8'h53);
        send_byte(8'hAA);
        send_byte(8'hFF);
        send_byte(8'h00);
        
        #3000;

        $finish;
    end

    // Monitor signals
    initial
    begin
        $monitor(
        "TIME=%0t | TX_STATE=%0d | RX_STATE=%0d | RX=%b | TX=%b | RX_BAUD=%0d | SHIFT_RX = %b | SHIFT_TX = %b | BIT_COUNT = %b",
        $time,
        uut.state,
        uut1.state,
        rx,
        tx,
        uut1.baud_counter,
        uut1.shift_reg,
        uut.shift_reg,
        uut1.bit_count
        );
    end

endmodule