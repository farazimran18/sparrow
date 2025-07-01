module yarp_data_mem
  import yarp_pkg::*;
(
    input logic clk,
    input logic reset_n,

    // Data request from current instruction
    input logic        data_req_i,
    input logic [31:0] data_addr_i,
    input logic [ 1:0] data_byte_en_i,
    input logic        data_wr_i,
    input logic [31:0] data_wr_data_i,

    input logic data_zero_extnd_i,

    // Read/Write request to memory
    output logic        data_mem_req_o,
    output logic [31:0] data_mem_addr_o,
    output logic [ 1:0] data_mem_byte_en_o,
    output logic        data_mem_wr_o,
    output logic [31:0] data_mem_wr_data_o,
    // Read data from memory
    input  logic [31:0] mem_rd_data_i,

    // Data output
    output logic [31:0] data_mem_rd_data_o
);

  // Write your logic here...

endmodule
