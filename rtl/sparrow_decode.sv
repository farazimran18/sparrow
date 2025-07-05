module sparrow_decode
  import sparrow_pkg::*;
  (
    input logic [31:0] i_instr,

    output logic      [ 4:0] o_rs1,
    output logic      [ 4:0] o_rs2,
    output logic      [ 4:0] o_rd,
    output riscv_op_e        o_op,
    output logic      [ 2:0] o_funct3,
    output logic      [ 6:0] o_funct7,
    output logic      [31:0] o_instr_imm,

    output logic o_instr_r_type,
    output logic o_instr_i_type,
    output logic o_instr_s_type,
    output logic o_instr_b_type,
    output logic o_instr_u_type,
    output logic o_instr_j_type
  );

  assign o_rs1    = i_instr[19:15];
  assign o_rs2    = i_instr[24:20];
  assign o_rd     = i_instr[11:7];
  assign o_op     = riscv_op_e'(i_instr[6:0]);
  assign o_funct3 = i_instr[14:12];
  assign o_funct7 = i_instr[31:25];

  always_comb begin
    o_instr_r_type = '0;
    o_instr_i_type = '0;
    o_instr_s_type = '0;
    o_instr_b_type = '0;
    o_instr_u_type = '0;
    o_instr_j_type = '0;
    o_instr_imm    = '0;

    unique case (o_op)
      R_TYPE: begin
        o_instr_r_type = '1;
      end
      I_TYPE_0, I_TYPE_1, I_TYPE_2: begin
        o_instr_i_type = '1;
        o_instr_imm    = {{20{i_instr[31]}}, i_instr[31:20]};
      end
      S_TYPE: begin
        o_instr_s_type = '1;
        o_instr_imm    = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};
      end
      B_TYPE: begin
        o_instr_b_type = '1;
        o_instr_imm    = {{20{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};
      end
      U_TYPE_0, U_TYPE_1: begin
        o_instr_u_type = '1;
        o_instr_imm    = {i_instr[31:12], 12'h0};
      end
      J_TYPE: begin
        o_instr_j_type = '1;
        o_instr_imm    = {{12{i_instr[31]}}, i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};
      end
      default: ;
    endcase
  end

endmodule
