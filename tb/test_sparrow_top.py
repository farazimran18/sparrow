import cocotb
from cocotb.triggers import ClockCycles
from cocotb.clock import Clock


@cocotb.test()
async def test_sparrow_top(dut):

    clock = Clock(dut.clk, 1, units="ns")  # 1 GHz clock
    cocotb.start_soon(clock.start(start_high=False))

    dut.reset_n.value = 0
    await ClockCycles(dut.clk, 1)

    dut.reset_n.value = 1
    await ClockCycles(dut.clk, 10)
