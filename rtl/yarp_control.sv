import yarp_pkg::*;

module yarp_control (
    // Instruction type
    input logic is_r_type_i,
    input logic is_i_type_i,
    input logic is_s_type_i,
    input logic is_b_type_i,
    input logic is_u_type_i,
    input logic is_j_type_i,

    // Instruction opcode/funct fields
    input logic [2:0] instr_funct3_i,
    input logic       instr_funct7_bit5_i,
    input logic [6:0] instr_opcode_i,

    // Control signals
    output logic       pc_sel_o,
    output logic       op1sel_o,
    output logic       op2sel_o,
    output logic [3:0] alu_func_o,
    output logic [1:0] rf_wr_data_o,
    output logic       data_req_o,
    output logic [1:0] data_byte_o,
    output logic       data_wr_o,
    output logic       zero_extnd_o,
    output logic       rf_wr_en_o
  );

  // Write your logic here...

endmodule
