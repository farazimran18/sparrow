package sparrow_pkg;

  typedef enum logic [6:0] {
    R_TYPE   = 7'h33,
    I_TYPE_0 = 7'h03,
    I_TYPE_1 = 7'h13,
    I_TYPE_2 = 7'h67,
    S_TYPE   = 7'h23,
    B_TYPE   = 7'h63,
    U_TYPE_0 = 7'h37,
    U_TYPE_1 = 7'h17,
    J_TYPE   = 7'h6F
  } riscv_op_e;

  typedef enum logic [3:0] {
    OP_ADD,   // add
    OP_SUB,   // subtract
    OP_SLL,   // shift left logical
    OP_SRL,   // shift right logical
    OP_SRA,   // shift right arithmetic
    OP_OR,    // bitwise or
    OP_AND,   // bitwise and
    OP_XOR,   // bitwise xor
    OP_SLTU,  // set on less than unsigned
    OP_SLT    // set on less than
  } alu_op_e;

  typedef enum logic [1:0] {
    BYTE      = 2'b00,  // 1 byte
    HALF_WORD = 2'b01,  // 2 bytes
    WORD      = 2'b11   // 4 bytes
  } mem_access_size_e;

  // r type - {funct7[5], funct3[2:0]}
  typedef enum logic [3:0] {
    ADD  = {1'b0, 3'h0},
    SUB  = {1'b1, 3'h0},
    SLL  = {1'b0, 3'h1},
    SLT  = {1'b0, 3'h2},
    SLTU = {1'b0, 3'h3},
    XOR  = {1'b0, 3'h4},
    SRL  = {1'b0, 3'h5},
    SRA  = {1'b1, 3'h5},
    OR   = {1'b0, 3'h6},
    AND  = {1'b0, 3'h7}
  } r_type_e;

  // i type - {opcode[4], funct3[2:0]}
  typedef enum logic [3:0] {
    LB_JALR = {1'b0, 3'h0},  // LB/JALR - check opcode[2]
    LH      = {1'b0, 3'h1},
    LW      = {1'b0, 3'h2},
    LBU     = {1'b0, 3'h4},
    LHU     = {1'b0, 3'h5},
    ADDI    = {1'b1, 3'h0},
    SLLI    = {1'b1, 3'h1},  // check funct7
    SLTI    = {1'b1, 3'h2},
    SLTIU   = {1'b1, 3'h3},
    XORI    = {1'b1, 3'h4},
    SRXI    = {1'b1, 3'h5},  // SRLI/SRAI - check funct7
    ORI     = {1'b1, 3'h6},
    ANDI    = {1'b1, 3'h7}
  } i_type_e;

  // s type - funct3[2:0]
  typedef enum logic [2:0] {
    SB = 3'h0,
    SH = 3'h1,
    SW = 3'h2
  } s_type_e;

  // b type - funct3[2:0]
  typedef enum logic [2:0] {
    BEQ  = 3'h0,  // branch if =
    BNE  = 3'h1,  // branch if ≠
    BLT  = 3'h4,  // branch if <
    BGE  = 3'h5,  // branch if ≥
    BLTU = 3'h6,  // branch if < unsigned
    BGEU = 3'h7   // branch if ≥ unsigned
  } b_type_e;

  // u type
  typedef enum logic [6:0] {
    AUIPC = 7'h17,
    LUI   = 7'h37
  } u_type_e;

  typedef enum logic [1:0] {
    ALU = 2'b00,
    MEM = 2'b01,
    IMM = 2'b10,
    PC  = 2'b11   // next PC
  } rf_wr_data_src_e;

  // control signals
  typedef struct packed {
    logic dmem_req;
    logic dmem_wr_en;
    mem_access_size_e dmem_byte_en;
    logic dmem_zero_extend;
    logic rf_wr_en;
    rf_wr_data_src_e rf_wr_data_sel;  // select dest reg data source
    logic pc_sel;  // select between sequential (PC+4, default) or branch/jump PC source
    logic alu_op1_sel;  // select between current PC and rs1 (default)
    logic alu_op2_sel;  // select between instr immediate and rs2 (default)
    alu_op_e alu_op;
  } control_t;

endpackage
