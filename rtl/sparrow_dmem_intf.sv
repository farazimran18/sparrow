module sparrow_dmem_intf
  import sparrow_pkg::*;
  (
    // request from current instruction
    input  logic                    i_instr_req,
    input  logic             [31:0] i_instr_addr,
    input  mem_access_size_e        i_instr_byte_en,
    input  logic                    i_instr_wr_en,
    input  logic             [31:0] i_instr_wr_data,
    output logic             [31:0] o_instr_rd_data,
    input  logic                    i_instr_zero_extend,

    // rd/wr request to memory
    output logic        o_dmem_req,
    output logic [31:0] o_dmem_addr,
    output logic [ 1:0] o_dmem_byte_en,
    output logic        o_dmem_wr_en,
    output logic [31:0] o_dmem_wr_data,
    input  logic [31:0] i_dmem_rd_data
  );

  assign o_dmem_req     = i_instr_req;
  assign o_dmem_addr    = i_instr_addr;
  assign o_dmem_byte_en = i_instr_byte_en;
  assign o_dmem_wr_en   = i_instr_wr_en;
  assign o_dmem_wr_data = i_instr_wr_data;

  always_comb begin
    unique case (i_instr_byte_en)
      BYTE: begin
        o_instr_rd_data = i_instr_zero_extend ?
          {24'h0, i_dmem_rd_data[7:0]} :
          {{24{i_dmem_rd_data[7]}}, i_dmem_rd_data[7:0]};
      end
      HALF_WORD: begin
        o_instr_rd_data = i_instr_zero_extend ?
          {16'h0, i_dmem_rd_data[15:0]} :
          {{16{i_dmem_rd_data[15]}}, i_dmem_rd_data[15:0]};
      end
      WORD   : o_instr_rd_data = i_dmem_rd_data;
      default: o_instr_rd_data = '0;
    endcase
  end

endmodule
