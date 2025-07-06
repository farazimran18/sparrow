module tb_sparrow_top
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

  sparrow_top #(
      .RESET_PC(RESET_PC)
  ) u_sparrow_top (
      .i_clk    (i_clk),
      .i_reset_n(i_reset_n),

      .o_imem_req    (o_imem_req),
      .o_imem_addr   (o_imem_addr),
      .i_imem_rd_data(i_imem_rd_data),

      .o_dmem_req    (o_dmem_req),
      .o_dmem_addr   (o_dmem_addr),
      .o_dmem_byte_en(o_dmem_byte_en),
      .o_dmem_wr_en  (o_dmem_wr_en),
      .o_dmem_wr_data(o_dmem_wr_data),
      .i_dmem_rd_data(i_dmem_rd_data)
  );

endmodule
