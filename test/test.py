# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer, RisingEdge, ReadOnly


async def wait_done_low(dut):
    while True:
        await RisingEdge(dut.clk)
        await ReadOnly()
        val = dut.uio_out[0].value
        if val.is_resolvable:
            if val.integer == 0:
                break
        else:
            await Timer(200, units="ns")


@cocotb.test()
async def test_uart_behavior(dut):
    dut._log.info("Starting test...")

     
    dut.rst_n.value = 1
    dut._log.info("assert ui_in = 1")
    dut.ui_in.value = 1  # UART idle (high)
    
    # Clock setup: 10 MHz = 100 ns period
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    await ClockCycles(dut.clk, 2)
    
    #Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    
    # UART transmission of 0x01 directly inlined
    bit_time_ns = 104160
    byte = 0xAA

    dut._log.info("Start UART send routine")

    # Start bit
    dut._log.info("set start bit to 0")
    dut.ui_in[0].value = 0
    await Timer(bit_time_ns, units="ns")

    # Data bits (LSB first)
    for i in range(8):
        bit_val = (byte >> i) & 1
        dut.ui_in[0].value = bit_val
        dut._log.info(f"write bit {i} = {bit_val}")
        await Timer(bit_time_ns, units="ns")

    # Stop bit
    dut._log.info("set stop bit to 1")
    dut.ui_in[0].value = 1
    await Timer(bit_time_ns, units="ns")

    await Timer(2500, units="us")
    
    # Optional: wait for done
    # await wait_done_low(dut)

    dut._log.info("Test completed.")
