// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 4;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 8;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0




integer  K0[col-1:0][pr-1:0];
integer  K1[col-1:0][pr-1:0];
integer  K80[col/2-1:0][pr-1:0];
integer  K81[col/2-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  result_core0[total_cycle-1:0][col-1:0];
integer  result_core1[total_cycle-1:0][col-1:0];
integer  norm_core0[total_cycle-1:0][col-1:0];
integer  norm_core1[total_cycle-1:0][col-1:0];
integer  sum[total_cycle-1:0];

integer i,j,k,t,p,q,s,u, m;

integer tmp_sum_core0;
integer tmp_sum_core1;
integer tmp_div_core0;
integer tmp_div_core1;


reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in_core0, mem_in_core1;

reg ofifo_rd_core0 = 0;
wire [18:0] inst_core0; 
reg qmem_rd_core0 = 0;
reg qmem_wr_core0 = 0; 
reg kmem_rd_core0 = 0; 
reg kmem_wr_core0 = 0;
reg pmem_rd_core0 = 0; 
reg pmem_wr_core0 = 0; 
reg execute_core0 = 0;
reg load_core0 = 0;
reg [3:0] qkmem_add_core0 = 0;
reg [3:0] pmem_add_core0 = 0;
reg div_core0 = 0;
reg acc_core0 = 0;


assign inst_core0[18] = div_core0;
assign inst_core0[17] = acc_core0;
assign inst_core0[16] = ofifo_rd_core0;
assign inst_core0[15:12] = qkmem_add_core0;
assign inst_core0[11:8]  = pmem_add_core0;
assign inst_core0[7] = execute_core0;
assign inst_core0[6] = load_core0;
assign inst_core0[5] = qmem_rd_core0;
assign inst_core0[4] = qmem_wr_core0;
assign inst_core0[3] = kmem_rd_core0;
assign inst_core0[2] = kmem_wr_core0;
assign inst_core0[1] = pmem_rd_core0;
assign inst_core0[0] = pmem_wr_core0;

reg ofifo_rd_core1 = 0;
wire [18:0] inst_core1; 
reg qmem_rd_core1 = 0;
reg qmem_wr_core1 = 0; 
reg kmem_rd_core1 = 0; 
reg kmem_wr_core1 = 0;
reg pmem_rd_core1 = 0; 
reg pmem_wr_core1 = 0; 
reg execute_core1 = 0;
reg load_core1 = 0;
reg [3:0] qkmem_add_core1 = 0;
reg [3:0] pmem_add_core1 = 0;
reg div_core1 = 0;
reg acc_core1 = 0;


assign inst_core1[18] = div_core1;
assign inst_core1[17] = acc_core1;
assign inst_core1[16] = ofifo_rd_core1;
assign inst_core1[15:12] = qkmem_add_core1;
assign inst_core1[11:8]  = pmem_add_core1;
assign inst_core1[7] = execute_core1;
assign inst_core1[6] = load_core1;
assign inst_core1[5] = qmem_rd_core1;
assign inst_core1[4] = qmem_wr_core1;
assign inst_core1[3] = kmem_rd_core1;
assign inst_core1[2] = kmem_wr_core1;
assign inst_core1[1] = pmem_rd_core1;
assign inst_core1[0] = pmem_wr_core1;



reg [bw_psum*2-1:0] temp5b_core0;
// reg [bw_psum+3:0] temp_sum;
reg [bw_psum*col-1:0] temp16b_core0;

reg [bw_psum*2-1:0] temp5b_core1;
// reg [bw_psum+3:0] temp_sum;
reg [bw_psum*col-1:0] temp16b_core1;

wire [bw_psum+6:0] sum_out;
wire [bw_psum*col*2-1:0] out;


reg width_mode = 1;
reg sign_mode = 1;


fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk_core0(clk),
      .clk_core1(clk), 
      .mem_in_core0(mem_in_core0),
      .mem_in_core1(mem_in_core1),
      .inst_core0(inst_core0),
      .inst_core1(inst_core1),
      .sum_out(sum_out),
      .out(out),
      .width_mode(width_mode),
      .sign_mode(sign_mode)
);


initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);



// ///// Q data txt reading /////

// $display("##### V data txt reading #####");


//   qk_file = $fopen("E:/VivadoProjects/ECE260Step3/verilog/data/vdata.txt", "r");

//   //// To get rid of first 3 lines in data file ////
//   // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
//   // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
//   // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
//   // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


//   for (q=0; q<total_cycle; q=q+1) begin
//     for (j=0; j<pr; j=j+1) begin
        
//           qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
//           Q[q][j] = captured_data;
//           // if (Q[q][j] < 0) 
//           //   Q[q][j] = Q[q][j] + 16;
//         $display("%d", captured_data);
//           //$display("%d\n", K[q][j]);
//     end
//   end
// /////////////////////////////////




//   for (q=0; q<2; q=q+1) begin
//     #0.5 clk = 1'b0;   
//     #0.5 clk = 1'b1;   
//   end




// ///// K data txt reading /////

// $display("##### N data txt reading #####");

//   for (q=0; q<10; q=q+1) begin
//     #0.5 clk = 1'b0;   
//     #0.5 clk = 1'b1;   
//   end
//   reset = 0;

//   qk_file = $fopen("E:/VivadoProjects/ECE260Step3/verilog/data/ndata.txt", "r");

//   //// To get rid of first 4 lines in data file ////
//   // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
//   // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
//   // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
//   // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




//   for (q=0; q<col/2; q=q+1) begin
//     for (j=0; j<pr; j=j+1) begin
//           qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
//           K[q*2][j] = captured_data[7] ? captured_data[7:4] - 16 : captured_data[7:4];
//           K[q*2+1][j] = captured_data[3] ? captured_data[3:0] - 16: captured_data[3:0];
//           // if (K[q*2][j] < 0) 
//           //   K[q*2][j] = K[q*2][j] + 16;
//           // if (K[q*2+1][j] < 0)
//           //   K[q*2+1][j] = K[q*2+1][j] + 16;
//           $display("%d, %d, %d", captured_data, K[q*2][j], K[q*2+1][j]);
//           //$display("##### %d\n", K[q][j]);
//     end
//   end
// /////////////////////////////////

///// Q data txt reading /////

$display("##### Q data txt reading #####");


  qk_file = $fopen("E:/VivadoProjects/ECE260B_DualCore/verilog/data/vdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
        
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          if (!sign_mode) begin
            if (Q[q][j] < 0) begin
              Q[q][j] = Q[q][j] + 16;
            end
          end
          else begin
            if (Q[q][j] > 7) begin
              Q[q][j] = Q[q][j] - 16;
            end
          end

        $display("%d", Q[q][j]);
          //$display("%d\n", K[q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end




///// K data txt reading /////

$display("##### K data core0 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("E:/VivadoProjects/ECE260B_DualCore/verilog/data/ndata_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);

  for (q=0; q<col/2; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K0[q*2][j] = captured_data[7:4];
          K0[q*2+1][j] = captured_data[3:0];
          K80[q][j] = captured_data;
          if (!sign_mode) begin
            if (K0[q*2][j] < 0) 
              K0[q*2][j] = K0[q*2][j] + 16;
          end
          else begin
            if (K0[q*2][j] > 7) 
              K0[q*2][j] = K0[q*2][j] - 16;
            if (K80[q][j] > 127)
              K80[q][j] = K80[q][j] - 256;
          end
          
          $display("%d, %d, %d", K80[q][j], K0[q*2][j], K0[q*2+1][j]);
          //$display("##### %d\n", K[q][j]);
    end
  end

$display("##### K data core1 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("E:/VivadoProjects/ECE260B_DualCore/verilog/data/ndata_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  // qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);

  for (q=0; q<col/2; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K1[q*2][j] = captured_data[7:4];
          K1[q*2+1][j] = captured_data[3:0];
          K81[q][j] = captured_data;
          if (!sign_mode) begin
            if (K1[q*2][j] < 0) 
              K1[q*2][j] = K1[q*2][j] + 16;
          end
          else begin
            if (K1[q*2][j] > 7) 
              K1[q*2][j] = K1[q*2][j] - 16;
            if (K81[q][j] > 127)
              K81[q][j] = K81[q][j] - 256;
          end
          
          $display("%d, %d, %d", K81[q][j], K1[q*2][j], K1[q*2+1][j]);
          //$display("##### %d\n", K[q][j]);
    end
  end
/////////////////////////////////








/////////////// Estimated result printing /////////////////


$display("##### Estimated normalization result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result_core0[t][q] = 0;
       result_core1[t][q] = 0;
     end
  end


  for (t=0; t<total_cycle; t=t+1) begin
    tmp_sum_core0 = 0;
    tmp_sum_core1 = 0;
    for (q=0; q<col/2; q=q+1) begin
      for (k=0; k<pr; k=k+1) begin
        result_core0[t][q] = result_core0[t][q] + Q[t][k] * K80[q][k];
        result_core1[t][q] = result_core1[t][q] + Q[t][k] * K81[q][k];
      end
      // if (result_core0[t][q] >= 0) 
      //   tmp_sum_core0 = tmp_sum_core0 + result_core0[t][q];
      // else 
      //   tmp_sum_core0 = tmp_sum_core0 - result_core0[t][q];

      // if (result_core1[t][q] >= 0) 
      //   tmp_sum_core1 = tmp_sum_core1 + result_core1[t][q];
      // else 
      //   tmp_sum_core1 = tmp_sum_core1 - result_core1[t][q];
      // tmp_sum = tmp_sum + result[t][q];
    end

    // $display("prd @cycle%2d: sum = %h", t, tmp_sum);

    for (q=0; q<col/2; q=q+1) begin
      // if (result_core0[t][q] >= 0)
      //   tmp_div_core0 = result_core0[t][q];
      // else
      //   tmp_div_core0 = -result_core0[t][q];

      // if (result_core1[t][q] >= 0)
      //   tmp_div_core1 = result_core1[t][q];
      // else
      //   tmp_div_core1 = -result_core1[t][q];

      // tmp_div_core0 = {tmp_div_core0, 12'b0};
      // tmp_div_core1 = {tmp_div_core1, 12'b0};

      // norm_core0[t][q] = tmp_div_core0 / tmp_sum_core0;
      // norm_core1[t][q] = tmp_div_core1 / tmp_sum_core1;

      // norm_core0[t][q] = tmp_div_core0 / (tmp_sum_core0 + tmp_sum_core1);
      // norm_core1[t][q] = tmp_div_core1 / (tmp_sum_core0 + tmp_sum_core1);

      temp5b_core0 = result_core0[t][q];
      temp16b_core0 = {temp16b_core0[139:0], temp5b_core0};

      temp5b_core1 = result_core1[t][q];
      temp16b_core1 = {temp16b_core1[139:0], temp5b_core1};
      // temp16b = {temp16b[139:0], temp5b};
    end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     $display("prd @cycle%2d: %24h %24h", t, temp16b_core0, temp16b_core1);
    //  $display("prd @cycle%2d: %3h %3h %3h %3h %3h %3h %3h %3h", t, norm[t][0], norm[t][1], norm[t][2], norm[t][3], norm[t][4], norm[t][5], norm[t][6], norm[t][7]);
    //  $display("prd @cycle%2d: %d %d %d %d %d %d %d %d", t, norm[t][0], norm[t][1], norm[t][2], norm[t][3], norm[t][4], norm[t][5], norm[t][6], norm[t][7]);
  end

//////////////////////////////////////////////






///// Qmem writing  /////

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr_core0 = 1;  if (q>0) qkmem_add_core0 = qkmem_add_core0 + 1; 
    qmem_wr_core1 = 1;  if (q>0) qkmem_add_core1 = qkmem_add_core1 + 1; 
    
    mem_in_core0[1*bw-1:0*bw] = Q[q][0];
    mem_in_core0[2*bw-1:1*bw] = Q[q][1];
    mem_in_core0[3*bw-1:2*bw] = Q[q][2];
    mem_in_core0[4*bw-1:3*bw] = Q[q][3];
    mem_in_core0[5*bw-1:4*bw] = Q[q][4];
    mem_in_core0[6*bw-1:5*bw] = Q[q][5];
    mem_in_core0[7*bw-1:6*bw] = Q[q][6];
    mem_in_core0[8*bw-1:7*bw] = Q[q][7];

    mem_in_core1[1*bw-1:0*bw] = Q[q][0];
    mem_in_core1[2*bw-1:1*bw] = Q[q][1];
    mem_in_core1[3*bw-1:2*bw] = Q[q][2];
    mem_in_core1[4*bw-1:3*bw] = Q[q][3];
    mem_in_core1[5*bw-1:4*bw] = Q[q][4];
    mem_in_core1[6*bw-1:5*bw] = Q[q][5];
    mem_in_core1[7*bw-1:6*bw] = Q[q][6];
    mem_in_core1[8*bw-1:7*bw] = Q[q][7];

    #0.5 clk = 1'b1;  

  end


  #0.5 clk = 1'b0;  
  qmem_wr_core0 = 0; 
  qkmem_add_core0 = 0;
  qmem_wr_core1 = 0; 
  qkmem_add_core1 = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////





///// Kmem writing  /////

$display("##### Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr_core0 = 1; if (q>0) qkmem_add_core0 = qkmem_add_core0 + 1; 
    kmem_wr_core1 = 1; if (q>0) qkmem_add_core1 = qkmem_add_core1 + 1; 
    
    mem_in_core0[1*bw-1:0*bw] = K0[q][0];
    mem_in_core0[2*bw-1:1*bw] = K0[q][1];
    mem_in_core0[3*bw-1:2*bw] = K0[q][2];
    mem_in_core0[4*bw-1:3*bw] = K0[q][3];
    mem_in_core0[5*bw-1:4*bw] = K0[q][4];
    mem_in_core0[6*bw-1:5*bw] = K0[q][5];
    mem_in_core0[7*bw-1:6*bw] = K0[q][6];
    mem_in_core0[8*bw-1:7*bw] = K0[q][7];

    mem_in_core1[1*bw-1:0*bw] = K1[q][0];
    mem_in_core1[2*bw-1:1*bw] = K1[q][1];
    mem_in_core1[3*bw-1:2*bw] = K1[q][2];
    mem_in_core1[4*bw-1:3*bw] = K1[q][3];
    mem_in_core1[5*bw-1:4*bw] = K1[q][4];
    mem_in_core1[6*bw-1:5*bw] = K1[q][5];
    mem_in_core1[7*bw-1:6*bw] = K1[q][6];
    mem_in_core1[8*bw-1:7*bw] = K1[q][7];

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;  
  kmem_wr_core0 = 0;  
  qkmem_add_core0 = 0;
  kmem_wr_core1 = 0;  
  qkmem_add_core1 = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////



  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end




/////  K data loading  /////
$display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;  
    load_core0 = 1; 
    load_core1 = 1;
    if (q==1) kmem_rd_core0 = 1;
    if (q>1) begin
       qkmem_add_core0 = qkmem_add_core0 + 1;
    end
    if (q==1) kmem_rd_core1 = 1;
    if (q>1) begin
       qkmem_add_core1 = qkmem_add_core1 + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  kmem_rd_core0 = 0; qkmem_add_core0 = 0;
  kmem_rd_core1 = 0; qkmem_add_core1 = 0;
  #0.5 clk = 1'b1;  

  #0.5 clk = 1'b0;  
  load_core0 = 0; 
  load_core1 = 0; 
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end





///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    execute_core0 = 1; 
    qmem_rd_core0 = 1;
    execute_core1 = 1; 
    qmem_rd_core1 = 1;

    if (q>0) begin
       qkmem_add_core0 = qkmem_add_core0 + 1;
    end
    if (q>0) begin
       qkmem_add_core1 = qkmem_add_core1 + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  qmem_rd_core0 = 0; qkmem_add_core0 = 0; execute_core0 = 0;
  qmem_rd_core1 = 0; qkmem_add_core1 = 0; execute_core1 = 0;
  #0.5 clk = 1'b1;  


///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end




////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");
  #0.5 clk = 1'b0;

  #0.5 clk = 1'b1;

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    ofifo_rd_core0 = 1; 
    ofifo_rd_core1 = 1; 
    acc_core0 = 1'b1; div_core0 = 1'b1;
    acc_core1 = 1'b1; div_core1 = 1'b1;
    
    if (q > 0) begin
      pmem_wr_core0 = 1; 
      pmem_wr_core1 = 1; 
    end
    if (q>1) begin
       pmem_add_core0 = pmem_add_core0 + 1;
       pmem_add_core1 = pmem_add_core1 + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  pmem_add_core0 = pmem_add_core0 + 1;
  pmem_add_core1 = pmem_add_core1 + 1;
  acc_core0 = 1'b0; div_core0 = 1'b0;
  acc_core1 = 1'b0; div_core1 = 1'b0;
  #0.5 clk = 1'b1;  

  #0.5 clk = 1'b0;  
  
  pmem_wr_core0 = 0; pmem_add_core0 = 0; ofifo_rd_core0 = 0;
  pmem_wr_core1 = 0; pmem_add_core1 = 0; ofifo_rd_core1 = 0;
  
  #0.5 clk = 1'b1;  

///////////////////////////////////////////




  #10 $finish;


end

endmodule




