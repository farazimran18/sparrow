module yarp_execute
  import yarp_pkg::*;
(
    input logic [31:0] opr_a_i,
    input logic [31:0] opr_b_i,

    input logic [3:0] op_sel_i,

    output logic [31:0] alu_res_o
);

  alu_op_e alu_op;
  assign alu_op = alu_op_e'(op_sel_i);

  always_comb begin
    unique case (alu_op)
      OP_ADD:  alu_res_o = opr_a_i + opr_b_i;
      OP_SUB:  alu_res_o = opr_a_i - opr_b_i;
      OP_SLL:  alu_res_o = opr_a_i << opr_b_i[4:0];
      OP_SRL:  alu_res_o = '1;
      OP_SRA:  alu_res_o = '1;
      OP_OR:   alu_res_o = '1;
      OP_AND:  alu_res_o = '1;
      OP_XOR:  alu_res_o = '1;
      OP_SLTU: alu_res_o = '1;
      OP_SLT:  alu_res_o = '1;
      default: alu_res_o = '0;
    endcase
  end

endmodule
