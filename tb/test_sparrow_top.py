import cocotb
from cocotb.triggers import ClockCycles, RisingEdge
from cocotb.clock import Clock


# Helper class to model memory
class Memory:
    """A simple memory model for the testbench."""

    def __init__(self, size=1024):
        self.size = size
        self.mem = {}

    def read(self, address):
        """Reads a 32-bit word from the specified address."""
        # Ensure address is word-aligned
        if address % 4 != 0:
            cocotb.log.warning(f"Memory read from unaligned address: {hex(address)}")
            address = (address // 4) * 4

        word_address = address // 4
        return self.mem.get(word_address, 0)  # Return 0 if address not found

    def write(self, address, data, byte_en):
        """Writes data to the specified address based on the byte enable."""
        # Ensure address is word-aligned
        if address % 4 != 0:
            cocotb.log.warning(f"Memory write to unaligned address: {hex(address)}")
            address = (address // 4) * 4

        word_address = address // 4
        current_val = self.mem.get(word_address, 0)

        new_val = 0
        for i in range(4):
            if (byte_en >> i) & 1:
                new_val |= ((data >> (i * 8)) & 0xFF) << (i * 8)
            else:
                new_val |= (current_val >> (i * 8) & 0xFF) << (i * 8)

        self.mem[word_address] = new_val
        cocotb.log.info(
            f"MEM WRITE: addr={hex(address)}, data={hex(data)}, byte_en={bin(byte_en)}, result={hex(new_val)}"
        )

    def load_program(self, program, start_address):
        """Loads a program (list of 32-bit instructions) into memory."""
        for i, instruction in enumerate(program):
            self.mem[(start_address // 4) + i] = instruction
            cocotb.log.info(
                f"IMEM LOAD: addr={hex(start_address + i*4)}, instr={hex(instruction)}"
            )


async def imem_driver(dut, memory):
    """Drives the instruction memory interface with immediate reads."""
    while True:
        await RisingEdge(dut.i_clk)
        # Combinational-like read: data is available in the same cycle as the request.
        # The core asserts the address on a rising edge, and the memory provides the data
        # immediately for the core to use within the same clock cycle.
        if dut.imem_req.value:
            addr = dut.imem_addr.value.integer
            data = memory.read(addr)
            dut.imem_rd_data.value = data
            cocotb.log.info(
                f"IMEM READ (immediate): req=1, addr={hex(addr)}, data={hex(data)}"
            )
        else:
            # Keep the line driven to avoid X's
            dut.imem_rd_data.value = 0


async def dmem_driver(dut, memory):
    """
    Drives the data memory interface.
    Reads are immediate (0-cycle latency).
    Writes are delayed by one clock cycle.
    """
    while True:
        await RisingEdge(dut.i_clk)
        if dut.dmem_req.value:
            addr = dut.dmem_addr.value.integer

            if dut.dmem_wr_en.value:
                # Write operation: Capture write info, but delay the actual write by one cycle.
                wr_data = dut.dmem_wr_data.value.integer
                byte_en = dut.dmem_byte_en.value.integer

                await RisingEdge(dut.i_clk)
                memory.write(addr, wr_data, byte_en)
                cocotb.log.info(
                    f"DMEM WRITE (delayed): addr={hex(addr)}, data={hex(wr_data)} written to memory model."
                )

            else:
                # Read operation: Immediate read, data available in the same cycle.
                rd_data = memory.read(addr)
                dut.dmem_rd_data.value = rd_data
                cocotb.log.info(
                    f"DMEM READ (immediate): req=1, addr={hex(addr)}, data={hex(rd_data)}"
                )
        else:
            # Keep the line driven to avoid X's
            dut.dmem_rd_data.value = 0


@cocotb.test()
async def test_sparrow_top(dut):
    """
    Tests the core by running a simple program:
    - ADDI x1, x0, 5      # x1 = 0 + 5
    - ADDI x2, x0, 10     # x2 = 0 + 10
    - ADD  x3, x1, x2     # x3 = x1 + x2 = 15
    - SW   x3, 0(x0)      # Store x3 at memory address 0x0000_0000
    - JAL  x0, .          # Infinite loop to halt the core
    """

    # Test parameters
    RESET_PC = dut.RESET_PC.value

    # Program to execute (assembled using an online RISC-V assembler)
    # The last instruction is a jump-to-self to halt execution.
    program = [
        0x00500093,  # addi x1, x0, 5
        0x00A00113,  # addi x2, x0, 10
        0x002081B3,  # add  x3, x1, x2
        0x00302023,  # sw   x3, 0(x0)
        0x0000006F,  # jal  x0, 0 (jump to self)
    ]

    # 1. Setup
    cocotb.log.info("--- Setup Phase ---")
    clock = Clock(dut.i_clk, 10, units="ns")  # 100 MHz clock
    cocotb.start_soon(clock.start(start_high=False))

    # Initialize memory and load the program
    memory = Memory(size=4096)
    memory.load_program(program, RESET_PC)

    # Start memory drivers
    cocotb.start_soon(imem_driver(dut, memory))
    cocotb.start_soon(dmem_driver(dut, memory))

    # 2. Reset
    cocotb.log.info("--- Resetting DUT ---")
    dut.i_reset_n.value = 0
    dut.imem_rd_data.value = 0
    dut.dmem_rd_data.value = 0
    await ClockCycles(dut.i_clk, 5)
    dut.i_reset_n.value = 1
    await RisingEdge(dut.i_clk)
    cocotb.log.info("--- Reset complete ---")

    # 3. Run the test
    cocotb.log.info("--- Running Program ---")

    # Since the core is single-cycle, the 5-instruction program will complete in 5 cycles
    await ClockCycles(dut.i_clk, 10)

    # 4. Verification
    cocotb.log.info("--- Verification Phase ---")

    # Check the memory location where the result was stored
    result = memory.read(0x0)
    expected_result = 15

    cocotb.log.info(f"Value at memory address 0x00000000 is {hex(result)}")

    assert (
        result == expected_result
    ), f"Test failed! Expected result {expected_result}, but got {result}"

    cocotb.log.info("--- Test PASSED! ---")
