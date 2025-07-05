module sparrow_control
  import sparrow_pkg::*;
  (
    input logic i_instr_r_type,
    input logic i_instr_i_type,
    input logic i_instr_s_type,
    input logic i_instr_b_type,
    input logic i_instr_u_type,
    input logic i_instr_j_type,

    input logic [6:0] i_instr_opcode,
    input logic [2:0] i_instr_funct3,
    input logic [6:0] i_instr_funct7,

    output control_t o_controls
  );

  control_t r_type_controls;
  control_t i_type_controls;
  control_t s_type_controls;
  control_t b_type_controls;
  control_t u_type_controls;
  control_t j_type_controls;

  // r-type
  always_comb begin
    r_type_controls          = '0;
    r_type_controls.rf_wr_en = 1'b1;

    unique case (r_type_e'({i_instr_funct7[5], i_instr_funct3}))
      ADD  : r_type_controls.alu_op = OP_ADD;
      AND  : r_type_controls.alu_op = OP_AND;
      OR   : r_type_controls.alu_op = OP_OR;
      SLL  : r_type_controls.alu_op = OP_SLL;
      SLT  : r_type_controls.alu_op = OP_SLT;
      SLTU : r_type_controls.alu_op = OP_SLTU;
      SRA  : r_type_controls.alu_op = OP_SRA;
      SRL  : r_type_controls.alu_op = OP_SRL;
      SUB  : r_type_controls.alu_op = OP_SUB;
      XOR  : r_type_controls.alu_op = OP_XOR;

      default: r_type_controls.alu_op = OP_ADD;
    endcase
  end

  // i-type
  always_comb begin
    i_type_controls          = '0;
    i_type_controls.rf_wr_en = 1'b1;
    i_type_controls.op2_sel  = 1'b1;

    unique case (i_type_e'({i_instr_opcode[4], i_instr_funct3}))
      ADDI : i_type_controls.alu_op = OP_ADD;
      ANDI : i_type_controls.alu_op = OP_AND;
      ORI  : i_type_controls.alu_op = OP_OR;
      SLLI : i_type_controls.alu_op = OP_SLL;
      SRXI : i_type_controls.alu_op = i_instr_funct7[5] ? OP_SRA : OP_SRL;
      SLTI : i_type_controls.alu_op = OP_SLT;
      SLTIU: i_type_controls.alu_op = OP_SLTU;
      XORI : i_type_controls.alu_op = OP_XOR;

      LB_JALR: begin
        i_type_controls.dmem_req       = 1'b1;
        i_type_controls.dmem_byte_en   = BYTE;
        i_type_controls.rf_wr_data_sel = MEM;
      end
      LH: begin
        i_type_controls.dmem_req       = 1'b1;
        i_type_controls.dmem_byte_en   = HALF_WORD;
        i_type_controls.rf_wr_data_sel = MEM;
      end
      LW: begin
        i_type_controls.dmem_req       = 1'b1;
        i_type_controls.dmem_byte_en   = WORD;
        i_type_controls.rf_wr_data_sel = MEM;
      end
      LBU: begin
        i_type_controls.dmem_req         = 1'b1;
        i_type_controls.dmem_byte_en     = BYTE;
        i_type_controls.rf_wr_data_sel   = MEM;
        i_type_controls.dmem_zero_extend = 1'b1;

      end
      LHU: begin
        i_type_controls.dmem_req         = 1'b1;
        i_type_controls.dmem_byte_en     = HALF_WORD;
        i_type_controls.rf_wr_data_sel   = MEM;
        i_type_controls.dmem_zero_extend = 1'b1;
      end

      default: i_type_controls = '0;
    endcase

    // JALR
    if ((i_instr_opcode == I_TYPE_2)) begin
      i_type_controls.rf_wr_data_sel = PC;
      i_type_controls.pc_sel         = 1'b1;
      i_type_controls.alu_op         = OP_ADD;
    end
  end

  // s-type
  always_comb begin
    s_type_controls            = '0;
    s_type_controls.dmem_req   = 1'b1;
    s_type_controls.dmem_wr_en = 1'b1;
    s_type_controls.op2_sel    = 1'b1;

    unique case(i_instr_funct3)
      SB : s_type_controls.dmem_byte_en = BYTE;
      SH : s_type_controls.dmem_byte_en = HALF_WORD;
      SW : s_type_controls.dmem_byte_en = WORD;

      default: s_type_controls = '0;
    endcase
  end

  // b-type
  always_comb begin
    b_type_controls         = '0;
    b_type_controls.alu_op  = OP_ADD;
    b_type_controls.op1_sel = 1'b1;
    b_type_controls.op2_sel = 1'b1;
  end

  // u-type
  always_comb begin
    u_type_controls          = '0;
    u_type_controls.rf_wr_en = 1'b1;

    unique case (i_instr_opcode)
      AUIPC : {u_type_controls.op2_sel, u_type_controls.op1_sel} = {1'b1, 1'b1};
      LUI   : u_type_controls.rf_wr_data_sel                     = IMM;

      default: u_type_controls = '0;
    endcase
  end

  // j-type
  always_comb begin
    j_type_controls                = '0;
    j_type_controls.rf_wr_en       = 1'b1;
    j_type_controls.rf_wr_data_sel = PC;
    j_type_controls.op2_sel        = 1'b1;
    j_type_controls.op1_sel        = 1'b1;
    j_type_controls.pc_sel         = 1'b1;
  end

  // output assignments
  always_comb begin
    unique case (1'b1)
      i_instr_r_type: o_controls = r_type_controls;
      i_instr_i_type: o_controls = i_type_controls;
      i_instr_s_type: o_controls = s_type_controls;
      i_instr_b_type: o_controls = b_type_controls;
      i_instr_u_type: o_controls = u_type_controls;
      i_instr_j_type: o_controls = j_type_controls;

      default : o_controls = '0;
    endcase
  end

endmodule
