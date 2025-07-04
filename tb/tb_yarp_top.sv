module tb_yarp_top
  import yarp_pkg::*;
  #(
    parameter int RESET_PC = 32'h1000
  ) (
    input logic clk,
    input logic reset_n,

    // Instruction memory interface
    output logic        instr_mem_req_o,
    output logic [31:0] instr_mem_addr_o,
    input  logic [31:0] instr_mem_rd_data_i,

    // Data memory interface
    output logic        data_mem_req_o,
    output logic [31:0] data_mem_addr_o,
    output logic [ 1:0] data_mem_byte_en_o,
    output logic        data_mem_wr_o,
    output logic [31:0] data_mem_wr_data_o,
    input  logic [31:0] data_mem_rd_data_i
  );

  yarp_top #(
    .RESET_PC(RESET_PC)
  ) u_yarp_top (
    .clk    (clk    ),
    .reset_n(reset_n),

    .instr_mem_req_o    (instr_mem_req_o    ),
    .instr_mem_addr_o   (instr_mem_addr_o   ),
    .instr_mem_rd_data_i(instr_mem_rd_data_i),

    .data_mem_req_o    (data_mem_req_o    ),
    .data_mem_addr_o   (data_mem_addr_o   ),
    .data_mem_byte_en_o(data_mem_byte_en_o),
    .data_mem_wr_o     (data_mem_wr_o     ),
    .data_mem_wr_data_o(data_mem_wr_data_o),
    .data_mem_rd_data_i(data_mem_rd_data_i)
  );

endmodule
