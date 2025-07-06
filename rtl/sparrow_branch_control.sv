module sparrow_branch_control
  import sparrow_pkg::*;
(
    input logic [31:0] i_opr_a,
    input logic [31:0] i_opr_b,

    input logic    i_instr_b_type,
    input b_type_e i_instr_funct3,

    output logic o_branch_taken
);

  always_comb begin
    o_branch_taken = '0;

    if (i_instr_b_type) begin
      unique case (i_instr_funct3)
        BEQ:     o_branch_taken = (i_opr_a == i_opr_b);
        BNE:     o_branch_taken = (i_opr_a != i_opr_b);
        BLT:     o_branch_taken = ($signed(i_opr_a) < $signed(i_opr_b));
        BGE:     o_branch_taken = ($signed(i_opr_a) >= $signed(i_opr_b));
        BLTU:    o_branch_taken = (i_opr_a < i_opr_b);
        BGEU:    o_branch_taken = (i_opr_a >= i_opr_b);
        default: o_branch_taken = 1'b0;
      endcase
    end
  end

endmodule
