module yarp_top
  import yarp_pkg::*;
#(
    parameter RESET_PC = 32'h1000
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

  // Write your logic here...

  // --------------------------------------------------------
  // Instruction Memory
  // --------------------------------------------------------
  yarp_instr_mem u_yarp_instr_mem (
      .clk              (clk),
      .reset_n          (reset_n),
      .instr_mem_pc_i   (),
      .instr_mem_req_o  (),
      .instr_mem_addr_o (),
      .mem_rd_data_i    (),
      .instr_mem_instr_o()
  );

  // --------------------------------------------------------
  // Instruction Decode
  // --------------------------------------------------------
  yarp_decode u_yarp_decode (
      .instr_i       (),
      .rs1_o         (),
      .rs2_o         (),
      .rd_o          (),
      .op_o          (),
      .funct3_o      (),
      .funct7_o      (),
      .r_type_instr_o(),
      .i_type_instr_o(),
      .s_type_instr_o(),
      .b_type_instr_o(),
      .u_type_instr_o(),
      .j_type_instr_o(),
      .instr_imm_o   ()
  );

  // --------------------------------------------------------
  // Register File
  // --------------------------------------------------------
  yarp_regfile u_yarp_regfile (
      .clk       (clk),
      .reset_n   (reset_n),
      .rs1_addr_i(),
      .rs2_addr_i(),
      .rd_addr_i (),
      .wr_en_i   (),
      .wr_data_i (),
      .rs1_data_o(),
      .rs2_data_o()
  );

  // --------------------------------------------------------
  // Control Unit
  // --------------------------------------------------------
  yarp_control u_yarp_control (
      .instr_funct3_i     (),
      .instr_funct7_bit5_i(),
      .instr_opcode_i     (),
      .is_r_type_i        (),
      .is_i_type_i        (),
      .is_s_type_i        (),
      .is_b_type_i        (),
      .is_u_type_i        (),
      .is_j_type_i        (),
      .pc_sel_o           (),
      .op1sel_o           (),
      .op2sel_o           (),
      .data_req_o         (),
      .data_wr_o          (),
      .data_byte_o        (),
      .zero_extnd_o       (),
      .rf_wr_en_o         (),
      .rf_wr_data_o       (),
      .alu_func_o         ()
  );

  // --------------------------------------------------------
  // Branch Control
  // --------------------------------------------------------
  yarp_branch_control u_yarp_branch_control (
      .opr_a_i          (),
      .opr_b_i          (),
      .is_b_type_ctl_i  (),
      .instr_func3_ctl_i(),
      .branch_taken_o   ()
  );

  // --------------------------------------------------------
  // Execute Unit
  // --------------------------------------------------------
  yarp_execute u_yarp_execute (
      .opr_a_i  (),
      .opr_b_i  (),
      .op_sel_i (),
      .alu_res_o()
  );

  // --------------------------------------------------------
  // Data Memory
  // --------------------------------------------------------
  yarp_data_mem u_yarp_data_mem (
      .clk               (clk),
      .reset_n           (reset_n),
      .data_req_i        (),
      .data_addr_i       (),
      .data_byte_en_i    (),
      .data_wr_i         (),
      .data_wr_data_i    (),
      .data_zero_extnd_i (),
      .data_mem_req_o    (),
      .data_mem_addr_o   (),
      .data_mem_byte_en_o(),
      .data_mem_wr_o     (),
      .data_mem_wr_data_o(),
      .mem_rd_data_i     (),
      .data_mem_rd_data_o()
  );

endmodule
