package yarp_pkg;

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
    OP_ADD,
    OP_SUB,
    OP_SLL,
    OP_SRL,
    OP_SRA,
    OP_OR,
    OP_AND,
    OP_XOR,
    OP_SLTU,
    OP_SLT
  } alu_op_e;

  typedef enum logic [1:0] {
    BYTE      = 2'b00,
    HALF_WORD = 2'b01,
    WORD      = 2'b11
  } mem_access_size_e;

  // R Type
  // Formed using {funct7[5], funct3}
  typedef enum logic [3:0] {
    ADD  = 4'h0,
    AND  = 4'h7,
    OR   = 4'h6,
    SLL  = 4'h1,
    SLT  = 4'h2,
    SLTU = 4'h3,
    SRA  = 4'hd,
    SRL  = 4'h5,
    SUB  = 4'h8,
    XOR  = 4'h4
  } r_type_e;

  // I Type
  // Formed using {opcode[4], funct3}
  typedef enum logic [3:0] {
    LB    = 4'h0,
    LBU   = 4'h4,
    LH    = 4'h1,
    LHU   = 4'h5,
    LW    = 4'h2,
    ADDI  = 4'h8,
    ANDI  = 4'hf,
    ORI   = 4'he,
    SLLI  = 4'h9,
    SRXI  = 4'hd,
    SLTI  = 4'ha,
    SLTIU = 4'hb,
    XORI  = 4'hc
  } i_type_e;

  // S Type
  typedef enum logic [2:0] {
    SB = 3'h0,
    SH = 3'h1,
    SW = 3'h2
  } s_type_e;

  // B Type
  typedef enum logic [2:0] {
    BEQ  = 3'h0,
    BNE  = 3'h1,
    BLT  = 3'h4,
    BGE  = 3'h5,
    BLTU = 3'h6,
    BGEU = 3'h7
  } b_type_e;

  // U Type
  typedef enum logic [6:0] {
    AUIPC = 7'h17,
    LUI   = 7'h37
  } u_type_e;

  // J Type
  typedef enum logic [5:0] {JAL = 6'h3} j_type_e;

  typedef enum logic [1:0] {
    ALU = 2'b00,
    MEM = 2'b01,
    IMM = 2'b10,
    PC  = 2'b11
  } rf_wr_data_src_e;

  // Control signals
  typedef struct packed {
    logic             data_req;
    logic             data_wr;
    mem_access_size_e data_byte;
    logic             zero_extnd;
    logic             rf_wr_en;
    logic             pc_sel;
    logic             op1_sel;
    logic             op2_sel;
    rf_wr_data_src_e  rf_wr_data_sel;
    alu_op_e          alu_funct_sel;
  } control_t;

endpackage
