# uart-transceiver-verilog
UART Transceiver in Verilog
# Overview
This project implements a UART (Universal Asynchronous Receiver Transmitter) Transceiver using Verilog HDL. The design integrates both UART Transmitter (TX) and UART Receiver (RX) modules, enabling end-to-end serial communication.

The transmitter serializes parallel data and sends it over the UART line, while the receiver reconstructs the original data from the received serial stream. The complete transceiver was verified through simulation using Xilinx Vivado.

# Features
1. UART Transmitter (TX)
2. UART Receiver (RX)
3. End-to-end serial communication
4. FSM-based architecture
5. Start bit generation and detection
6. Stop bit generation and validation
7. Baud rate control
8. Data serialization and deserialization
9. Simulation testbench included

# Verification

The transceiver was verified using a dedicated testbench.

Verification checks included:

1. Correct start bit generation
2. Correct stop bit generation
3. Proper serialization of transmitted data
4. Proper deserialization of received data
5. End-to-end data integrity
6. UART timing validation

# Learning Outcomes

Through this project, I learned:

1. UART communication protocol
2. FSM-based RTL design
3. Shift register implementation
4. Baud rate generation
5. Serial communication fundamentals
6. Testbench development
7. RTL debugging and waveform analysis
