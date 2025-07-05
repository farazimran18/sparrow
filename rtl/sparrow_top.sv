module sparrow_top
  import sparrow_pkg::*;
  #(
    parameter int RESET_PC = 32'h1000
  ) (
    input logic i_clk,
    input logic i_reset_n,

    // instruction memory interface
    output logic        o_imem_req,
    output logic [31:0] o_imem_addr,
    input  logic [31:0] i_imem_rd_data,

    // data memory interface
    output logic        o_dmem_req,
    output logic [31:0] o_dmem_addr,
    output logic [ 1:0] o_dmem_byte_en,
    output logic        o_dmem_wr_en,
    output logic [31:0] o_dmem_wr_data,
    input  logic [31:0] i_dmem_rd_data
  );

  logic [31:0] current_instr;
  logic [31:0] instr_imm;
  logic [ 6:0] instr_opcode;
  logic [ 2:0] instr_funct3;
  logic [ 6:0] instr_funct7;

  logic r_type_instr;
  logic i_type_instr;
  logic s_type_instr;
  logic b_type_instr;
  logic u_type_instr;
  logic j_type_instr;

  logic [ 4:0] regfile_rs1_addr;
  logic [31:0] regfile_rs1_data;
  logic [ 4:0] regfile_rs2_addr;
  logic [31:0] regfile_rs2_data;
  logic [ 4:0] regfile_rd_addr;
  logic [31:0] regfile_rd_data;

  logic [31:0] alu_opr_a;
  logic [31:0] alu_opr_b;
  logic [31:0] alu_result;

  logic        reset_seen_q;
  logic [31:0] next_seq_pc;
  logic [31:0] current_pc;
  logic [31:0] next_pc;

  logic        branch_taken;
  logic [31:0] dmem_rd_data;

  control_t control_signals;

  // capture the first cycle out of reset
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      reset_seen_q <= 1'b0;
    end else begin
      reset_seen_q <= 1'b1;
    end
  end

  // PC logic
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      current_pc <= RESET_PC;
    end else if (reset_seen_q) begin
      current_pc <= next_pc;
    end
  end

  assign next_seq_pc = current_pc + 32'h4;
  assign next_pc = (branch_taken | control_signals.pc_sel) ? {alu_result[31:1], 1'b0} : next_seq_pc;

  // instruction memory interface
  sparrow_imem_intf u_sparrow_imem_intf (
    .i_clk     (i_clk     ),
    .i_reset_n (i_reset_n ),

    .i_imem_pc (current_pc    ),
    .o_instr   (current_instr ),

    .o_imem_req     (o_imem_req     ),
    .o_imem_addr    (o_imem_addr    ),
    .i_imem_rd_data (i_imem_rd_data )
  );

  // instruction decode
  sparrow_decode u_sparrow_decode (
    .i_instr (current_instr ),

    .o_rs1       (regfile_rs1_addr ),
    .o_rs2       (regfile_rs2_addr ),
    .o_rd        (regfile_rd_addr  ),
    .o_opcode    (instr_opcode     ),
    .o_funct3    (instr_funct3     ),
    .o_funct7    (instr_funct7     ),
    .o_instr_imm (instr_imm        ),

    .o_instr_r_type(r_type_instr ),
    .o_instr_i_type(i_type_instr ),
    .o_instr_s_type(s_type_instr ),
    .o_instr_b_type(b_type_instr ),
    .o_instr_u_type(u_type_instr ),
    .o_instr_j_type(j_type_instr )
  );

  // register file
  assign regfile_rd_data = (control_signals.rf_wr_data_sel == ALU) ? alu_result :
    (control_signals.rf_wr_data_sel == MEM) ? dmem_rd_data :
    (control_signals.rf_wr_data_sel == IMM) ? instr_imm    :
    next_seq_pc;
  sparrow_regfile u_sparrow_regfile (
    .i_clk     (i_clk     ),
    .i_reset_n (i_reset_n ),

    .i_rd1_addr (regfile_rs1_addr ),
    .o_rd1_data (regfile_rs1_data ),

    .i_rd2_addr (regfile_rs2_addr ),
    .o_rd2_data (regfile_rs2_data ),

    .i_wr_en   (control_signals.rf_wr_en ),
    .i_wr_addr (regfile_rd_addr          ),
    .i_wr_data (regfile_rd_data          )
  );

  // control unit
  sparrow_control u_sparrow_control (
    .i_instr_r_type (r_type_instr ),
    .i_instr_i_type (i_type_instr ),
    .i_instr_s_type (s_type_instr ),
    .i_instr_b_type (b_type_instr ),
    .i_instr_u_type (u_type_instr ),
    .i_instr_j_type (j_type_instr ),

    .i_instr_opcode (instr_opcode ),
    .i_instr_funct3 (instr_funct3 ),
    .i_instr_funct7 (instr_funct7 ),

    .o_controls (control_signals )
  );

  // branch control
  sparrow_branch_control u_sparrow_branch_control (
    .i_opr_a (regfile_rs1_data ),
    .i_opr_b (regfile_rs2_data ),

    .i_instr_b_type (b_type_instr            ),
    .i_instr_funct3 (b_type_e'(instr_funct3) ),

    .o_branch_taken (branch_taken )
  );

  // ALU operand mux
  assign alu_opr_a = control_signals.op1_sel ? current_pc : regfile_rs1_data;
  assign alu_opr_b = control_signals.op2_sel ? instr_imm  : regfile_rs2_data;

  // ALU
  sparrow_execute u_sparrow_execute (
    .i_opr_a (alu_opr_a              ),
    .i_opr_b (alu_opr_b              ),
    .i_op    (control_signals.alu_op ),

    .o_result(alu_result )
  );

  // data memory interface
  sparrow_dmem_intf u_sparrow_dmem_intf (
    .i_instr_req         (control_signals.dmem_req         ),
    .i_instr_addr        (alu_result                       ),
    .i_instr_byte_en     (control_signals.dmem_byte_en     ),
    .i_instr_wr_en       (control_signals.dmem_wr_en       ),
    .i_instr_wr_data     (regfile_rs2_data                 ),
    .o_instr_rd_data     (dmem_rd_data                     ),
    .i_instr_zero_extend (control_signals.dmem_zero_extend ),

    .o_dmem_req     (o_dmem_req     ),
    .o_dmem_addr    (o_dmem_addr    ),
    .o_dmem_byte_en (o_dmem_byte_en ),
    .o_dmem_wr_en   (o_dmem_wr_en   ),
    .o_dmem_wr_data (o_dmem_wr_data ),
    .i_dmem_rd_data (i_dmem_rd_data )
  );

endmodule
