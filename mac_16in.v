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

wire [31:0] tmp_out;
assign tmp_out = product_pad[(bw+bw+4)*1-1:(bw+bw+4)*0]
+ product_pad[(bw+bw+4)*2-1:(bw+bw+4)*1]
+ product_pad[(bw+bw+4)*3-1:(bw+bw+4)*2]
+ product_pad[(bw+bw+4)*4-1:(bw+bw+4)*3]
+ product_pad[(bw+bw+4)*5-1:(bw+bw+4)*4]
+ product_pad[(bw+bw+4)*6-1:(bw+bw+4)*5]
+ product_pad[(bw+bw+4)*7-1:(bw+bw+4)*6]
+ product_pad[(bw+bw+4)*8-1:(bw+bw+4)*7];
// + product_pad[(bw+bw+4)*9-1:(bw+bw+4)*8]
// + product_pad[(bw+bw+4)*10-1:(bw+bw+4)*9]
// + product_pad[(bw+bw+4)*11-1:(bw+bw+4)*10]
// + product_pad[(bw+bw+4)*12-1:(bw+bw+4)*11]
// + product_pad[(bw+bw+4)*13-1:(bw+bw+4)*12]
// + product_pad[(bw+bw+4)*14-1:(bw+bw+4)*13]
// + product_pad[(bw+bw+4)*15-1:(bw+bw+4)*14]
// + product_pad[(bw+bw+4)*16-1:(bw+bw+4)*15];

assign out =  product_pad[(bw+bw+4)*1-1:(bw+bw+4)*0]
+ product_pad[(bw+bw+4)*2-1:(bw+bw+4)*1]
+ product_pad[(bw+bw+4)*3-1:(bw+bw+4)*2]
+ product_pad[(bw+bw+4)*4-1:(bw+bw+4)*3]
+ product_pad[(bw+bw+4)*5-1:(bw+bw+4)*4]
+ product_pad[(bw+bw+4)*6-1:(bw+bw+4)*5]
+ product_pad[(bw+bw+4)*7-1:(bw+bw+4)*6]
+ product_pad[(bw+bw+4)*8-1:(bw+bw+4)*7];
// + product_pad[(bw+bw+4)*9-1:(bw+bw+4)*8]
// + product_pad[(bw+bw+4)*10-1:(bw+bw+4)*9]
// + product_pad[(bw+bw+4)*11-1:(bw+bw+4)*10]
// + product_pad[(bw+bw+4)*12-1:(bw+bw+4)*11]
// + product_pad[(bw+bw+4)*13-1:(bw+bw+4)*12]
// + product_pad[(bw+bw+4)*14-1:(bw+bw+4)*13]
// + product_pad[(bw+bw+4)*15-1:(bw+bw+4)*14]
// + product_pad[(bw+bw+4)*16-1:(bw+bw+4)*15];

// wire    [2*bw-1:0]  product0  ;  //8 bit [7:0]
// wire    [2*bw-1:0]  product1  ;
// wire    [2*bw-1:0]  product2  ;
// wire    [2*bw-1:0]  product3  ;
// wire    [2*bw-1:0]  product4  ;
// wire    [2*bw-1:0]  product5  ;
// wire    [2*bw-1:0]  product6  ;
// wire    [2*bw-1:0]  product7  ;
// wire    [2*bw-1:0]  product8  ;
// wire    [2*bw-1:0]  product9  ;
// wire    [2*bw-1:0]  product10  ;
// wire    [2*bw-1:0]  product11  ;
// wire    [2*bw-1:0]  product12  ;
// wire    [2*bw-1:0]  product13  ;
// wire    [2*bw-1:0]  product14  ;
// wire    [2*bw-1:0]  product15  ;


// assign  product0  =  {{(bw){a[bw*  1  -1]}},  a[bw*  1  -1:bw*  0  ]}  *  {{(bw){a[bw*  1  -1]}},  b[bw*  1  -1:  bw*  0  ]};
// assign  product1  =  {{(bw){a[bw*  2  -1]}},  a[bw*  2  -1:bw*  1  ]}  *  {{(bw){b[bw*  2  -1]}},  b[bw*  2  -1:  bw*  1  ]};
// assign  product2  =  {{(bw){a[bw*  3  -1]}},  a[bw*  3  -1:bw*  2  ]}  *  {{(bw){b[bw*  3  -1]}},  b[bw*  3  -1:  bw*  2  ]};
// assign  product3  =  {{(bw){a[bw*  4  -1]}},  a[bw*  4  -1:bw*  3  ]}  *  {{(bw){b[bw*  4  -1]}},  b[bw*  4  -1:  bw*  3  ]};
// assign  product4  =  {{(bw){a[bw*  5  -1]}},  a[bw*  5  -1:bw*  4  ]}  *  {{(bw){b[bw*  5  -1]}},  b[bw*  5  -1:  bw*  4  ]};
// assign  product5  =  {{(bw){a[bw*  6  -1]}},  a[bw*  6  -1:bw*  5  ]}  *  {{(bw){b[bw*  6  -1]}},  b[bw*  6  -1:  bw*  5  ]};
// assign  product6  =  {{(bw){a[bw*  7  -1]}},  a[bw*  7  -1:bw*  6  ]}  *  {{(bw){b[bw*  7  -1]}},  b[bw*  7  -1:  bw*  6  ]};
// assign  product7  =  {{(bw){a[bw*  8  -1]}},  a[bw*  8  -1:bw*  7  ]}  *  {{(bw){b[bw*  8  -1]}},  b[bw*  8  -1:  bw*  7  ]};
// assign  product8  =  {{(bw){a[bw*  9  -1]}},  a[bw*  9  -1:bw*  8  ]}  *  {{(bw){b[bw*  9  -1]}},  b[bw*  9  -1:  bw*  8  ]};
// assign  product9  =  {{(bw){a[bw*  10  -1]}},  a[bw*  10  -1:bw*  9  ]}  *  {{(bw){b[bw*  10  -1]}},  b[bw*  10  -1:  bw*  9  ]};
// assign  product10  =  {{(bw){a[bw*  11  -1]}},  a[bw*  11  -1:bw*  10  ]}  *  {{(bw){b[bw*  11  -1]}},  b[bw*  11  -1:  bw*  10  ]};
// assign  product11  =  {{(bw){a[bw*  12  -1]}},  a[bw*  12  -1:bw*  11  ]}  *  {{(bw){b[bw*  12  -1]}},  b[bw*  12  -1:  bw*  11  ]};
// assign  product12  =  {{(bw){a[bw*  13  -1]}},  a[bw*  13  -1:bw*  12  ]}  *  {{(bw){b[bw*  13  -1]}},  b[bw*  13  -1:  bw*  12  ]};
// assign  product13  =  {{(bw){a[bw*  14  -1]}},  a[bw*  14  -1:bw*  13  ]}  *  {{(bw){b[bw*  14  -1]}},  b[bw*  14  -1:  bw*  13  ]};
// assign  product14  =  {{(bw){a[bw*  15  -1]}},  a[bw*  15  -1:bw*  14  ]}  *  {{(bw){b[bw*  15  -1]}},  b[bw*  15  -1:  bw*  14  ]};
// assign  product15  =  {{(bw){a[bw*  16  -1]}},  a[bw*  16  -1:bw*  15  ]}  *  {{(bw){b[bw*  16  -1]}},  b[bw*  16  -1:  bw*  15  ]};


// wire [11:0] out1;
// assign out1 = 
//      {{(4){product0[2*bw-1]}},product0  }
//   +  {{(4){product1[2*bw-1]}},product1  }
//   +  {{(4){product2[2*bw-1]}},product2  }
//   +  {{(4){product3[2*bw-1]}},product3  }
//   +  {{(4){product4[2*bw-1]}},product4  }
//   +  {{(4){product5[2*bw-1]}},product5  }
//   +  {{(4){product6[2*bw-1]}},product6  }
//   +  {{(4){product7[2*bw-1]}},product7  }
//   +  {{(4){product8[2*bw-1]}},product8  }
//   +  {{(4){product9[2*bw-1]}},product9  }
//   +  {{(4){product10[2*bw-1]}},product10  }
//   +  {{(4){product11[2*bw-1]}},product11  }
//   +  {{(4){product12[2*bw-1]}},product12  }
//   +  {{(4){product13[2*bw-1]}},product13  }
//   +  {{(4){product14[2*bw-1]}},product14  }
//   +  {{(4){product15[2*bw-1]}},product15  };



endmodule

// module mac_16in (out, a, b, col_index, sign_mode, width_mode);

// parameter bw = 4;
// parameter bw_psum = 2*bw+4; //[11:0]
// parameter pr = 16; // parallel factor: number of inputs = 64

// output [bw_psum-1:0] out;
// input  [pr*bw-1:0] a; //query
// input  [pr*bw-1:0] b;// kernel

// input  col_index; //0 = odd, 1 = even
// input  sign_mode; //0 = unsigned, 1 = signed
// input  width_mode; //0 = 4 bit, 1 = 8 bit

// wire operation_mode; //0 = unsigned, 1 = signed
// wire third_mode;
// wire tmp1, tmp2;
// assign tmp1 = width_mode && col_index; //
// assign tmp2 = (!tmp1) && sign_mode;
// assign operation_mode = tmp2;
// assign third_mode = tmp1 && sign_mode; //  third mode activate when even column, 8 bit mode and signed mode; key is unsigned and q is signed

// wire [pr * 5-1:0] a5;
// wire [pr * 5-1:0] b5;
// wire [pr * 10-1:0] a_pad;
// wire [pr * 10-1:0] b_pad;
// wire [pr * 8-1:0] product;
// wire [pr * 12-1:0] product_pad;
// genvar i;

// // wire [(bw+bw)-1:0] a_pad[bw];
// // wire [(bw+bw)-1:0] b_pad[bw];
// // wire [pr * (bw+bw)-1:0] b_tmp;
// generate
//   for (i = 0; i < pr; i=i+1) begin: INPUT_5bit
//     assign a5[5*(i+1)-1:5*i] = sign_mode ?                  {{a[4*(i+1)-1]},  a[4*(i+1)-1: 4*i]} : {1'b0, a[4*(i+1)-1: 4*i]};
//     assign b5[5*(i+1)-1:5*i] = sign_mode && (!third_mode) ? {{b[4*(i+1)-1]},  b[4*(i+1)-1: 4*i]} : {1'b0, b[4*(i+1)-1: 4*i]};
//     // assign a_pad[i] = operation_mode ? {{(bw){a[bw*(i+1)-1]}},  a[bw*(i+1)-1: bw*i]} : {{(bw){1'b0}},       a[bw*(i+1)-1: bw*i]};
//     // assign b_pad[i] = operation_mode ? {{(bw){b[bw*(i+1)-1]}},  b[bw*(i+1)-1: bw*i]} : {{(bw){1'b0}},       b[bw*(i+1)-1: bw*i]};
//   end
// endgenerate

// generate
//   for (i = 0; i < pr; i=i+1) begin: INPUT_PADDING
//     assign a_pad[10*(i+1)-1:10*i] = sign_mode ?                  {{(5){a5[bw*(i+1)-1]}},  a5[5*(i+1)-1: 5*i]} : {{(5){1'b0}},       a5[5*(i+1)-1: 5*i]};
//     assign b_pad[10*(i+1)-1:10*i] = sign_mode && (!third_mode) ? {{(5){b5[bw*(i+1)-1]}},  b5[5*(i+1)-1: 5*i]} : {{(5){1'b0}},       b5[5*(i+1)-1: 5*i]};
//     // assign a_pad[i] = operation_mode ? {{(bw){a[bw*(i+1)-1]}},  a[bw*(i+1)-1: bw*i]} : {{(bw){1'b0}},       a[bw*(i+1)-1: bw*i]};
//     // assign b_pad[i] = operation_mode ? {{(bw){b[bw*(i+1)-1]}},  b[bw*(i+1)-1: bw*i]} : {{(bw){1'b0}},       b[bw*(i+1)-1: bw*i]};
//   end
// endgenerate

// generate
//   for (i = 0; i < pr; i=i+1) begin: MULTIPLIER
//     // assign product[10*(i+1)-1:10*i] = a_pad[10*(i+1)-1:10*i] * b_pad[10*(i+1)-1:10*i];
//     // assign product[10*(i+1)-1:10*i] = a5[5*(i+1)-1:5*i] * b5[5*(i+1)-1:5*i];
//     assign product[8*(i+1)-1:8*i] = a5[5*(i+1)-1:5*i] * b5[5*(i+1)-1:5*i];
//     // assign product[(bw+bw)*(i+1)-1:(bw+bw)*i] = a_pad[i] * b_pad[i];
//   end 
// endgenerate

// generate
//   for (i = 0; i < pr; i=i+1) begin: PRODUCT_PADDING
//     // assign product_pad[14*(i+1)-1:14*i] = sign_mode ? {{(4){product[10*(i+1)-1]}},product[10*(i+1)-1:10*i]}: {4'b0000, product[10*(i+1)-1:10*i]};
//     assign product_pad[12*(i+1)-1:12*i] = sign_mode ? {{(4){product[8*(i+1)-1]}},product[8*(i+1)-1:8*i]}: {4'b0000, product[8*(i+1)-1:8*i]};
//   end 
// endgenerate

// assign out =  product_pad[(bw+bw+4)*1-1:(bw+bw+4)*0]
// + product_pad[(bw+bw+4)*2-1:(bw+bw+4)*1]
// + product_pad[(bw+bw+4)*3-1:(bw+bw+4)*2]
// + product_pad[(bw+bw+4)*4-1:(bw+bw+4)*3]
// + product_pad[(bw+bw+4)*5-1:(bw+bw+4)*4]
// + product_pad[(bw+bw+4)*6-1:(bw+bw+4)*5]
// + product_pad[(bw+bw+4)*7-1:(bw+bw+4)*6]
// + product_pad[(bw+bw+4)*8-1:(bw+bw+4)*7]
// + product_pad[(bw+bw+4)*9-1:(bw+bw+4)*8]
// + product_pad[(bw+bw+4)*10-1:(bw+bw+4)*9]
// + product_pad[(bw+bw+4)*11-1:(bw+bw+4)*10]
// + product_pad[(bw+bw+4)*12-1:(bw+bw+4)*11]
// + product_pad[(bw+bw+4)*13-1:(bw+bw+4)*12]
// + product_pad[(bw+bw+4)*14-1:(bw+bw+4)*13]
// + product_pad[(bw+bw+4)*15-1:(bw+bw+4)*14]
// + product_pad[(bw+bw+4)*16-1:(bw+bw+4)*15];

// // wire    [2*bw-1:0]  product0  ;  //8 bit [7:0]
// // wire    [2*bw-1:0]  product1  ;
// // wire    [2*bw-1:0]  product2  ;
// // wire    [2*bw-1:0]  product3  ;
// // wire    [2*bw-1:0]  product4  ;
// // wire    [2*bw-1:0]  product5  ;
// // wire    [2*bw-1:0]  product6  ;
// // wire    [2*bw-1:0]  product7  ;
// // wire    [2*bw-1:0]  product8  ;
// // wire    [2*bw-1:0]  product9  ;
// // wire    [2*bw-1:0]  product10  ;
// // wire    [2*bw-1:0]  product11  ;
// // wire    [2*bw-1:0]  product12  ;
// // wire    [2*bw-1:0]  product13  ;
// // wire    [2*bw-1:0]  product14  ;
// // wire    [2*bw-1:0]  product15  ;


// // assign  product0  =  {{(bw){a[bw*  1  -1]}},  a[bw*  1  -1:bw*  0  ]}  *  {{(bw){a[bw*  1  -1]}},  b[bw*  1  -1:  bw*  0  ]};
// // assign  product1  =  {{(bw){a[bw*  2  -1]}},  a[bw*  2  -1:bw*  1  ]}  *  {{(bw){b[bw*  2  -1]}},  b[bw*  2  -1:  bw*  1  ]};
// // assign  product2  =  {{(bw){a[bw*  3  -1]}},  a[bw*  3  -1:bw*  2  ]}  *  {{(bw){b[bw*  3  -1]}},  b[bw*  3  -1:  bw*  2  ]};
// // assign  product3  =  {{(bw){a[bw*  4  -1]}},  a[bw*  4  -1:bw*  3  ]}  *  {{(bw){b[bw*  4  -1]}},  b[bw*  4  -1:  bw*  3  ]};
// // assign  product4  =  {{(bw){a[bw*  5  -1]}},  a[bw*  5  -1:bw*  4  ]}  *  {{(bw){b[bw*  5  -1]}},  b[bw*  5  -1:  bw*  4  ]};
// // assign  product5  =  {{(bw){a[bw*  6  -1]}},  a[bw*  6  -1:bw*  5  ]}  *  {{(bw){b[bw*  6  -1]}},  b[bw*  6  -1:  bw*  5  ]};
// // assign  product6  =  {{(bw){a[bw*  7  -1]}},  a[bw*  7  -1:bw*  6  ]}  *  {{(bw){b[bw*  7  -1]}},  b[bw*  7  -1:  bw*  6  ]};
// // assign  product7  =  {{(bw){a[bw*  8  -1]}},  a[bw*  8  -1:bw*  7  ]}  *  {{(bw){b[bw*  8  -1]}},  b[bw*  8  -1:  bw*  7  ]};
// // assign  product8  =  {{(bw){a[bw*  9  -1]}},  a[bw*  9  -1:bw*  8  ]}  *  {{(bw){b[bw*  9  -1]}},  b[bw*  9  -1:  bw*  8  ]};
// // assign  product9  =  {{(bw){a[bw*  10  -1]}},  a[bw*  10  -1:bw*  9  ]}  *  {{(bw){b[bw*  10  -1]}},  b[bw*  10  -1:  bw*  9  ]};
// // assign  product10  =  {{(bw){a[bw*  11  -1]}},  a[bw*  11  -1:bw*  10  ]}  *  {{(bw){b[bw*  11  -1]}},  b[bw*  11  -1:  bw*  10  ]};
// // assign  product11  =  {{(bw){a[bw*  12  -1]}},  a[bw*  12  -1:bw*  11  ]}  *  {{(bw){b[bw*  12  -1]}},  b[bw*  12  -1:  bw*  11  ]};
// // assign  product12  =  {{(bw){a[bw*  13  -1]}},  a[bw*  13  -1:bw*  12  ]}  *  {{(bw){b[bw*  13  -1]}},  b[bw*  13  -1:  bw*  12  ]};
// // assign  product13  =  {{(bw){a[bw*  14  -1]}},  a[bw*  14  -1:bw*  13  ]}  *  {{(bw){b[bw*  14  -1]}},  b[bw*  14  -1:  bw*  13  ]};
// // assign  product14  =  {{(bw){a[bw*  15  -1]}},  a[bw*  15  -1:bw*  14  ]}  *  {{(bw){b[bw*  15  -1]}},  b[bw*  15  -1:  bw*  14  ]};
// // assign  product15  =  {{(bw){a[bw*  16  -1]}},  a[bw*  16  -1:bw*  15  ]}  *  {{(bw){b[bw*  16  -1]}},  b[bw*  16  -1:  bw*  15  ]};


// // wire [11:0] out1;
// // assign out1 = 
// //      {{(4){product0[2*bw-1]}},product0  }
// //   +  {{(4){product1[2*bw-1]}},product1  }
// //   +  {{(4){product2[2*bw-1]}},product2  }
// //   +  {{(4){product3[2*bw-1]}},product3  }
// //   +  {{(4){product4[2*bw-1]}},product4  }
// //   +  {{(4){product5[2*bw-1]}},product5  }
// //   +  {{(4){product6[2*bw-1]}},product6  }
// //   +  {{(4){product7[2*bw-1]}},product7  }
// //   +  {{(4){product8[2*bw-1]}},product8  }
// //   +  {{(4){product9[2*bw-1]}},product9  }
// //   +  {{(4){product10[2*bw-1]}},product10  }
// //   +  {{(4){product11[2*bw-1]}},product11  }
// //   +  {{(4){product12[2*bw-1]}},product12  }
// //   +  {{(4){product13[2*bw-1]}},product13  }
// //   +  {{(4){product14[2*bw-1]}},product14  }
// //   +  {{(4){product15[2*bw-1]}},product15  };



// endmodule
