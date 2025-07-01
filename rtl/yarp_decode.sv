module yarp_decode
  import yarp_pkg::*;
(
    input logic [31:0] instr_i,

    output logic [ 4:0] rs1_o,
    output logic [ 4:0] rs2_o,
    output logic [ 4:0] rd_o,
    output logic [ 6:0] op_o,
    output logic [ 2:0] funct3_o,
    output logic [ 6:0] funct7_o,
    output logic [31:0] instr_imm_o,

    output logic r_type_instr_o,
    output logic i_type_instr_o,
    output logic s_type_instr_o,
    output logic b_type_instr_o,
    output logic u_type_instr_o,
    output logic j_type_instr_o
);

  riscv_op_e opcode;
  assign opcode   = riscv_op_e'(instr_i[6:0]);

  assign rs1_o    = instr_i[19:15];
  assign rs2_o    = instr_i[24:20];
  assign rd_o     = instr_i[11:7];
  assign op_o     = opcode;
  assign funct3_o = instr_i[14:12];
  assign funct7_o = instr_i[31:25];

  always_comb begin
    r_type_instr_o = '0;
    i_type_instr_o = '0;
    s_type_instr_o = '0;
    b_type_instr_o = '0;
    u_type_instr_o = '0;
    j_type_instr_o = '0;
    instr_imm_o    = '0;

    unique case (opcode)
      R_TYPE: begin
        r_type_instr_o = '1;
      end
      I_TYPE_0, I_TYPE_1, I_TYPE_2: begin
        i_type_instr_o = '1;
        instr_imm_o    = {{20{instr_i[31]}}, instr_i[31:20]};
      end
      S_TYPE: begin
        s_type_instr_o = '1;
        instr_imm_o    = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
      end
      B_TYPE: begin
        b_type_instr_o = '1;
        instr_imm_o    = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
      end
      U_TYPE_0, U_TYPE_1: begin
        u_type_instr_o = '1;
        instr_imm_o    = {instr_i[31:12], 12'h0};
      end
      J_TYPE: begin
        j_type_instr_o = '1;
        instr_imm_o    = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
      end
      default: ;
    endcase
  end

endmodule
