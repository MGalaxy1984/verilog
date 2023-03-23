// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (
        clk, 
        width_mode, 
        sign_mode, 
        sum_out, 
        mem_in, 
        out, 
        tb_inst, 
        reset, 
        width_mode, 
        sign_mode,
        oc_clk,
        oc_sfu_fifo_rd,
        oc_sfu_fifo_empty,
        oc_sfu_sum,
        tc_sfu_fifo_rd,
        tc_sfu_fifo_empty,
        tc_sfu_sum,
        done
);

parameter index = 0;
parameter col = 8;
parameter bw = 4;
parameter bw_psum = 2*bw+4;
parameter pr = 8;
parameter total_cycle = 8;

output [bw_psum+6:0] sum_out;
output [bw_psum*col-1:0] out;
wire   [bw_psum*col-1:0] pmem_out;
input  [pr*bw-1:0] mem_in;
input  clk;
// input width_mode, sign_mode;
input  [18:0] tb_inst; 
input  reset;
input width_mode; // 0 = 4bits, 1 = 8 bits
input sign_mode; // 0 = unsigned, 1 = signed

input                oc_clk;
input                oc_sfu_fifo_rd;
input                oc_sfu_fifo_empty;
input [bw_psum+3:0]  oc_sfu_sum;

output               tc_sfu_fifo_rd;
output               tc_sfu_fifo_empty;
output [bw_psum+3:0] tc_sfu_sum;

output done;

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] sfp_out;
wire  [bw_psum*col-1:0] array_out;
wire  [col-1:0] fifo_wr;
wire  ofifo_rd;
wire [3:0] qkmem_add;
wire [3:0] qmem_add;
wire [3:0] kmem_add;
wire [3:0] pmem_add;

assign out = sfp_out;

wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr; 

assign kmem_add = inst[22:19];
assign ofifo_rd = inst[16];
assign qmem_add = inst[15:12];
assign pmem_add = inst[11:8];

assign qmem_rd = inst[5];
assign qmem_wr = inst[4];
assign kmem_rd = inst[3];
assign kmem_wr = inst[2];
assign pmem_rd = inst[1];
assign pmem_wr = inst[0];

assign mac_in  = inst[6] ? kmem_out : qmem_out;
assign pmem_in = sfp_out;

wire [22:0] inst;
// assign inst = ctrl_inst;

assign inst[18:0] = tb_inst;
assign inst[22:19] = tb_inst[15:12];

wire fifo_valid;

mac_array #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) mac_array_instance (
        .in(mac_in), 
        .clk(clk), 
        .reset(reset), 
        .inst(inst[7:6]),     
        .fifo_wr(fifo_wr),     
        .out(array_out),
        .width_mode(width_mode),
        .sign_mode(sign_mode)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(clk),
        .in(array_out),
        .wr(fifo_wr),
        .rd(ofifo_rd),
        .o_valid(fifo_valid),
        .out(fifo_out)
);

sfu #(.bw(bw), .bw_psum(bw_psum), .col(col)) sfu_instance (
        .clk(clk), 
        .reset(reset), 
        .acc(inst[17]), 
        .div(inst[18]), 
        .width_mode(width_mode), 
        .sign_mode(sign_mode), 
        .sum_out(sum_out), 
        .sfp_in(fifo_out), 
        .sfp_out(sfp_out),
        .oc_clk(oc_clk),
        .oc_sfu_fifo_rd(oc_sfu_fifo_rd),
        .oc_sfu_fifo_empty(oc_sfu_fifo_empty),
        .oc_sfu_sum(oc_sfu_sum),
        .tc_sfu_fifo_rd(tc_sfu_fifo_rd),
        .tc_sfu_fifo_empty(tc_sfu_fifo_empty),
        .tc_sfu_sum(tc_sfu_sum),
        .ofifo_valid(fifo_valid)
);


sram_w16 #(.sram_bit(pr*bw)) qmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(qmem_out),
        .CEN(!(qmem_rd||qmem_wr)),
        .WEN(!qmem_wr), 
        .A(qmem_add)
);

sram_w16 #(.sram_bit(pr*bw)) kmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(kmem_out),
        .CEN(!(kmem_rd||kmem_wr)),
        .WEN(!kmem_wr), 
        .A(kmem_add)
);

sram_w16 #(.sram_bit(col*bw_psum)) psum_mem_instance (
        .CLK(clk),
        .D(pmem_in),
        .Q(pmem_out),
        .CEN(!(pmem_rd||pmem_wr)),
        .WEN(!pmem_wr), 
        .A(pmem_add)
);

wire [22:0] ctrl_inst;

controller #(.col(col), .total_cycle(total_cycle)) ctrl (
        .clk(clk),
        .reset(reset),
        .done(done),
        .controller_inst(ctrl_inst)
);



  //////////// For printing purpose ////////////
  always @(posedge clk) begin
      if(pmem_wr)
         $display("Memory write to core %2d, PSUM mem add %x %x ", index, pmem_add, pmem_in); 
  end



endmodule
