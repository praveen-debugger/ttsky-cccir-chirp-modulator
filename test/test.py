import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer


CLK_PERIOD_NS = 100        # 10 MHz clock
UART_BIT_TIME_US = 1000    # 1 ms per bit (adjust if needed)


async def uart_send_byte(dut, data):
    """Send one UART byte (8N1 format) on ui_in[0]"""

    cocotb.log.info(f"Sending byte: {data:#010b}")

    # Ensure other bits = 0, only bit0 used
    bus_val = 0

    # Start bit (0)
    cocotb.log.info("UART START bit")
    bus_val = 0b00000000
    dut.ui_in.value = bus_val
    await Timer(UART_BIT_TIME_US, unit="us")

    # Data bits (LSB first)
    for i in range(8):
        bit = (data >> i) & 1
        cocotb.log.info(f"UART DATA bit {i}: {bit}")

        if bit == 1:
            bus_val = 0b00000001
        else:
            bus_val = 0b00000000

        dut.ui_in.value = bus_val
        await Timer(UART_BIT_TIME_US, unit="us")

    # Stop bit (1)
    cocotb.log.info("UART STOP bit")
    dut.ui_in.value = 0b00000001
    await Timer(UART_BIT_TIME_US, unit="us")


@cocotb.test()
async def test_uart_behavior(dut):
    """Main UART test"""

    cocotb.log.info("Starting test...")

    # Start clock
    clock = Clock(dut.clk, CLK_PERIOD_NS, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset sequence
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await Timer(500, unit="ns")

    dut.rst_n.value = 1
    await Timer(500, unit="ns")

    cocotb.log.info("Reset done")

    # Idle line (UART idle = 1)
    dut.ui_in.value = 0b00000001
    await Timer(2000, unit="ns")

    # Send test bytes
    cocotb.log.info("Start UART send routine")

    await uart_send_byte(dut, 0x55)   # 01010101 (good test pattern)
    await uart_send_byte(dut, 0xA3)
    await uart_send_byte(dut, 0x7F)

    # Wait for DUT processing (chirp generation etc.)
    cocotb.log.info("Waiting for DUT response...")
    await Timer(5, unit="ms")

    cocotb.log.info("Test completed")
