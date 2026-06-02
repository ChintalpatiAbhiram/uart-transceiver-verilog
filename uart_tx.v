`timescale 1ns / 1ps

module uart_tx(
    input reset,
    input clk,
    input tx_start,
    input [7:0] tx_data,
    output reg tx,
    output tx_busy
);

    reg [1:0] state, next_state;
    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [15:0] baud_counter;
    reg tx_request;

    wire baud_tick;

    localparam IDLE      = 2'b00;
    localparam START     = 2'b01;
    localparam SEND_DATA = 2'b10;
    localparam STOP      = 2'b11;

    parameter BAUD_DIV = 10;

    assign baud_tick = (baud_counter == BAUD_DIV - 1);
    assign tx_busy = (state != IDLE);

    // STATE REGISTER

    always @(posedge clk or posedge reset)
    begin
        if(reset)
            state <= IDLE;

        else if(state == IDLE && tx_request)
            state <= START;

        else if(baud_tick)
            state <= next_state;
    end

    // TX REQUEST LATCH

    always @(posedge clk or posedge reset)
    begin
        if(reset)
            tx_request <= 0;

        else
        begin
            if(tx_start)
                tx_request <= 1;

            else if(state == START)
                tx_request <= 0;
        end
    end

    // BAUD GENERATOR

    always @(posedge clk or posedge reset)
    begin
        if(reset)
            baud_counter <= 0;

        else if(state == IDLE && tx_request)
            baud_counter <= 0;

        else if(baud_counter == BAUD_DIV - 1)
            baud_counter <= 0;

        else
            baud_counter <= baud_counter + 1;
    end

    // NEXT STATE LOGIC

    always @(*)
    begin

        next_state = state;

        case(state)

            IDLE:
                next_state = IDLE;

            START:
                next_state = SEND_DATA;

            SEND_DATA:
            begin
                if(bit_count == 7)
                    next_state = STOP;
                else
                    next_state = SEND_DATA;
            end

            STOP:
                next_state = IDLE;

            default:
                next_state = IDLE;

        endcase
    end

    // OUTPUT LOGIC

    always @(*)
    begin

        tx = 1;

        case(state)

            IDLE:
                tx = 1;

            START:
                tx = 0;

            SEND_DATA:
                tx = shift_reg[0];

            STOP:
                tx = 1;

            default:
                tx = 1;

        endcase
    end

    // DATAPATH

    always @(posedge clk or posedge reset)
    begin

        if(reset)
        begin
            shift_reg <= 0;
            bit_count <= 0;
        end

        else if(state == IDLE && tx_request)
        begin
            shift_reg <= tx_data;
            bit_count <= 0;
        end

        else if(baud_tick)
        begin

            case(state)

                SEND_DATA:
                begin
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count + 1;
                end

                STOP:
                begin
                    bit_count <= 0;
                end

            endcase
        end
    end

endmodule