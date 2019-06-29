//--------------------------------------------------------------------
//		Timescale
//		Means that if you do #1 in the initial block of your
//		testbench, time is advanced by 1ns instead of 1ps
//--------------------------------------------------------------------
`timescale 1ns / 1ps
// Compatibility directive for >0.97a
`default_nettype none
//--------------------------------------------------------------------
//		Design Assign #2, Testbench.
//--------------------------------------------------------------------

module dassign2_tb();
   //----------------------------------------------------------------
   //		Test Bench Signal Declarations
   //----------------------------------------------------------------
   integer i, j, outfile;
   reg clk;

   //----------------------------------------------------------------
   //		Instantiate modules Module
   //----------------------------------------------------------------

   H_startup Hm16(H256_0);
   dassign2_1 dassign2_1(H256_out, out_v, H256_in, M256_in, in_v, clk);
   dassign2_2	dassign2_2(heading, blked, reset, clk);

   //----------------------------------------------------------------
   //		Design Task #1 Signal Declarations
   //----------------------------------------------------------------
   wire out_v;
   reg in_v = 1'b0;
   reg  [511:0] M256_in;
   wire [511:0] M256_abc[0:2];
   wire [255:0] H256_abc_chk[0:2]; // room for 2 more test vectors for you 

   // 'abc' test vector
   assign M256_abc[0] = {
     256'h6162638000000000000000000000000000000000000000000000000000000000,
     256'h0000000000000000000000000000000000000000000000000000000000000018
   };
   assign  H256_abc_chk[0] = {
     256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
   };

   wire [255:0] H256_0, H256_out;
   reg [255:0] H256_in = 0;

   //----------------------------------------------------------------
   //		Design Task #2 Signal Declarations
   //----------------------------------------------------------------
   reg [5:0] route[0:15];

   reg reset = 1'b0;
   reg [2:0] blked = 3'b000;
   wire [2:0] heading;

   //----------------------------------------------------------------
   //		Test Stimulus
   //----------------------------------------------------------------
   initial begin
      outfile=$fopen("dassign2.txt");
      if (!outfile) begin
        $display("FAIL WRITE FILE");
	      $finish;
      end

      $dumpfile("dassign2.vcd");
      $dumpvars(0,dassign2_tb);
      tick;
      // Note:
      // you can increase the number of test vectors as you choose
      //
      for (i=0;i<1;i=i+1) begin
        H256_in = H256_0;
        M256_in = M256_abc[i];
        in_v = 1'b1;
        tick;
        in_v = 1'b0;
        repeat (66) begin
          tick;
          hash_chk;
        end
      end
      tick;
      $readmemb("./route_in_stud.mem", route);
      reset = 1;
      tick;
      reset = 0;
      for(i=0;i<16;i=i+1) begin
        blked = route[i][5:3];
        tick;
      end
    $finish;
   end

   task tick;
   begin
     #10;
     clk = 1;
     #10;
     clk = 0;
   end
   endtask

   task hash_chk;
   begin
     if (out_v) begin
       $display("Block output %h\n", H256_out);
     end
   end
   endtask
   
endmodule // dassign2_tb
