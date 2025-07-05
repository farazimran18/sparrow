module sparrow_top
  import sparrow_pkg::*;
  #(
    parameter int RESET_PC = 32'h1000
  ) (
    input logic clk,
    input logic reset_n,

    // Instruction memory interface
    output logic        instr_mem_req_o,
    output logic [31:0] instr_mem_addr_o,
    input  logic [31:0] instr_mem_rd_data_i,

    // Data memory interface
    output logic        data_mem_req_o,
    output logic [31:0] data_mem_addr_o,
    output logic [ 1:0] data_mem_byte_en_o,
    output logic        data_mem_wr_o,
    output logic [31:0] data_mem_wr_data_o,
    input  logic [31:0] data_mem_rd_data_i
  );

  // Internal signals
  logic     [31:0] imem_dec_instr;
  logic     [ 4:0] dec_rf_rs1;
  logic     [ 4:0] dec_rf_rs2;
  logic     [ 4:0] dec_rf_rd;
  logic     [31:0] rf_rs1_data;
  logic     [31:0] rf_rs2_data;
  logic     [31:0] rf_wr_data;
  logic     [31:0] alu_opr_a;
  logic     [31:0] alu_opr_b;
  logic     [31:0] data_mem_rd_data;
  logic     [31:0] nxt_seq_pc;
  logic     [31:0] nxt_pc;
  logic     [31:0] pc_q;
  logic     [ 6:0] dec_ctl_opcode;
  logic     [ 2:0] dec_ctl_funct3;
  logic     [ 6:0] dec_ctl_funct7;
  logic            r_type_instr;
  logic            i_type_instr;
  logic            s_type_instr;
  logic            b_type_instr;
  logic            u_type_instr;
  logic            j_type_instr;
  logic     [31:0] dec_instr_imm;
  logic     [31:0] ex_alu_res;
  control_t        control_signals;
  logic            branch_taken;
  logic            reset_seen_q;

  // Capture the first cycle out of reset
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      reset_seen_q <= 1'b0;
    end else begin
      reset_seen_q <= 1'b1;
    end
  end

  // Program Counter logic
  assign nxt_seq_pc = pc_q + 32'h4;
  assign nxt_pc = (branch_taken | control_signals.pc_sel) ? {ex_alu_res[31:1], 1'b0} : nxt_seq_pc;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      pc_q <= RESET_PC;
    end else if (reset_seen_q) begin
      pc_q <= nxt_pc;
    end
  end

  // Instruction Memory
  sparrow_imem_intf u_sparrow_imem_intf (
    .i_clk     (clk     ),
    .i_reset_n (reset_n ),

    .i_imem_pc (pc_q           ),
    .o_instr   (imem_dec_instr ),

    .o_imem_req     (instr_mem_req_o    ),
    .o_imem_addr    (instr_mem_addr_o   ),
    .i_imem_rd_data (instr_mem_rd_data_i)
  );

  // Instruction Decode
  sparrow_decode u_sparrow_decode (
    .i_instr (imem_dec_instr),

    .o_rs1       (dec_rf_rs1    ),
    .o_rs2       (dec_rf_rs2    ),
    .o_rd        (dec_rf_rd     ),
    .o_opcode    (dec_ctl_opcode),
    .o_funct3    (dec_ctl_funct3),
    .o_funct7    (dec_ctl_funct7),
    .o_instr_imm (dec_instr_imm ),

    .o_instr_r_type(r_type_instr ),
    .o_instr_i_type(i_type_instr ),
    .o_instr_s_type(s_type_instr ),
    .o_instr_b_type(b_type_instr ),
    .o_instr_u_type(u_type_instr ),
    .o_instr_j_type(j_type_instr )
  );

  // Register File
  assign rf_wr_data = (control_signals.rf_wr_data_sel == ALU) ? ex_alu_res :
    (control_signals.rf_wr_data_sel == MEM) ? data_mem_rd_data :
    (control_signals.rf_wr_data_sel == IMM) ? dec_instr_imm    :
    nxt_seq_pc;
  sparrow_regfile u_sparrow_regfile (
    .i_clk     (clk     ),
    .i_reset_n (reset_n ),

    .i_rd1_addr (dec_rf_rs1  ),
    .o_rd1_data (rf_rs1_data ),

    .i_rd2_addr (dec_rf_rs2  ),
    .o_rd2_data (rf_rs2_data ),

    .i_wr_en   (control_signals.rf_wr_en),
    .i_wr_addr (dec_rf_rd               ),
    .i_wr_data (rf_wr_data              )
  );

  // Control Unit
  sparrow_control u_sparrow_control (
    .instr_funct3_i     (dec_ctl_funct3   ),
    .instr_funct7_bit5_i(dec_ctl_funct7[5]),
    .instr_opcode_i     (dec_ctl_opcode   ),
    .is_r_type_i        (r_type_instr     ),
    .is_i_type_i        (i_type_instr     ),
    .is_s_type_i        (s_type_instr     ),
    .is_b_type_i        (b_type_instr     ),
    .is_u_type_i        (u_type_instr     ),
    .is_j_type_i        (j_type_instr     ),
    .controls_o         (control_signals  )
  );

  // Branch Control
  sparrow_branch_control u_sparrow_branch_control (
    .i_opr_a (rf_rs1_data ),
    .i_opr_b (rf_rs2_data ),

    .i_instr_b_type (b_type_instr             ),
    .i_instr_funct3 (b_type_e'(dec_ctl_funct3)),

    .o_branch_taken (branch_taken )
  );

  // ALU operand mux
  assign alu_opr_a = control_signals.op1_sel ? pc_q          : rf_rs1_data;
  assign alu_opr_b = control_signals.op2_sel ? dec_instr_imm : rf_rs2_data;

  // Execute Unit
  sparrow_execute u_sparrow_execute (
    .i_opr_a (alu_opr_a                    ),
    .i_opr_b (alu_opr_b                    ),
    .i_op    (control_signals.alu_funct_sel),

    .o_result(ex_alu_res )
  );

  // Data Memory
  sparrow_dmem_intf u_sparrow_dmem_intf (
    .i_instr_req         (control_signals.data_req  ),
    .i_instr_addr        (ex_alu_res                ),
    .i_instr_byte_en     (control_signals.data_byte ),
    .i_instr_wr_en       (control_signals.data_wr   ),
    .i_instr_wr_data     (rf_rs2_data               ),
    .o_instr_rd_data     (data_mem_rd_data          ),
    .i_instr_zero_extend (control_signals.zero_extnd),

    .o_dmem_req     (data_mem_req_o     ),
    .o_dmem_addr    (data_mem_addr_o    ),
    .o_dmem_byte_en (data_mem_byte_en_o ),
    .o_dmem_wr_en   (data_mem_wr_o      ),
    .o_dmem_wr_data (data_mem_wr_data_o ),
    .i_dmem_rd_data (data_mem_rd_data_i )
  );

endmodule
