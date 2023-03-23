module controller(
   clk, 
   reset,
   done, 
   controller_inst
);

parameter col = 8;
parameter total_cycle = 8;

input  clk;
input  reset;

output done;
output [22:0] controller_inst;

assign done = (state == 6);
assign controller_inst = {kmem_add, sfu_div, sfu_acc, ofifo_rd, qmem_add, pmem_add, execute, load, qmem_rd, qmem_wr, kmem_rd, kmem_wr, pmem_rd, pmem_wr};

reg kmem_wr, kmem_rd;
reg [3:0] kmem_add;

reg qmem_wr, qmem_rd;
reg [3:0] qmem_add;

reg pmem_wr, pmem_rd;
reg [3:0] pmem_add;

reg load;
reg execute;

reg sfu_acc;
reg sfu_div;

reg ofifo_rd;

reg [2:0] state; //0: idle, 1: kmem writing, 2: q_mem_writing and k data to array, 3: q data to array and execute, 4: sfu, 5: reading from pmem, 6: done, 7: error

reg [5:0] counter;

always @ (posedge clk, posedge reset) begin
   if (reset) begin
      state <= 0;
      counter <= 0;

      kmem_wr <= 0;
      kmem_rd <= 0;
      kmem_add <= 0;

      qmem_wr <= 0;
      qmem_rd <= 0;
      qmem_add <= 0;

      pmem_wr <= 0;
      pmem_rd <= 0;
      pmem_add <= 0;

      load <= 0;
      execute <= 0;

      sfu_acc <= 0;
      sfu_div <= 0;

      ofifo_rd <= 0;
   end
   else begin
      if (state == 0) begin
         state <= 1;
         counter <= 0;

         kmem_wr <= 1;
         kmem_rd <= 0;
         kmem_add <= 0;

         qmem_wr <= 0;
         qmem_rd <= 0;
         qmem_add <= 0;

         pmem_wr <= 0;
         pmem_rd <= 0;
         pmem_add <= 0;

         load <= 0;
         execute <= 0;

         sfu_acc <= 0;
         sfu_div <= 0;

         ofifo_rd <= 0;
      end
      else if (state == 1) begin
         if (counter == col-1) begin
            state <= 2;
            counter <= 0;

            kmem_wr <= 0;
            kmem_rd <= 1;
            kmem_add <= 0;

            qmem_wr <= 1;
            qmem_rd <= 0;
            qmem_add <= 0;

            pmem_wr <= 0;
            pmem_rd <= 0;
            pmem_add <= 0;

            load <= 1;
            execute <= 0;

            sfu_acc <= 0;
            sfu_div <= 0;

            ofifo_rd <= 0;
         end
         else begin
            counter <= counter + 1;
            kmem_add <= kmem_add + 1;
         end
      end
      else if (state == 2) begin
         if (counter == total_cycle+1) begin
            state <= 3;
            counter <= 0;

            kmem_wr <= 0;
            kmem_rd <= 0;
            kmem_add <= 0;

            qmem_wr <= 0;
            qmem_rd <= 1;
            qmem_add <= 0;

            pmem_wr <= 0;
            pmem_rd <= 0;
            pmem_add <= 0;

            load <= 0;
            execute <= 1;

            sfu_acc <= 0;
            sfu_div <= 0;

            ofifo_rd <= 0;
         end
         else begin
            counter <= counter + 1;
            if (counter < total_cycle) begin
               qmem_add <= qmem_add + 1;
            end 
            if (counter > col) begin
               load <= 0;
            end
            if (counter > 0) begin
               kmem_add <= kmem_add + 1;
            end
         end
      end
      else if (state == 3) begin
         if (counter == total_cycle + 10) begin
            state <= 4;
            counter <= 0;

            kmem_wr <= 0;
            kmem_rd <= 0;
            kmem_add <= 0;

            qmem_wr <= 0;
            qmem_rd <= 0;
            qmem_add <= 0;

            pmem_wr <= 0;
            pmem_rd <= 0;
            pmem_add <= 0;

            load <= 0;
            execute <= 0;

            sfu_acc <= 1;
            sfu_div <= 0;

            ofifo_rd <= 1;
         end
         else begin
            counter <= counter + 1;
            qmem_add <= qmem_add + 1;
            if (counter > total_cycle) begin
               qmem_rd <= 0;
               execute <= 0;
            end
         end
      end
      else if (state == 4) begin
         if (counter == total_cycle + 1) begin
            state <= 6;
            counter <= 0;

            kmem_wr <= 0;
            kmem_rd <= 0;
            kmem_add <= 0;

            qmem_wr <= 0;
            qmem_rd <= 0;
            qmem_add <= 0;

            pmem_wr <= 0;
            pmem_rd <= 0;
            pmem_add <= 0;

            load <= 0;
            execute <= 0;

            sfu_acc <= 0;
            sfu_div <= 0;

            ofifo_rd <= 0;
         end
         else begin 
            sfu_div <= 1;
            pmem_wr <= 1;
            counter <= counter + 1;
            if (counter > 0) begin
               pmem_add <= pmem_add + 1;
            end
            if (counter >= total_cycle) begin
               pmem_wr <= 0;

            end
         end
      end
   end
end

endmodule
