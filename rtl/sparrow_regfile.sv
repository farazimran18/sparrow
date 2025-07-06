// 2 read ports, 1 write port
module sparrow_regfile
  import sparrow_pkg::*;
(
    input logic i_clk,
    input logic i_reset_n,

    input  logic [ 4:0] i_rd1_addr,
    output logic [31:0] o_rd1_data,

    input  logic [ 4:0] i_rd2_addr,
    output logic [31:0] o_rd2_data,

    input logic        i_wr_en,
    input logic [ 4:0] i_wr_addr,
    input logic [31:0] i_wr_data
);

  logic [31:0][31:0] regfile_d, regfile_q;
  logic [31:0] regfile_en;

  generate
    for (genvar i = 0; i < 32; i++) begin : g_registers

      always_ff @(posedge i_clk or negedge i_reset_n) begin
        if (!i_reset_n) begin
          regfile_q[i] <= '0;
        end else begin
          regfile_q[i] <= regfile_d[i];
        end
      end

      // register X0 is not writable
      assign regfile_en[i] = (i == '0) ? '0 : (i_wr_en & (i == i_wr_addr));
      assign regfile_d[i]  = regfile_en[i] ? i_wr_data : regfile_q[i];

    end
  endgenerate

  assign o_rd1_data = regfile_q[i_rd1_addr];
  assign o_rd2_data = regfile_q[i_rd2_addr];

endmodule
