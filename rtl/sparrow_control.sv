module sparrow_control
  import sparrow_pkg::*;
  (
    // Instruction type
    input logic is_r_type_i,
    input logic is_i_type_i,
    input logic is_s_type_i,
    input logic is_b_type_i,
    input logic is_u_type_i,
    input logic is_j_type_i,

    // Instruction opcode/funct fields
    input logic [2:0] instr_funct3_i,
    input logic       instr_funct7_bit5_i,
    input logic [6:0] instr_opcode_i,

    // Control signals
    output control_t controls_o
  );

  // Internal signals
  r_type_e instr_funct;
  i_type_e instr_opc;

  control_t r_type_controls;
  control_t i_type_controls;
  control_t s_type_controls;
  control_t b_type_controls;
  control_t u_type_controls;
  control_t j_type_controls;

  // R-type
  assign instr_funct = r_type_e'({instr_funct7_bit5_i, instr_funct3_i});
  always_comb begin
    r_type_controls          = '0;
    r_type_controls.rf_wr_en = 1'b1;
    case (instr_funct)
      ADD    : r_type_controls.alu_funct_sel = OP_ADD;
      AND    : r_type_controls.alu_funct_sel = OP_AND;
      OR     : r_type_controls.alu_funct_sel = OP_OR;
      SLL    : r_type_controls.alu_funct_sel = OP_SLL;
      SLT    : r_type_controls.alu_funct_sel = OP_SLT;
      SLTU   : r_type_controls.alu_funct_sel = OP_SLTU;
      SRA    : r_type_controls.alu_funct_sel = OP_SRA;
      SRL    : r_type_controls.alu_funct_sel = OP_SRL;
      SUB    : r_type_controls.alu_funct_sel = OP_SUB;
      XOR    : r_type_controls.alu_funct_sel = OP_XOR;
      default: r_type_controls.alu_funct_sel = OP_ADD;
    endcase
  end

  // I-type
  assign instr_opc = i_type_e'({instr_opcode_i[4], instr_funct3_i});
  always_comb begin
    i_type_controls          = '0;
    i_type_controls.rf_wr_en = 1'b1;
    i_type_controls.op2_sel  = 1'b1;
    case (instr_opc)
      ADDI : i_type_controls.alu_funct_sel = OP_ADD;
      ANDI : i_type_controls.alu_funct_sel = OP_AND;
      ORI  : i_type_controls.alu_funct_sel = OP_OR;
      SLLI : i_type_controls.alu_funct_sel = OP_SLL;
      SRXI : i_type_controls.alu_funct_sel = instr_funct7_bit5_i ? OP_SRA : OP_SRL;
      SLTI : i_type_controls.alu_funct_sel = OP_SLT;
      SLTIU: i_type_controls.alu_funct_sel = OP_SLTU;
      XORI : i_type_controls.alu_funct_sel = OP_XOR;

      LB: begin
        i_type_controls.data_req       = 1'b1;
        i_type_controls.data_byte      = BYTE;
        i_type_controls.rf_wr_data_sel = MEM;
      end
      LH: begin
        i_type_controls.data_req       = 1'b1;
        i_type_controls.data_byte      = HALF_WORD;
        i_type_controls.rf_wr_data_sel = MEM;
      end
      LW: begin
        i_type_controls.data_req       = 1'b1;
        i_type_controls.data_byte      = WORD;
        i_type_controls.rf_wr_data_sel = MEM;
      end
      LBU: begin
        i_type_controls.data_req       = 1'b1;
        i_type_controls.data_byte      = BYTE;
        i_type_controls.rf_wr_data_sel = MEM;
        i_type_controls.zero_extnd     = 1'b1;

      end
      LHU: begin
        i_type_controls.data_req       = 1'b1;
        i_type_controls.data_byte      = HALF_WORD;
        i_type_controls.rf_wr_data_sel = MEM;
        i_type_controls.zero_extnd     = 1'b1;
      end
      default: i_type_controls = '0;
    endcase

    // JALR
    if ((instr_opcode_i == I_TYPE_2)) begin
      i_type_controls.rf_wr_data_sel = PC;
      i_type_controls.pc_sel         = 1'b1;
      i_type_controls.alu_funct_sel  = OP_ADD;
    end
  end

  // S-type
  always_comb begin
    s_type_controls          = '0;
    s_type_controls.data_req = 1'b1;
    s_type_controls.data_wr  = 1'b1;
    s_type_controls.op2_sel  = 1'b1;
    case (instr_funct3_i)
      SB     : s_type_controls.data_byte = BYTE;
      SH     : s_type_controls.data_byte = HALF_WORD;
      SW     : s_type_controls.data_byte = WORD;
      default: s_type_controls           = '0;
    endcase
  end

  // B-type
  always_comb begin
    b_type_controls               = '0;
    b_type_controls.alu_funct_sel = OP_ADD;
    b_type_controls.op1_sel       = 1'b1;
    b_type_controls.op2_sel       = 1'b1;
  end

  // U-type
  always_comb begin
    u_type_controls          = '0;
    u_type_controls.rf_wr_en = 1'b1;
    case (instr_opcode_i)
      AUIPC  : {u_type_controls.op2_sel, u_type_controls.op1_sel} = {1'b1, 1'b1};
      LUI    : u_type_controls.rf_wr_data_sel                     = IMM;
      default: u_type_controls                                    = '0;
    endcase
  end

  // J-type
  always_comb begin
    j_type_controls                = '0;
    j_type_controls.rf_wr_en       = 1'b1;
    j_type_controls.rf_wr_data_sel = PC;
    j_type_controls.op2_sel        = 1'b1;
    j_type_controls.op1_sel        = 1'b1;
    j_type_controls.pc_sel         = 1'b1;
  end

  // Output assignments
  always_comb begin
    unique case (1'b1)
      is_r_type_i: controls_o = r_type_controls;
      is_i_type_i: controls_o = i_type_controls;
      is_s_type_i: controls_o = s_type_controls;
      is_b_type_i: controls_o = b_type_controls;
      is_u_type_i: controls_o = u_type_controls;
      is_j_type_i: controls_o = j_type_controls;
      default    : controls_o = '0;
    endcase
  end

endmodule
