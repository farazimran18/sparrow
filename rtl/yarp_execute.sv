module yarp_execute
  import yarp_pkg::*;
  (
    input logic [31:0] opr_a_i,
    input logic [31:0] opr_b_i,

    input alu_op_e op_sel_i,

    output logic [31:0] alu_res_o
  );

  logic [31:0] twos_compl_a, twos_compl_b;

  assign twos_compl_a = opr_a_i[31] ? (~opr_a_i + 32'h1) : opr_a_i;
  assign twos_compl_b = opr_b_i[31] ? (~opr_b_i + 32'h1) : opr_b_i;

  always_comb begin
    unique case (op_sel_i)
      OP_ADD : alu_res_o = opr_a_i + opr_b_i;
      OP_SUB : alu_res_o = opr_a_i - opr_b_i;
      OP_SLL : alu_res_o = opr_a_i << opr_b_i[4:0];
      OP_SRL : alu_res_o = opr_a_i >> opr_b_i[4:0];
      OP_SRA : alu_res_o = $signed(opr_a_i) >>> opr_b_i[4:0];
      OP_OR  : alu_res_o = opr_a_i | opr_b_i;
      OP_AND : alu_res_o = opr_a_i & opr_b_i;
      OP_XOR : alu_res_o = opr_a_i ^ opr_b_i;
      OP_SLTU: alu_res_o = {31'h0, opr_a_i < opr_b_i};
      OP_SLT : alu_res_o = {31'h0, twos_compl_a < twos_compl_b};
      default: alu_res_o = '0;
    endcase
  end

endmodule
