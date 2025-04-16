import yarp_pkg::*;

module yarp_decode (
    input  logic [31:0] instr_i,
    output logic [4:0]  rs1_o,
    output logic [4:0]  rs2_o,
    output logic [4:0]  rd_o,
    output logic [6:0]  op_o,
    output logic [2:0]  funct3_o,
    output logic [6:0]  funct7_o,
    output logic        r_type_instr_o,
    output logic        i_type_instr_o,
    output logic        s_type_instr_o,
    output logic        b_type_instr_o,
    output logic        u_type_instr_o,
    output logic        j_type_instr_o,
    output logic [31:0] instr_imm_o
  );

  // Write your logic here...

endmodule
