`timescale 1ns / 1ps


module uart_rx(
    input reset,
    input clk,
    input rx,
    output reg [7:0] rx_data,
    output reg rx_done
);

    reg rx_prev;
    reg [1:0] state, next_state;
    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [15:0] baud_counter;
    
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam RECV_DATA = 2'b10;
    localparam STOP = 2'b11;
    
    parameter BAUD_DIV = 10;
    
    always@(posedge clk or posedge reset)
        begin
        if(reset)
            rx_prev <= 1'b1;
        else
            rx_prev <= rx;
        end

    wire start_edge;
    wire half_baud;
    wire baud_tick;
    
    assign baud_tick = (baud_counter == BAUD_DIV - 1);
    assign half_baud = (baud_counter == BAUD_DIV / 2);
    assign start_edge = rx_prev & ~rx;
    
    // STATE REGISTER
    
    always@(posedge clk or posedge reset)
        begin
            if(reset)
                state <= IDLE;
            else
                state <= next_state;
        end
        
    // BAUD GENERATOR

    always @(posedge clk or posedge reset)
    begin
        if(reset)
            baud_counter <= 0;

        else if(baud_counter == BAUD_DIV - 1)
            baud_counter <= 0;
        
        else if(state == IDLE && start_edge)
            baud_counter <= 0;

        else
            baud_counter <= baud_counter + 1;
    end        
    
    // NEXT STATE LOGIC
    
    always@(*)
        begin
        
            next_state = state;
            
            case(state)
                IDLE:
                    if(start_edge)
                        next_state = START;
                    else
                        next_state = IDLE;
                        
                 START:
                     if(half_baud)
                     begin
                        if(rx == 0)
                            next_state = RECV_DATA;
                        else
                            next_state = IDLE;
                     end
                     else
                        next_state = START;
                        
                 RECV_DATA:
                    begin
                        if(bit_count == 8)
                            next_state = STOP;
                        else
                            next_state = RECV_DATA;
                    end
                    
                 STOP:
                    begin
                        if(baud_tick)
                            next_state = IDLE;
                        else
                            next_state = STOP;
                    end
                    
                 default:
                    next_state = IDLE;
            endcase
        end
        
    // DATAPATH

    always @(posedge clk or posedge reset)
    begin

        if(reset)
        begin
            shift_reg <= 0;
            bit_count <= 0;
            rx_done <= 0;
            rx_data <= 0;
            
        end

        else if(baud_tick)
        begin
            
            rx_done <= 0;
            
            case(state)

                RECV_DATA:
                        begin
                            shift_reg[bit_count] <= rx;
                            bit_count <= bit_count + 1;
                        end

                STOP:
                begin
                    bit_count <= 0;
                    
                    if(rx)
                    begin
                        rx_data <= shift_reg;
                        rx_done <= 1;
                    end
                end
                
                default:
                    rx_done <= 0;
            endcase
        end
    end

endmodule