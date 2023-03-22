// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sfu (clk, reset, width_mode, acc, div, sign_mode, sum_out, sfp_in, sfp_out);

    parameter col = 8;
    parameter bw = 4;
    parameter bw_psum = 2*bw+4; //12

    input  clk, div, acc, reset;
    
    input width_mode, sign_mode;

    input  [col*bw_psum-1:0] sfp_in; //95:0
    output [col*bw_psum-1:0] sfp_out; //95:0

    output [bw_psum+6:0] sum_out;

    //assign sfp_out = sfp_in;

    reg [bw_psum+7:0] sum_q; //19:0
    reg fifo_wr;
    reg div_q;
    wire [bw_psum+3:0] sum_this_core; // 15:0
    wire  [col*(bw_psum+4)-1:0] abs; //95:0 12 each
    //wire  [col*bw_psum-1:0] sfp_in_width8; //95:0 

    wire  [bw_psum+3:0] sfp_in_0_width8; //15:0
    wire  [bw_psum+3:0] sfp_in_1_width8;
    wire  [bw_psum+3:0] sfp_in_2_width8;
    wire  [bw_psum+3:0] sfp_in_3_width8;
    wire  [bw_psum+3:0] sfp_in_4_width8;
    wire  [bw_psum+3:0] sfp_in_5_width8;
    wire  [bw_psum+3:0] sfp_in_6_width8;
    wire  [bw_psum+3:0] sfp_in_7_width8;

    reg  [bw_psum+3:0] sfp_norm_0_width8; //15:0
    reg  [bw_psum+3:0] sfp_norm_1_width8;
    reg  [bw_psum+3:0] sfp_norm_2_width8;
    reg  [bw_psum+3:0] sfp_norm_3_width8;
    reg  [bw_psum+3:0] sfp_norm_4_width8;
    reg  [bw_psum+3:0] sfp_norm_5_width8;
    reg  [bw_psum+3:0] sfp_norm_6_width8;
    reg  [bw_psum+3:0] sfp_norm_7_width8;

    assign sfp_in_0_width8 = width_mode ? sfp_in[bw_psum * 1 - 1 : bw_psum * 0] << 4: sfp_in[bw_psum * 1 - 1 : bw_psum * 0];
    assign sfp_in_1_width8 = sfp_in[bw_psum * 2 - 1 : bw_psum * 1];
    assign sfp_in_2_width8 = width_mode ? sfp_in[bw_psum * 3 - 1 : bw_psum * 2] << 4: sfp_in[bw_psum * 3 - 1 : bw_psum * 2];
    assign sfp_in_3_width8 = sfp_in[bw_psum * 4 - 1 : bw_psum * 3];
    assign sfp_in_4_width8 = width_mode ? sfp_in[bw_psum * 5 - 1 : bw_psum * 4] << 4: sfp_in[bw_psum * 5 - 1 : bw_psum * 4];
    assign sfp_in_5_width8 = sfp_in[bw_psum * 6 - 1 : bw_psum * 5];
    assign sfp_in_6_width8 = width_mode ? sfp_in[bw_psum * 7 - 1 : bw_psum * 6] << 4: sfp_in[bw_psum * 7 - 1 : bw_psum * 6];
    assign sfp_in_7_width8 = sfp_in[bw_psum * 8 - 1 : bw_psum * 7];

  //assign sum_out = sfp_in_0_width8 + sfp_in_1_width8 + sfp_in_2_width8 + sfp_in_3_width8 + sfp_in_4_width8 + sfp_in_5_width8 + sfp_in_6_width8 + sfp_in_7_width8;

  assign abs[(bw_psum+4)*1-1 : (bw_psum+4)*0] = (sfp_in_0_width8[bw_psum+3]) ?  (~sfp_in_0_width8 + 1)  :  sfp_in_0_width8 ;
  assign abs[(bw_psum+4)*2 -1: (bw_psum+4)*1] = (sfp_in_1_width8[bw_psum+3]) ?  (~sfp_in_1_width8 + 1)  :  sfp_in_1_width8;
  assign abs[(bw_psum+4)*3 -1: (bw_psum+4)*2] = (sfp_in_2_width8[bw_psum+3]) ?  (~sfp_in_2_width8 + 1)  :  sfp_in_2_width8;
  assign abs[(bw_psum+4)*4-1 : (bw_psum+4)*3] = (sfp_in_3_width8[bw_psum+3]) ?  (~sfp_in_3_width8 + 1)  :  sfp_in_3_width8;
  assign abs[(bw_psum+4)*5-1 : (bw_psum+4)*4] = (sfp_in_4_width8[bw_psum+3]) ?  (~sfp_in_4_width8 + 1)  :  sfp_in_4_width8;
  assign abs[(bw_psum+4)*6-1 : (bw_psum+4)*5] = (sfp_in_5_width8[bw_psum+3]) ?  (~sfp_in_5_width8 + 1)  :  sfp_in_5_width8;
  assign abs[(bw_psum+4)*7 -1: (bw_psum+4)*6] = (sfp_in_6_width8[bw_psum+3]) ?  (~sfp_in_6_width8 + 1)  :  sfp_in_6_width8;
  assign abs[(bw_psum+4)*8-1 : (bw_psum+4)*7] = (sfp_in_7_width8[bw_psum+3]) ?  (~sfp_in_7_width8 + 1)  :  sfp_in_7_width8;

  assign sfp_out = {sfp_norm_0_width8, sfp_norm_1_width8, sfp_norm_2_width8, sfp_norm_3_width8, sfp_norm_4_width8, sfp_norm_5_width8, sfp_norm_6_width8, sfp_norm_7_width8};

  wire [40:0] tmp0, tmp1, tmp2, tmp3;
  assign tmp0 = {(sfp_in_0_width8 + sfp_in_1_width8),20'b0} / sum_q;
  assign tmp1 = {(sfp_in_2_width8 + sfp_in_3_width8),20'b0} / sum_q;
  assign tmp2 = {(sfp_in_4_width8 + sfp_in_5_width8),20'b0} / sum_q;
  assign tmp3 = {(sfp_in_6_width8 + sfp_in_7_width8),20'b0} / sum_q;

always @ (posedge clk) begin
    if (reset) begin
      fifo_wr <= 0;
    end
    else begin
       div_q <= div ;
       if (acc) begin
      
         sum_q <= 
           {4'b0, abs[(bw_psum+4)*1-1 : (bw_psum+4)*0]} +
           {4'b0, abs[(bw_psum+4)*2-1 : (bw_psum+4)*1]} +
           {4'b0, abs[(bw_psum+4)*3-1 : (bw_psum+4)*2]} +
           {4'b0, abs[(bw_psum+4)*4-1 : (bw_psum+4)*3]} +
           {4'b0, abs[(bw_psum+4)*5-1 : (bw_psum+4)*4]} +
           {4'b0, abs[(bw_psum+4)*6-1 : (bw_psum+4)*5]} +
           {4'b0, abs[(bw_psum+4)*7-1 : (bw_psum+4)*6]} +
           {4'b0, abs[(bw_psum+4)*8-1 : (bw_psum+4)*7]} ;
         fifo_wr <= 1;
       end
       else begin
         fifo_wr <= 0;
   
         if (div) begin 
          if(!width_mode)begin //Width Mode 
           sfp_norm_0_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
           sfp_norm_1_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
           sfp_norm_2_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
           sfp_norm_3_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
           sfp_norm_4_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
           sfp_norm_5_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
           sfp_norm_6_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
           sfp_norm_7_width8 <= {sfp_in_0_width8,20'b0} / sum_q;
          end
          else begin
           sfp_norm_0_width8 <= tmp0[(bw_psum+4)/2 - 1:0];
           sfp_norm_1_width8 <= tmp0[bw_psum+3:(bw_psum+4)/2];
           sfp_norm_2_width8 <= tmp1[(bw_psum+4)/2 - 1:0];
           sfp_norm_3_width8 <= tmp1[bw_psum+3:(bw_psum+4)/2];
           sfp_norm_4_width8 <= tmp2[(bw_psum+4)/2 - 1:0];
           sfp_norm_5_width8 <= tmp2[bw_psum+3:(bw_psum+4)/2];
           sfp_norm_6_width8 <= tmp3[(bw_psum+4)/2 - 1:0];
           sfp_norm_7_width8 <= tmp3[bw_psum+3:(bw_psum+4)/2];

         end

       end
   end
 end
end
endmodule

