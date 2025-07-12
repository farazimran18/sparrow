module tb_sparrow_top
  import sparrow_pkg::*;
#(
    parameter int RESET_PC = 32'h1000
) (
    input logic i_clk,
    input logic i_reset_n
);

  logic        imem_req;
  logic [31:0] imem_addr;
  logic [31:0] imem_rd_data;

  logic        dmem_req;
  logic [31:0] dmem_addr;
  logic [ 1:0] dmem_byte_en;
  logic        dmem_wr_en;
  logic [31:0] dmem_wr_data;
  logic [31:0] dmem_rd_data;

  sparrow_top #(
      .RESET_PC(RESET_PC)
  ) u_sparrow_top (
      .i_clk    (i_clk),
      .i_reset_n(i_reset_n),

      .o_imem_req    (imem_req),
      .o_imem_addr   (imem_addr),
      .i_imem_rd_data(imem_rd_data),

      .o_dmem_req    (dmem_req),
      .o_dmem_addr   (dmem_addr),
      .o_dmem_byte_en(dmem_byte_en),
      .o_dmem_wr_en  (dmem_wr_en),
      .o_dmem_wr_data(dmem_wr_data),
      .i_dmem_rd_data(dmem_rd_data)
  );

  // --- flop-based memory model ---
  localparam int MemDepthWords = 1024;  // 4kb memory

  // instruction memory
  logic [31:0] imem[MemDepthWords-1];
  assign imem_rd_data = imem_req ? imem[imem_addr] : '0;

  // data memory
  logic [31:0] dmem[MemDepthWords-1];
  assign dmem_rd_data = dmem_req ? dmem[dmem_addr] : '0;

  logic [31:0] current_word = dmem[dmem_addr];
  logic [31:0] new_word;

  always_ff @(posedge i_clk) begin
    dmem[dmem_addr] <= new_word;
  end

  always_comb begin
    if (dmem_req && dmem_wr_en) begin

      new_word = current_word;

      // Byte-level write support
      unique case (dmem_byte_en)
        BYTE: begin
          unique case (dmem_addr[1:0])
            2'b00: new_word[7:0] = dmem_wr_data[7:0];
            2'b01: new_word[15:8] = dmem_wr_data[7:0];
            2'b10: new_word[23:16] = dmem_wr_data[7:0];
            2'b11: new_word[31:24] = dmem_wr_data[7:0];
          endcase
        end
        HALF_WORD: begin
          unique case (dmem_addr[1:0])
            2'b00:   new_word[15:0] = dmem_wr_data[15:0];
            2'b10:   new_word[31:16] = dmem_wr_data[15:0];
            default: $fatal(1, "Unaligned half-word stores are not supported by RV32I");
          endcase
        end
        WORD: new_word = dmem_wr_data;
      endcase

    end
  end

endmodule
