module sparrow_execute
  import sparrow_pkg::*;
  (
    input logic    [31:0] i_opr_a,
    input logic    [31:0] i_opr_b,
    input alu_op_e        i_op,

    output logic [31:0] o_result
  );

  always_comb begin
    unique case (i_op)
      OP_ADD : o_result = i_opr_a + i_opr_b;
      OP_SUB : o_result = i_opr_a - i_opr_b;
      OP_SLL : o_result = i_opr_a << i_opr_b[4:0];
      OP_SRL : o_result = i_opr_a >> i_opr_b[4:0];
      OP_SRA : o_result = $signed(i_opr_a) >>> i_opr_b[4:0];
      OP_OR  : o_result = i_opr_a | i_opr_b;
      OP_AND : o_result = i_opr_a & i_opr_b;
      OP_XOR : o_result = i_opr_a ^ i_opr_b;
      OP_SLTU: o_result = {31'h0, i_opr_a < i_opr_b};
      OP_SLT : o_result = {31'h0, $signed(i_opr_a) < $signed(i_opr_b)};

      default: o_result = '0;
    endcase
  end

endmodule
