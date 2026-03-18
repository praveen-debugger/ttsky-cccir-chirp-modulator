How it works

This design receives an 8-bit data byte through a UART RX interface and generates a corresponding chirp signal using LoRa-style modulation.

The input byte is captured via a UART receiver.

The design encodes this byte into a chirp signal based on:

Bandwidth (BW): 125 kHz

Spreading Factor (SF): 8

The chirp represents the digital LoRa modulation of the input data.

The generated chirp is provided as an 8-bit parallel digital output:

data_out[7] → MSB

data_out[0] → LSB

Each output sample corresponds to the instantaneous amplitude of the chirp waveform.

<img src="additional/Megnevezetlen diagram.png" >
How to test

Connect all required hardware components.

Apply a 10 MHz clock to the design.

Power on the system:

Assert Reset = 0 (active low reset).

Send a byte through the UART interface.

Observe the 8-bit output bus:

The output will represent the generated chirp corresponding to the transmitted byte.

External hardware

UART Transmitter (TX only)
Connect to the design’s RX input.

Clock Generator (10 MHz)
Provides the system clock.

Digital Signal Analyzer / Logic Analyzer
Connect to:

data_out[7:0] to observe the chirp waveform samples.

Notes (Recommended to Add)

UART configuration (if applicable):

Baud rate: (e.g., 9600 / 115200 — specify your design value)

Data bits: 8

Parity: None

Stop bits: 1

Chirp duration:

One chirp corresponds to one input byte (SF8 → 256 chips).

Output behavior:

Continuous output or one-shot per byte (clarify based on your RTL).
