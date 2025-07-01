module yarp_data_mem
  import yarp_pkg::*;
(
    input logic clk,
    input logic reset_n,

    // Data request from current instruction
    input  logic        data_req_i,
    input  logic [31:0] data_addr_i,
    input  logic [ 1:0] data_byte_en_i,
    input  logic        data_wr_i,
    input  logic [31:0] data_wr_data_i,
    output logic [31:0] data_mem_rd_data_o, // Data output

    input logic data_zero_extnd_i,

    // Read/Write request to memory
    output logic        data_mem_req_o,
    output logic [31:0] data_mem_addr_o,
    output logic [ 1:0] data_mem_byte_en_o,
    output logic        data_mem_wr_o,
    output logic [31:0] data_mem_wr_data_o,
    input  logic [31:0] mem_rd_data_i        // Read data from memory
);

  assign data_mem_req_o     = data_req_i;
  assign data_mem_addr_o    = data_addr_i;
  assign data_mem_byte_en_o = data_byte_en_i;
  assign data_mem_wr_o      = data_wr_i;
  assign data_mem_wr_data_o = data_wr_data_i;

  mem_access_size_e access_size;
  assign access_size = mem_access_size_e'(data_byte_en_i);

  always_comb begin
    unique case (access_size)
      BYTE: begin
        data_mem_rd_data_o = data_zero_extnd_i ?
                             {24'h0, mem_rd_data_i[7:0]} :
                             {{24{mem_rd_data_i[7]}}, mem_rd_data_i[7:0]};
      end
      HALF_WORD: begin
        data_mem_rd_data_o = data_zero_extnd_i ?
                             {16'h0, mem_rd_data_i[15:0]} :
                             {{16{mem_rd_data_i[15]}}, mem_rd_data_i[15:0]};
      end
      WORD:    data_mem_rd_data_o = mem_rd_data_i;
      default: data_mem_rd_data_o = '0;
    endcase
  end

endmodule
