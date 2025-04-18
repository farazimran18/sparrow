import yarp_pkg::*;

// 2 read ports, 1 write port
module yarp_regfile (
    input logic clk,
    input logic reset_n,

    input  logic [4:0]      rs1_addr_i,
    output logic [XLEN-1:0] rs1_data_o,

    input  logic [4:0]      rs2_addr_i,
    output logic [XLEN-1:0] rs2_data_o,

    input logic [4:0]      rd_addr_i,
    input logic            wr_en_i,
    input logic [XLEN-1:0] wr_data_i
  );

  logic [31:0] [XLEN-1:0] regfile_d, regfile_q;
  logic [31:0]            regfile_en;

  generate
    for (genvar i = 0; i < 32; i++) begin: g_registers

      always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
          regfile_q[i] <= '0;
        end else begin
          regfile_q[i] <= regfile_d[i];
        end
      end

      // register X0 is not writable
      assign regfile_en[i] = (i == '0) ? '0 : (wr_en_i & (i == rd_addr_i));
      assign regfile_d[i]  = regfile_en[i] ? wr_data_i : regfile_q[i];

    end
  endgenerate

  assign rs1_data_o = regfile_q[rs1_addr_i];
  assign rs2_data_o = regfile_q[rs2_addr_i];

endmodule
