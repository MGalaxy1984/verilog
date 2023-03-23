// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_16in (out, a, b, col_index, sign_mode, width_mode);

parameter bw = 4;
parameter bw_psum = 2*bw+4; //[11:0]
parameter pr = 8; // parallel factor: number of inputs = 64

output [bw_psum-1:0] out;
input  [pr*bw-1:0] a; //query
input  [pr*bw-1:0] b;// kernel

input  col_index; //0 = odd, 1 = even
input  sign_mode; //0 = unsigned, 1 = signed
input  width_mode; //0 = 4 bit, 1 = 8 bit

wire operation_mode; //0 = unsigned, 1 = signed
wire third_mode;
wire tmp1, tmp2;
assign tmp1 = width_mode && col_index; //
assign tmp2 = (!tmp1) && sign_mode;
assign operation_mode = tmp2;
assign third_mode = tmp1 && sign_mode; //  third mode activate when even column, 8 bit mode and signed mode; key is unsigned and q is signed


wire [pr * (bw+bw)-1:0] a_pad;
wire [pr * (bw+bw)-1:0] b_pad;
wire [pr * (bw+bw)-1:0] tmp_product;
wire [pr * (bw+bw)-1:0] product;
wire [pr * (bw+bw+4)-1:0] product_pad;
genvar i;

// wire [(bw+bw)-1:0] a_pad[bw];
// wire [(bw+bw)-1:0] b_pad[bw];
// wire [pr * (bw+bw)-1:0] b_tmp;

generate
  for (i = 0; i < pr; i=i+1) begin: INPUT_PADDING
    assign a_pad[(bw+bw)*(i+1)-1:(bw+bw)*i] = sign_mode ?                  {{(bw){a[bw*(i+1)-1]}},  a[bw*(i+1)-1: bw*i]} : {{(bw){1'b0}},       a[bw*(i+1)-1: bw*i]};
    assign b_pad[(bw+bw)*(i+1)-1:(bw+bw)*i] = sign_mode && (!third_mode) ? {{(bw){b[bw*(i+1)-1]}},  b[bw*(i+1)-1: bw*i]} : {{(bw){1'b0}},       b[bw*(i+1)-1: bw*i]};
    // assign a_pad[i] = operation_mode ? {{(bw){a[bw*(i+1)-1]}},  a[bw*(i+1)-1: bw*i]} : {{(bw){1'b0}},       a[bw*(i+1)-1: bw*i]};
    // assign b_pad[i] = operation_mode ? {{(bw){b[bw*(i+1)-1]}},  b[bw*(i+1)-1: bw*i]} : {{(bw){1'b0}},       b[bw*(i+1)-1: bw*i]};
  end
endgenerate

generate
  for (i = 0; i < pr; i=i+1) begin: MULTIPLIER

    assign tmp_product[(bw+bw)*(i+1)-1:(bw+bw)*i] = a_pad[(bw+bw)*(i+1)-1:(bw+bw)*i] * b_pad[(bw+bw)*(i+1)-1:(bw+bw)*i];
    // assign product[(bw+bw)*(i+1)-1:(bw+bw)*i] = third_mode && a[bw*(i+1)-1] ? -tmp_product[(bw+bw)*(i+1)-1:(bw+bw)*i] : tmp_product[(bw+bw)*(i+1)-1:(bw+bw)*i];
    assign product[(bw+bw)*(i+1)-1:(bw+bw)*i] = tmp_product[(bw+bw)*(i+1)-1:(bw+bw)*i];
    // assign product[(bw+bw)*(i+1)-1:(bw+bw)*i] = a_pad[i] * b_pad[i];
  end 
endgenerate

generate
  for (i = 0; i < pr; i=i+1) begin: PRODUCT_PADDING
    assign product_pad[(bw+bw+4)*(i+1)-1:(bw+bw+4)*i] = sign_mode ? {{(4){product[(bw+bw)*(i+1)-1]}},product[(bw+bw)*(i+1)-1:(bw+bw)*i]}: {4'b0000, product[(bw+bw)*(i+1)-1:(bw+bw)*i]};
  end 
endgenerate

// wire [31:0] tmp_out;
// assign tmp_out = product_pad[(bw+bw+4)*1-1:(bw+bw+4)*0]
// + product_pad[(bw+bw+4)*2-1:(bw+bw+4)*1]
// + product_pad[(bw+bw+4)*3-1:(bw+bw+4)*2]
// + product_pad[(bw+bw+4)*4-1:(bw+bw+4)*3]
// + product_pad[(bw+bw+4)*5-1:(bw+bw+4)*4]
// + product_pad[(bw+bw+4)*6-1:(bw+bw+4)*5]
// + product_pad[(bw+bw+4)*7-1:(bw+bw+4)*6]
// + product_pad[(bw+bw+4)*8-1:(bw+bw+4)*7];

wire [bw_psum:0] quarter_sum0,quarter_sum1,quarter_sum2, quarter_sum3;
assign quarter_sum0 = product_pad[(bw+bw+4)*1-1:(bw+bw+4)*0] + product_pad[(bw+bw+4)*2-1:(bw+bw+4)*1];
assign quarter_sum1 = product_pad[(bw+bw+4)*3-1:(bw+bw+4)*2] + product_pad[(bw+bw+4)*4-1:(bw+bw+4)*3];
assign quarter_sum2 = product_pad[(bw+bw+4)*5-1:(bw+bw+4)*4] + product_pad[(bw+bw+4)*6-1:(bw+bw+4)*5];
assign quarter_sum3 = product_pad[(bw+bw+4)*7-1:(bw+bw+4)*6] +  product_pad[(bw+bw+4)*8-1:(bw+bw+4)*7];

wire [bw_psum+1:0] semi_sum0, semi_sum1;
assign semi_sum0 = quarter_sum0 + quarter_sum1;
assign semi_sum1 = quarter_sum2 + quarter_sum3;

assign out = semi_sum0 + semi_sum1;
// assign out =  product_pad[(bw+bw+4)*1-1:(bw+bw+4)*0]
// + product_pad[(bw+bw+4)*2-1:(bw+bw+4)*1]
// + product_pad[(bw+bw+4)*3-1:(bw+bw+4)*2]
// + product_pad[(bw+bw+4)*4-1:(bw+bw+4)*3]
// + product_pad[(bw+bw+4)*5-1:(bw+bw+4)*4]
// + product_pad[(bw+bw+4)*6-1:(bw+bw+4)*5]
// + product_pad[(bw+bw+4)*7-1:(bw+bw+4)*6]
// + product_pad[(bw+bw+4)*8-1:(bw+bw+4)*7];

endmodule
