module sparrow_imem_intf
  import sparrow_pkg::*;
(
    input logic i_clk,
    input logic i_reset_n,

    input  logic [31:0] i_imem_pc,
    output logic [31:0] o_instr,

    output logic        o_imem_req,
    output logic [31:0] o_imem_addr,
    input  logic [31:0] i_imem_rd_data
);

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if (!i_reset_n) begin
      o_imem_req <= '0;
    end else begin
      o_imem_req <= '1;
    end
  end

  assign o_imem_addr = i_imem_pc;
  assign o_instr     = i_imem_rd_data;

endmodule
