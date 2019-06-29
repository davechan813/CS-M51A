// EEM16 - Logic Design
// 2019_04_08
// Design Assignment #1 - Example Solutions
// dassign1.v

module nand2(y,a,b);
   output y;
   input a,b;
   wire d;
   assign d=a&b ;
   assign y=~(d);
endmodule

module dassign1_1 (y, nando[3:0], a, b, c, d, e);
   output y;
   output [3:0] nando;
   input a,b,c,d,e;
   wire y;
   wire [3:0] nando;

/*
 * Note: nando[3:0] are 4 outputs of the NAND gates that is internal to your
 * logic (not including the one that drives the output). You should need only
 * 5 NAND gates in this solution.
 * This allows the autograder to check the internal logic.
 * The ordering/assignment of the output to specific NAND gate does not matter.
 */

 //
 // Your code below
 //
  nand2 n1(.y(nando[0]), .a(~a), .b(b));
  nand2 n2(.y(nando[1]), .a(c), .b(~d));
  nand2 n3(.y(nando[2]), .a(nando[0]), .b(nando[1]));
  nand2 n4(.y(nando[3]), .a(nando[2]), .b(e));
  nand2 n5(.y(y), .a(nando[3]), .b(nando[3]));
  
endmodule

module Chm16 (Ch, E, F,G);
  output [31:0] Ch;
  input [31:0] E,F,G;
 //
 // Your code below
 //
  wire [31:0] w [0:1];
  assign w[0]= E&F;
  assign w[1]= (~E)&G;
  assign Ch = w[0]^w[1];

endmodule

//
// Note the 2 different ways to specify the input/output declarations
//
module MAm16 (
  output [31:0] Maj,
  input [31:0] A,B,C
  );
 //
 // Your code below
 //
  wire [31:0] w [0:2];
  assign w[0]= A&B;
  assign w[1]= A&C;
  assign w[2]= B&C;
  assign Maj= w[0]^w[1]^w[2];
  
endmodule

module S0m16 (S0, A);
 //
 // Your code below
 //
  output [31:0] S0;
  input [31:0] A;
  wire [31:0] w [0:2];
  assign w[0]= {A[1:0], A[31:2]};
  assign w[1]= {A[12:0], A[31:13]};
  assign w[2]= {A[21:0], A[31:22]};
  assign S0= w[0]^w[1]^w[2];

endmodule
// abcdef
//    210
// efabcd


module S1m16 (S1, E);
 //
 // Your code below
 //
  output [31:0] S1;
  input [31:0] E;
  wire [31:0] w1, w2, w3;
  assign w1 = {E[5:0], E[31:6]};
  assign w2 = {E[10:0], E[31:11]};
  assign w3 = {E[24:0], E[31:25]};
  assign S1 = w1^w2^w3;

endmodule

module dassign1_2 (Ch, Maj, S0, S1,
                   hashiA, hashiB, hashiC, hashiD, hashiE, hashiF, hashiG);
  output [31:0] Ch, Maj, S0, S1;
  input [31:0] hashiA, hashiB, hashiC, hashiD, hashiE, hashiF, hashiG;
 //
 // Your code below
 //
  Chm16 chm(.Ch(Ch), .E(hashiE), .F(hashiF),.G(hashiG));
  MAm16 mam(.Maj(Maj), .A(hashiA), .B(hashiB), .C(hashiC));
  S0m16 s0m(.S0(S0), .A(hashiA));
  S1m16 s1m(.S1(S1), .E(hashiE));
  
endmodule // dassign1_2

module dassign1_3 (aa, codon);
   output [4:0] aa;
   input [5:0] codon;

   localparam NU=2'b00;
   localparam NC=2'b01;
   localparam NA=2'b10;
   localparam NG=2'b11;

   reg [4:0] 	aa;

   always @(codon) begin
  //
  // Your code below
  //
   casez(codon)
      {NU, NU, NU}, {NU, NU, NC}: aa=5'b00000;
      {NU, NU, NA}, {NU, NU, NG}: aa=5'b00001;
      {NU, NC, 2'b??}:            aa=5'b00010;
      {NU, NA, NU}, {NU, NA, NC}: aa=5'b00011;
      {NU, NA, NA}, {NU, NA, NG}: aa=5'b00100;
      {NU, NG, NU}, {NU, NG, NC}: aa=5'b00101;
      {NU, NG, NA}:               aa=5'b00100;
      {NU, NG, NG}:               aa=5'b00110;
      {NC, NU, 2'b??}:            aa=5'b00001;
      {NC, NC, 2'b??}:            aa=5'b00111;
      {NC, NA, NC}, {NC, NA, NU}: aa=5'b01000;
      {NC, NA, NG}, {NC, NA, NA}: aa=5'b01001;
      {NC, NG, 2'b??}:            aa=5'b01010;
      {NA, NU, NA}, {NA, NU, NC}: aa=5'b01011;
      {NA, NU, NU}:               aa=5'b01011;
      {NA, NU, NG}:               aa=5'b01100;
      {NA, NC, 2'b??}:            aa=5'b01101;
      {NA, NA, NC}, {NA, NA, NU}: aa=5'b01110;
      {NA, NA, NG}, {NA, NA, NA}: aa=5'b01111;
      {NA, NG, NC}, {NA, NG, NU}: aa=5'b00010;
      {NA, NG, NG}, {NA, NG, NA}: aa=5'b01010;
      {NG, NU, 2'b??}:            aa=5'b10000;
      {NG, NC, 2'b??}:            aa=5'b10001;
      {NG, NA, NC}, {NG, NA, NU}: aa=5'b10010;
      {NG, NA, NA}, {NG, NA, NG}: aa=5'b10011;
      {NG, NG, 2'b??}:            aa=5'b10100;
   endcase
   end //always

endmodule // dassign1_3
