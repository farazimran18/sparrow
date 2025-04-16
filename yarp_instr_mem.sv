import yarp_pkg::*;

module yarp_instr_mem (
    input logic clk,
    input logic reset_n,

    input logic [31:0] instr_mem_pc_i,

    // Output read request to memory
    output logic        instr_mem_req_o,
    output logic [31:0] instr_mem_addr_o,

    // Read data from memory
    input logic [31:0] mem_rd_data_i,

    // Instruction output
    output logic [31:0] instr_mem_instr_o
  );

  // Write your logic here...

endmodule
