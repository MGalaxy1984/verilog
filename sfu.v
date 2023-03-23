// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfu (
  clk, 
  reset, 
  acc, 
  div, 
  width_mode, 
  sign_mode, 
  sum_out, 
  sfp_in, 
  sfp_out,
  oc_clk,
  oc_sfu_fifo_rd,
  oc_sfu_fifo_empty,
  oc_sfu_sum,
  tc_sfu_fifo_rd,
  tc_sfu_fifo_empty,
  tc_sfu_sum,
  ofifo_valid
);

    parameter col = 8;
    parameter bw = 4;
    parameter bw_psum = 2*bw+4; //12

    input  clk;
    input  reset;
    input  div, acc;  //, exchange;
    
    input width_mode, sign_mode;

    input  [col*bw_psum-1:0] sfp_in; //95:0
    output [col*bw_psum-1:0] sfp_out; //95:0

    output [bw_psum+4:0] sum_out;

    input ofifo_valid;

    input                oc_clk;
    input                oc_sfu_fifo_rd;
    input                oc_sfu_fifo_empty;
    input [bw_psum+3:0]  oc_sfu_sum;

    output               tc_sfu_fifo_rd;
    output               tc_sfu_fifo_empty;
    output [bw_psum+3:0] tc_sfu_sum;

    //assign sfp_out = sfp_in;

    // reg [bw_psum+7:0] sum_q; //19:0
    // wire [bw_psum+7:0] sum_q; //19:0
    // reg fifo_wr;
    // reg div_q;
    // wire [bw_psum+3:0] sum_this_core; // 15:0
    // wire  [col*(bw_psum+4)-1:0] abs; //95:0 12 each
    //wire  [col*bw_psum-1:0] sfp_in_width8; //95:0 

    // wire  [bw_psum+3:0] sfp_in_0_width8; //15:0
    // wire  [bw_psum+3:0] sfp_in_1_width8;
    // wire  [bw_psum+3:0] sfp_in_2_width8;
    // wire  [bw_psum+3:0] sfp_in_3_width8;
    // wire  [bw_psum+3:0] sfp_in_4_width8;
    // wire  [bw_psum+3:0] sfp_in_5_width8;
    // wire  [bw_psum+3:0] sfp_in_6_width8;
    // wire  [bw_psum+3:0] sfp_in_7_width8;

    // wire [col*(bw_psum+4)-1:0] sfu_in_width_process;
    // wire [4*(bw_psum+5)-1:0] sfu_in_width8;
    // wire [col*(bw_psum+4)-1:0] sfu_in_abs_process_0;
    // wire [col*(bw_psum+4)-1:0] sfu_in_abs_process_1;

    genvar i;

    // wire [bw_psum + 7: 0] sum_value;
    // wire [col*(bw_psum)-1:0] norm_value;
    // assign sfp_out = norm_value;

    // generate
      // if (!width_mode && !sign_mode) begin
      //   assign sum_value = sfp_in[(bw_psum)*1-1:(bw_psum)*0]
      //                     + sfp_in[(bw_psum)*2-1:(bw_psum)*1]
      //                     + sfp_in[(bw_psum)*3-1:(bw_psum)*2]
      //                     + sfp_in[(bw_psum)*4-1:(bw_psum)*3]
      //                     + sfp_in[(bw_psum)*5-1:(bw_psum)*4]
      //                     + sfp_in[(bw_psum)*6-1:(bw_psum)*5]
      //                     + sfp_in[(bw_psum)*7-1:(bw_psum)*6]
      //                     + sfp_in[(bw_psum)*8-1:(bw_psum)*7];
      //   assign norm_value[(bw_psum)*1-1:(bw_psum)*0] = {sfp_in[(bw_psum)*1-1:(bw_psum)*0], 8'b0} / sum_value;
      //   assign norm_value[(bw_psum)*2-1:(bw_psum)*1] = {sfp_in[(bw_psum)*2-1:(bw_psum)*1], 8'b0} / sum_value;
      //   assign norm_value[(bw_psum)*3-1:(bw_psum)*2] = {sfp_in[(bw_psum)*3-1:(bw_psum)*2], 8'b0} / sum_value;
      //   assign norm_value[(bw_psum)*4-1:(bw_psum)*3] = {sfp_in[(bw_psum)*4-1:(bw_psum)*3], 8'b0} / sum_value;
      //   assign norm_value[(bw_psum)*5-1:(bw_psum)*4] = {sfp_in[(bw_psum)*5-1:(bw_psum)*4], 8'b0} / sum_value;
      //   assign norm_value[(bw_psum)*6-1:(bw_psum)*5] = {sfp_in[(bw_psum)*6-1:(bw_psum)*5], 8'b0} / sum_value;
      //   assign norm_value[(bw_psum)*7-1:(bw_psum)*6] = {sfp_in[(bw_psum)*7-1:(bw_psum)*6], 8'b0} / sum_value;
      //   assign norm_value[(bw_psum)*8-1:(bw_psum)*7] = {sfp_in[(bw_psum)*8-1:(bw_psum)*7], 8'b0} / sum_value;
      // end
      // else if (!width_mode && sign_mode) begin
      // end
    // endgenerate

    assign sfp_out = width_mode ? sfu_abs_value : width_4_norm;

    wire [col*(bw_psum)-1:0] width_4_abs_value;
    wire [col*(bw_psum)-1:0] tmp_width_4_abs_value;

    generate
      for (i=0; i < col; i=i+1) begin: BIT_4_ABS_PROCESS
        assign tmp_width_4_abs_value[(bw_psum)*(i+1)-1:(bw_psum)*(i)] = 
          (sfp_in[(bw_psum)*(i+1)-1]) ?  
          (~sfp_in[(bw_psum)*(i+1)-1:(bw_psum)*(i)] + 1) :  
          sfp_in[(bw_psum)*(i+1)-1:(bw_psum)*(i)];

        assign width_4_abs_value[(bw_psum)*(i+1)-1:(bw_psum)*(i)] = 
          sign_mode ? 
          tmp_width_4_abs_value[(bw_psum)*(i+1)-1:(bw_psum)*(i)] : 
          sfp_in[(bw_psum)*(i+1)-1:(bw_psum)*(i)];
      end
    endgenerate

    wire [bw_psum+3:0] width_4_sum;
    wire [col*bw_psum-1:0] width_4_norm;

    wire [bw_psum:0] quarter_sum0, quarter_sum1, quarter_sum2, quarter_sum3;
    assign quarter_sum0 = {width_4_abs_value[(bw_psum)*1-1 : (bw_psum)*0]} + {width_4_abs_value[(bw_psum)*2-1 : (bw_psum)*1]};
    assign quarter_sum1 = {width_4_abs_value[(bw_psum)*3-1 : (bw_psum)*2]} + {width_4_abs_value[(bw_psum)*4-1 : (bw_psum)*3]};
    assign quarter_sum2 = {width_4_abs_value[(bw_psum)*5-1 : (bw_psum)*4]} + {width_4_abs_value[(bw_psum)*6-1 : (bw_psum)*5]};
    assign quarter_sum3 = {width_4_abs_value[(bw_psum)*7-1 : (bw_psum)*6]} + {width_4_abs_value[(bw_psum)*8-1 : (bw_psum)*7]};
                
    wire [bw_psum + 1:0] semi_sum0, semi_sum1;
    assign semi_sum0 = quarter_sum0 + quarter_sum1;
    assign semi_sum1 = quarter_sum2 + quarter_sum3;

    assign width_4_sum = semi_sum0 + semi_sum1;

    // assign width_4_sum = 
    //   {4'b0, width_4_abs_value[(bw_psum)*1-1 : (bw_psum)*0]} +
    //   {4'b0, width_4_abs_value[(bw_psum)*2-1 : (bw_psum)*1]} +
    //   {4'b0, width_4_abs_value[(bw_psum)*3-1 : (bw_psum)*2]} +
    //   {4'b0, width_4_abs_value[(bw_psum)*4-1 : (bw_psum)*3]} +
    //   {4'b0, width_4_abs_value[(bw_psum)*5-1 : (bw_psum)*4]} +
    //   {4'b0, width_4_abs_value[(bw_psum)*6-1 : (bw_psum)*5]} +
    //   {4'b0, width_4_abs_value[(bw_psum)*7-1 : (bw_psum)*6]} +
    //   {4'b0, width_4_abs_value[(bw_psum)*8-1 : (bw_psum)*7]} ;

    // generate
    //   for (i=0; i < col; i=i+1) begin: BIT_4_NORM
    //     assign width_4_norm[(bw_psum)*(i+1)-1:(bw_psum)*(i)] = {width_4_abs_value[(bw_psum)*(i+1)-1 : (bw_psum)*i], 12'b0} / width_4_sum;
    //   end
    // endgenerate

    wire [bw_psum+4:0] width_4_2_core_sum;
    assign width_4_2_core_sum = oc_sfu_sum + sfu_sum;
    assign sum_out = width_4_2_core_sum;

    generate
      for (i=0; i < col; i=i+1) begin: BIT_4_NORM
        assign width_4_norm[(bw_psum)*(i+1)-1:(bw_psum)*(i)] = {sfu_abs_value[(bw_psum)*(i+1)-1 : (bw_psum)*i], 12'b0} / width_4_2_core_sum;
      end
    endgenerate




    wire [4*(2*bw_psum)-1:0] width_8_in;

    generate
      for (i = 0; i < 4; i=i+1) begin: BIT_8_INPUT_PROCESS
        assign width_8_in[(2*bw_psum)*(i+1)-1:(2*bw_psum)*(i)] = 
          sign_mode ? 
          {{(bw_psum-4){sfp_in[(bw_psum)*(i*2+2)-1]}}, sfp_in[(bw_psum)*(i*2+2)-1:(bw_psum)*(i*2+1)], 4'b0000} + {{(bw_psum){sfp_in[(bw_psum)*(i*2+1)-1]}}, sfp_in[(bw_psum)*(i*2+1)-1:(bw_psum)*(i*2)]} :
          {sfp_in[(bw_psum)*(i*2+2)-1:(bw_psum)*(i*2+1)], 4'b0000} + {4'b0000, sfp_in[(bw_psum)*(i*2+1)-1:(bw_psum)*(i*2)]};
      end

    endgenerate
    // wire [4*(bw_psum+4)-1:0] width_8_abs_value;
    // wire [4*(bw_psum+4)-1:0] tmp_width_8_abs_value;

    // generate
    //   for (i=0; i < 4; i=i+1) begin: BIT_8_ABS_PROCESS
    //     assign tmp_width_8_abs_value[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)] = 
    //       (width_8_in[(bw_psum+4)*(i+1)-1]) ?  
    //       (~width_8_in[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)] + 1) :  
    //         width_8_in[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)];

    //     assign width_8_abs_value[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)] = 
    //       sign_mode ? 
    //       tmp_width_8_abs_value[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)] : 
    //       width_8_in[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)];
    //   end
    // endgenerate

    // wire [bw_psum+7:0] width_8_sum;
    // wire [4*(2 * bw_psum)-1:0] width_8_norm;

    // assign width_8_sum = 
    //   width_8_abs_value[(bw_psum+4)*1-1 : (bw_psum+4)*0] +
    //   width_8_abs_value[(bw_psum+4)*2-1 : (bw_psum+4)*1] +
    //   width_8_abs_value[(bw_psum+4)*3-1 : (bw_psum+4)*2] +
    //   width_8_abs_value[(bw_psum+4)*4-1 : (bw_psum+4)*3];

    // generate
    //   for (i=0; i < 4; i=i+1) begin: BIT_8_NORM
    //     assign width_8_norm[(2*bw_psum)*(i+1)-1:(2*bw_psum)*(i)] = {width_8_abs_value[(bw_psum+4)*(i+1)-1 : (bw_psum+4)*i], 12'b0} / width_8_sum;
    //   end
    // endgenerate

    // reg tc_sfu_wr;
    // reg tc_sfu_rd;
    wire tc_sfu_wr;
    wire tc_sfu_rd;
    wire oc_sum_wr;

    assign tc_sfu_fifo_rd = tc_sfu_rd;

    wire sum_empty, oc_sum_empty, abs_value_empty;
    wire sfu_ready;
    assign sfu_ready = !(sum_empty | abs_value_empty | oc_sfu_fifo_empty);

    // reg [bw_psum+3:0] sfu_sum;
    // reg [col*(bw_psum)-1:0] sfu_abs_value;
    wire [bw_psum+3:0] sfu_sum;
    wire [col*(bw_psum)-1:0] sfu_abs_value;

    wire [col*(bw_psum)-1:0] value_fifo_in;
    assign value_fifo_in = width_mode ? width_8_in : width_4_abs_value;

    fifo_depth16 #(.bw(bw_psum+4), .simd(1)) sum_value_fifo (
      .rd_clk(clk),
      .wr_clk(clk),
      .rd(tc_sfu_rd),
      .wr(tc_sfu_wr),
      .reset(reset),
      .o_empty(sum_empty),
      .in(width_4_sum),
      .out(sfu_sum)
    );

    fifo_depth16 #(.bw(bw_psum+4), .simd(1)) output_sum_value_fifo (
      .rd_clk(oc_clk),
      .wr_clk(clk),
      .rd(oc_sfu_fifo_rd),
      .wr(tc_sfu_wr),
      .reset(reset),
      .o_empty(tc_sfu_fifo_empty),
      .in(width_4_sum),
      .out(tc_sfu_sum)
    );

    fifo_depth16 #(.bw(col*(bw_psum)), .simd(1)) value_fifo (
      .rd_clk(clk),
      .wr_clk(clk),
      .rd(tc_sfu_rd),
      .wr(tc_sfu_wr),
      .reset(reset),
      .o_empty(abs_value_empty),
      .in(value_fifo_in),
      .out(sfu_abs_value)
    );

    // fifo_depth16 #(.bw(bw_psum+4), .simd(1)) oc_sum_value_fifo (
    //   .rd_clk(clk),
    //   .wr_clk(clk),
    //   .rd(tc_sfu_rd),
    //   .wr(oc_sum_wr),
    //   .reset(reset),
    //   .o_empty(oc_sum_empty),
    //   .in(oc_sfu_sum),
    //   .out(buffered_oc_sfu_sum)
    // );


    // assign tc_sfu_wr = acc && ofifo_valid;
    // assign tc_sfu_rd = div && sfu_ready;
    assign tc_sfu_wr = acc;
    assign tc_sfu_rd = div;
    // assign oc_sum_wr = exchange;

    // reg [3:0] acc_counter;
    // reg [3:0] div_counter;

    // reg [col*(bw_psum)-1:0] buffered_sfu_abs_value;
    // reg  [bw_psum+3:0] buffered_sfu_sum;
    // wire  [bw_psum+3:0] buffered_oc_sfu_sum;

    // always @(posedge clk) begin
    //   // buffered_sfu_abs_value <= sfu_abs_value;
    //   // buffered_sfu_sum <= sfu_sum;
    //   // sfu_sum <= buffered_sfu_sum;
    //   // sfu_abs_value <= buffered_sfu_abs_value;
    //   buffered_oc_sfu_sum <= oc_sfu_sum;
    // end

    // wire [col*(bw_psum)-1:0] buffered_sfu_abs_value;
    // wire  [bw_psum+3:0] buffered_sfu_sum;
    // assign sfu_abs_value = buffered_sfu_abs_value;
    // assign sfu_sum = buffered_sfu_sum;
    //   if (reset) begin
    //     acc_counter <= 4'b0;
    //     div_counter <= 4'b0;
    //     tc_sfu_wr <= 0;
    //     tc_sfu_rd <= 0;
    //   end
    //   else begin
    //     if (acc) begin
    //       if (ofifo_valid) begin
    //         acc_counter <= acc_counter + 1;
    //         tc_sfu_wr <= 1;
    //       end
    //       else
    //         tc_sfu_wr <= 0;
    //     end
    //     if (div) begin
    //       if (sfu_ready) begin
    //         tc_sfu_rd <= 1;
    //         div_counter <= div_counter + 1;
    //       end
    //       else 
    //         tc_sfu_rd <= 0;
    //     end
    //   end
    // end

    // reg [1:0] state; // idle, acc, fetch, div

    // always @(posedge clk, posedge reset) begin
    //   if (reset) begin
    //     acc_counter <= 4'b0;
    //     div_counter <= 4'b0;
    //     tc_sfu_wr <= 0;
    //     tc_sfu_rd <= 0;
    //     state <= 0;
    //   end
    //   else begin
    //     if (acc) begin
    //       if (ofifo_valid) begin
    //         acc_counter <= acc_counter + 1;
    //         tc_sfu_wr <= 1;
    //       end
    //       else
    //         tc_sfu_wr <= 0;
    //     end
    //     if (div) begin
    //       if (sfu_ready) begin
    //         tc_sfu_rd <= 1;
    //         div_counter <= div_counter + 1;
    //       end
    //       else 
    //         tc_sfu_rd <= 0;
    //     end
    //   end
    // end

    // generate
    //   for (i=0; i < col; i=i+1) begin: WIDTH_MODE_PROCESS
    //     assign sfu_in_width_process[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)] = i[0] && width_mode ? sfp_in[(bw_psum)*(i+1)-1:(bw_psum)*(i)] << 4 : sfp_in[(bw_psum)*(i+1)-1:(bw_psum)*(i)];
    //   end
    // endgenerate

    // generate
    //   for (i = 0; i < 4; i=i+1) begin: INPUT_8_BIT
    //     if (width_mode) begin
    //       assign sfu_in_width8[(bw_psum+5)*(i+1)-1:(bw_psum+5)*(i)] = sfu_in_width_process[(bw_psum+4)*(2*i+1)-1:(bw_psum+4)*(2*i)] + sfu_in_width_process[(bw_psum+4)*(2*i+2)-1:(bw_psum+4)*(2*i+1)];
    //     end
    //     else begin
    //       assign sfu_in_width8[(bw_psum+5)*(i+1)-1:(bw_psum+5)*(i)] = 0;
    //     end
    //   end
    // endgenerate

    // generate
    //   for (i=0; i < col; i=i+1) begin: SIGN_MODE_ABS_PROCESS
    //     if (!sign_mode) 
    //       assign sfu_in_width_process[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)] = width_mode ? sfp_in[(bw_psum)*(i+1)-1:(bw_psum)*(i)] << 4 : sfp_in[(bw_psum)*(i+1)-1:(bw_psum)*(i)];
    //     else
    //       assign sfu_in_abs_process_1[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)] = sfu_in_width_process[(bw_psum+4)*(i+1)-1:(bw_psum+4)*(i)];
    //   end
    // endgenerate

    // reg  [bw_psum+3:0] sfp_norm_0_width8; //15:0
    // reg  [bw_psum+3:0] sfp_norm_1_width8;
    // reg  [bw_psum+3:0] sfp_norm_2_width8;
    // reg  [bw_psum+3:0] sfp_norm_3_width8;
    // reg  [bw_psum+3:0] sfp_norm_4_width8;
    // reg  [bw_psum+3:0] sfp_norm_5_width8;
    // reg  [bw_psum+3:0] sfp_norm_6_width8;
    // reg  [bw_psum+3:0] sfp_norm_7_width8;
    // wire  [bw_psum+3:0] sfp_norm_0_width8; //15:0
    // wire  [bw_psum+3:0] sfp_norm_1_width8;
    // wire  [bw_psum+3:0] sfp_norm_2_width8;
    // wire  [bw_psum+3:0] sfp_norm_3_width8;
    // wire  [bw_psum+3:0] sfp_norm_4_width8;
    // wire  [bw_psum+3:0] sfp_norm_5_width8;
    // wire  [bw_psum+3:0] sfp_norm_6_width8;
    // wire  [bw_psum+3:0] sfp_norm_7_width8;

    // assign sfp_in_0_width8 = width_mode ? sfp_in[bw_psum * 1 - 1 : bw_psum * 0] << 4: sfp_in[bw_psum * 1 - 1 : bw_psum * 0];
    // assign sfp_in_1_width8 = sfp_in[bw_psum * 2 - 1 : bw_psum * 1];
    // assign sfp_in_2_width8 = width_mode ? sfp_in[bw_psum * 3 - 1 : bw_psum * 2] << 4: sfp_in[bw_psum * 3 - 1 : bw_psum * 2];
    // assign sfp_in_3_width8 = sfp_in[bw_psum * 4 - 1 : bw_psum * 3];
    // assign sfp_in_4_width8 = width_mode ? sfp_in[bw_psum * 5 - 1 : bw_psum * 4] << 4: sfp_in[bw_psum * 5 - 1 : bw_psum * 4];
    // assign sfp_in_5_width8 = sfp_in[bw_psum * 6 - 1 : bw_psum * 5];
    // assign sfp_in_6_width8 = width_mode ? sfp_in[bw_psum * 7 - 1 : bw_psum * 6] << 4: sfp_in[bw_psum * 7 - 1 : bw_psum * 6];
    // assign sfp_in_7_width8 = sfp_in[bw_psum * 8 - 1 : bw_psum * 7];

  //assign sum_out = sfp_in_0_width8 + sfp_in_1_width8 + sfp_in_2_width8 + sfp_in_3_width8 + sfp_in_4_width8 + sfp_in_5_width8 + sfp_in_6_width8 + sfp_in_7_width8;

  // assign abs[(bw_psum+4)*1-1 : (bw_psum+4)*0] = (sfp_in_0_width8[bw_psum+3]) ?  (~sfp_in_0_width8 + 1)  :  sfp_in_0_width8;
  // assign abs[(bw_psum+4)*2 -1: (bw_psum+4)*1] = (sfp_in_1_width8[bw_psum+3]) ?  (~sfp_in_1_width8 + 1)  :  sfp_in_1_width8;
  // assign abs[(bw_psum+4)*3 -1: (bw_psum+4)*2] = (sfp_in_2_width8[bw_psum+3]) ?  (~sfp_in_2_width8 + 1)  :  sfp_in_2_width8;
  // assign abs[(bw_psum+4)*4-1 : (bw_psum+4)*3] = (sfp_in_3_width8[bw_psum+3]) ?  (~sfp_in_3_width8 + 1)  :  sfp_in_3_width8;
  // assign abs[(bw_psum+4)*5-1 : (bw_psum+4)*4] = (sfp_in_4_width8[bw_psum+3]) ?  (~sfp_in_4_width8 + 1)  :  sfp_in_4_width8;
  // assign abs[(bw_psum+4)*6-1 : (bw_psum+4)*5] = (sfp_in_5_width8[bw_psum+3]) ?  (~sfp_in_5_width8 + 1)  :  sfp_in_5_width8;
  // assign abs[(bw_psum+4)*7 -1: (bw_psum+4)*6] = (sfp_in_6_width8[bw_psum+3]) ?  (~sfp_in_6_width8 + 1)  :  sfp_in_6_width8;
  // assign abs[(bw_psum+4)*8-1 : (bw_psum+4)*7] = (sfp_in_7_width8[bw_psum+3]) ?  (~sfp_in_7_width8 + 1)  :  sfp_in_7_width8;

  // assign sfp_out = {sfp_norm_0_width8, sfp_norm_1_width8, sfp_norm_2_width8, sfp_norm_3_width8, sfp_norm_4_width8, sfp_norm_5_width8, sfp_norm_6_width8, sfp_norm_7_width8};

  // wire [40:0] tmp0, tmp1, tmp2, tmp3;
  // assign tmp0 = {(sfp_in_0_width8 + sfp_in_1_width8),8'b0} / sum_q;
  // assign tmp1 = {(sfp_in_2_width8 + sfp_in_3_width8),8'b0} / sum_q;
  // assign tmp2 = {(sfp_in_4_width8 + sfp_in_5_width8),8'b0} / sum_q;
  // assign tmp3 = {(sfp_in_6_width8 + sfp_in_7_width8),8'b0} / sum_q;

  // assign sum_q = 
  //          {4'b0, abs[(bw_psum+4)*1-1 : (bw_psum+4)*0]} +
  //          {4'b0, abs[(bw_psum+4)*2-1 : (bw_psum+4)*1]} +
  //          {4'b0, abs[(bw_psum+4)*3-1 : (bw_psum+4)*2]} +
  //          {4'b0, abs[(bw_psum+4)*4-1 : (bw_psum+4)*3]} +
  //          {4'b0, abs[(bw_psum+4)*5-1 : (bw_psum+4)*4]} +
  //          {4'b0, abs[(bw_psum+4)*6-1 : (bw_psum+4)*5]} +
  //          {4'b0, abs[(bw_psum+4)*7-1 : (bw_psum+4)*6]} +
  //          {4'b0, abs[(bw_psum+4)*8-1 : (bw_psum+4)*7]} ;
  
  // assign sfp_norm_0_width8 = width_mode ? tmp0[(bw_psum+4)/2 - 1:0] :     {sfp_in_0_width8,8'b0} / sum_q;
  // assign sfp_norm_1_width8 = width_mode ? tmp0[bw_psum+3:(bw_psum+4)/2]:  {sfp_in_0_width8,8'b0} / sum_q;
  // assign sfp_norm_2_width8 = width_mode ? tmp1[(bw_psum+4)/2 - 1:0] :     {sfp_in_0_width8,8'b0} / sum_q;
  // assign sfp_norm_3_width8 = width_mode ? tmp1[bw_psum+3:(bw_psum+4)/2] : {sfp_in_0_width8,8'b0} / sum_q;
  // assign sfp_norm_4_width8 = width_mode ? tmp2[(bw_psum+4)/2 - 1:0] :     {sfp_in_0_width8,8'b0} / sum_q;
  // assign sfp_norm_5_width8 = width_mode ? tmp2[bw_psum+3:(bw_psum+4)/2] : {sfp_in_0_width8,8'b0} / sum_q;
  // assign sfp_norm_6_width8 = width_mode ? tmp3[(bw_psum+4)/2 - 1:0] :     {sfp_in_0_width8,8'b0} / sum_q;
  // assign sfp_norm_7_width8 = width_mode ? tmp3[bw_psum+3:(bw_psum+4)/2] : {sfp_in_0_width8,8'b0} / sum_q;



// always @ (posedge clk) begin
//     if (reset) begin
//       fifo_wr <= 0;
//     end
//     else begin
//        div_q <= div ;
//        if (acc) begin
      
//          sum_q <= 
//            {4'b0, abs[(bw_psum+4)*1-1 : (bw_psum+4)*0]} +
//            {4'b0, abs[(bw_psum+4)*2-1 : (bw_psum+4)*1]} +
//            {4'b0, abs[(bw_psum+4)*3-1 : (bw_psum+4)*2]} +
//            {4'b0, abs[(bw_psum+4)*4-1 : (bw_psum+4)*3]} +
//            {4'b0, abs[(bw_psum+4)*5-1 : (bw_psum+4)*4]} +
//            {4'b0, abs[(bw_psum+4)*6-1 : (bw_psum+4)*5]} +
//            {4'b0, abs[(bw_psum+4)*7-1 : (bw_psum+4)*6]} +
//            {4'b0, abs[(bw_psum+4)*8-1 : (bw_psum+4)*7]} ;
//          fifo_wr <= 1;
//        end
//        else begin
//          fifo_wr <= 0;
   
//          if (div) begin 
//           if(!width_mode)begin //Width Mode 
//            sfp_norm_0_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
//            sfp_norm_1_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
//            sfp_norm_2_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
//            sfp_norm_3_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
//            sfp_norm_4_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
//            sfp_norm_5_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
//            sfp_norm_6_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
//            sfp_norm_7_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
//           end
//           else begin
//            sfp_norm_0_width8 <= tmp0[(bw_psum+4)/2 - 1:0];
//            sfp_norm_1_width8 <= tmp0[bw_psum+3:(bw_psum+4)/2];
//            sfp_norm_2_width8 <= tmp1[(bw_psum+4)/2 - 1:0];
//            sfp_norm_3_width8 <= tmp1[bw_psum+3:(bw_psum+4)/2];
//            sfp_norm_4_width8 <= tmp2[(bw_psum+4)/2 - 1:0];
//            sfp_norm_5_width8 <= tmp2[bw_psum+3:(bw_psum+4)/2];
//            sfp_norm_6_width8 <= tmp3[(bw_psum+4)/2 - 1:0];
//            sfp_norm_7_width8 <= tmp3[bw_psum+3:(bw_psum+4)/2];

//          end

//        end
//    end
//  end
// end
endmodule

