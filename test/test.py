# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles


# ============================================================
# UART DRIVER CLASS
# ============================================================
class UARTDriver:
    def __init__(self, dut, signal, baud=9600):
        self.dut = dut
        self.signal = signal
        self.bit_time_ns = int(1e9 / baud)

    def _set_bit(self, bit):
        """Modify only bit[0] of ui_in safely"""
        val = self.signal.value.integer
        if bit:
            val |= (1 << 0)
        else:
            val &= ~(1 << 0)
        self.signal.value = val

    async def send_byte(self, byte):
        """Send one UART byte (8N1)"""
        self.dut._log.info(f"UART TX: Sending 0x{byte:02X}")

        # Start bit
        self._set_bit(0)
        await Timer(self.bit_time_ns, units="ns")

        # Data bits (LSB first)
        for i in range(8):
            bit_val = (byte >> i) & 1
            self._set_bit(bit_val)
            self.dut._log.info(f"Bit {i}: {bit_val}")
            await Timer(self.bit_time_ns, units="ns")

        # Stop bit
        self._set_bit(1)
        await Timer(self.bit_time_ns, units="ns")


# ============================================================
# MONITOR (Optional – observe chirp output)
# ============================================================
async def monitor_output(dut, duration_us=2000):
    """Capture output waveform"""
    samples = []
    cycles = int((duration_us * 1000) / 100)  # 10 MHz clock

    for _ in range(cycles):
        await RisingEdge(dut.clk)
        samples.append(int(dut.uo_out.value))

    dut._log.info(f"Captured {len(samples)} samples")
    return samples


# ============================================================
# MAIN TEST
# ============================================================
@cocotb.test()
async def test_uart_chirp(dut):

    dut._log.info("===== START TEST =====")

    # --------------------------------------------------------
    # Clock: 10 MHz
    # --------------------------------------------------------
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # --------------------------------------------------------
    # Initialize inputs
    # --------------------------------------------------------
    dut.ui_in.value = 0xFF   # UART idle = HIGH
    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 5)

    # --------------------------------------------------------
    # Reset
    # --------------------------------------------------------
    dut._log.info("Applying Reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    # --------------------------------------------------------
    # UART Driver
    # --------------------------------------------------------
    uart = UARTDriver(dut, dut.ui_in, baud=9600)

    # --------------------------------------------------------
    # Send Test Byte
    # --------------------------------------------------------
    test_byte = 0xAA
    await uart.send_byte(test_byte)

    # --------------------------------------------------------
    # Wait for chirp generation
    # --------------------------------------------------------
    await Timer(3000, units="us")

    # --------------------------------------------------------
    # Capture output
    # --------------------------------------------------------
    samples = await monitor_output(dut, duration_us=2000)

    # --------------------------------------------------------
    # Basic Checks (sanity)
    # --------------------------------------------------------
    assert len(samples) > 0, "No output samples captured!"

    unique_vals = set(samples)
    dut._log.info(f"Unique output values: {len(unique_vals)}")

    assert len(unique_vals) > 1, "Output is not changing → chirp not generated!"

    dut._log.info("===== TEST PASSED =====")

