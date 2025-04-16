import yarp_pkg::*;

module yarp_execute (
    // Source operands
    input logic [31:0] opr_a_i,
    input logic [31:0] opr_b_i,

    // ALU Operation
    input logic [3:0] op_sel_i,

    // ALU output
    output logic [31:0] alu_res_o
  );

  // Write your logic here...

endmodule
