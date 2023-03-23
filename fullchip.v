// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk_core0, clk_core1, width_mode, sign_mode, mem_in_core0, mem_in_core1, inst_core0, inst_core1, reset, out, sum_out);

parameter col = 8;
parameter bw = 4;
parameter bw_psum = 2*bw+4;
parameter pr = 8;

input  clk_core0, clk_core1; 
input width_mode; // 0 = 4bits, 1 = 8 bits
input sign_mode; // 0 = unsigned, 1 = signed
input  [pr*bw-1:0] mem_in_core0;
input  [pr*bw-1:0] mem_in_core1;
input  [18:0] inst_core0; 
input  [18:0] inst_core1;
input  reset;
output [bw_psum+6:0] sum_out;
output [bw_psum*col*2-1:0] out;

wire clk_core0, clk_core1;
// assign clk_core0 = clk;
// assign clk_core1 = clk;

wire [bw_psum*col-1:0]  out_core0;
wire [bw_psum*col-1:0]  out_core1;
assign out = {out_core0, out_core1};

wire [bw_psum+6:0] sum_out_core0;
wire [bw_psum+6:0] sum_out_core1;
assign sum_out = sum_out_core0;

wire sfu_fifo_rd_core0, sfu_fifo_rd_core1;
wire syn_sfu_fifo_rd_core0, syn_sfu_fifo_rd_core1;

wire sfu_fifo_empty_core0, sfu_fifo_empty_core1;
wire syn_sfu_fifo_empty_core0, syn_sfu_fifo_empty_core1;

sync sync_rd_core0 (
      .clk(clk_core1),
      .in(sfu_fifo_rd_core0),
      .out(syn_sfu_fifo_rd_core0) 
);

sync sync_rd_core1 (
      .clk(clk_core0),
      .in(sfu_fifo_rd_core1),
      .out(syn_sfu_fifo_rd_core1) 
);

sync sync_empty_core0 (
      .clk(clk_core1),
      .in(sfu_fifo_empty_core0),
      .out(syn_sfu_fifo_empty_core0) 
);

sync sync_empty_core1 (
      .clk(clk_core0),
      .in(sfu_fifo_empty_core1),
      .out(syn_sfu_fifo_empty_core1) 
);

wire [bw_psum+3:0] sfu_sum_core0, sfu_sum_core1;

core #(.index(0), .bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core0 (
      .reset(reset), 
      .clk(clk_core0), 
      .width_mode(width_mode),
      .sign_mode(sign_mode),
      .mem_in(mem_in_core0), 
      .inst(inst_core0),
      .out(out_core0),
      .sum_out(sum_out_core0),
      .oc_clk(clk_core1),
      // .oc_sfu_fifo_rd(syn_sfu_fifo_rd_core1),
      // .oc_sfu_fifo_empty(syn_sfu_fifo_empty_core1),
      .oc_sfu_fifo_rd(sfu_fifo_rd_core1),
      .oc_sfu_fifo_empty(sfu_fifo_empty_core1),
      .oc_sfu_sum(sfu_sum_core1),
      .tc_sfu_fifo_rd(sfu_fifo_rd_core0),
      .tc_sfu_fifo_empty(sfu_fifo_empty_core0),
      .tc_sfu_sum(sfu_sum_core0)
);

core #(.index(1), .bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core1 (
      .reset(reset), 
      .clk(clk_core1), 
      .width_mode(width_mode),
      .sign_mode(sign_mode),
      .mem_in(mem_in_core1), 
      .inst(inst_core1),
      .out(out_core1),
      .sum_out(sum_out_core1),
      .oc_clk(clk_core0),
      .oc_sfu_fifo_rd(sfu_fifo_rd_core0),
      .oc_sfu_fifo_empty(sfu_fifo_empty_core0),
      // .oc_sfu_fifo_rd(syn_sfu_fifo_rd_core0),
      // .oc_sfu_fifo_empty(syn_sfu_fifo_empty_core0),
      .oc_sfu_sum(sfu_sum_core0),
      .tc_sfu_fifo_rd(sfu_fifo_rd_core1),
      .tc_sfu_fifo_empty(sfu_fifo_empty_core1),
      .tc_sfu_sum(sfu_sum_core1)
);

endmodule
