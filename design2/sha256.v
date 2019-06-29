// ECEM16 - Logic Design
// 2019_04_11
// Design Assignment #2 - Utility Functions for SHA256
// sha256.v
//

module Chm16 (Ch, E, F, G);
  output [31:0] Ch;
  input [31:0] E,F, G;

  assign Ch = (E & F) ^ (~E & G);
endmodule

module MAm16 (Maj, A, B, C);
  output [31:0] Maj;
  input [31:0] A,B,C;

  assign Maj = (A & B) ^ (A & C) ^ (B & C);
endmodule

module S0m16 (S0, A);
  output [31:0] S0;
  input [31:0] A;

  assign S0 = {A[1:0],A[31:2]} ^ {A[12:0], A[31:13]} ^ {A[21:0], A[31:22]};
endmodule

module S1m16 (S1, E);
  output [31:0] S1;
  input [31:0] E;

  assign S1 = {E[5:0],E[31:6]} ^ {E[10:0], E[31:11]} ^ {E[24:0], E[31:25]};
// endSoln
endmodule

module W_machine (
    output [31:0] W,
    input [511:0] M,
    input M_v,
    input clk
    );

wire [31:0] s0_Wtm15 = ({W_tm15[6:0], W_tm15[31:7]} ^ {W_tm15[17:0], W_tm15[31:18]} ^ (W_tm15 >> 3));
wire [31:0] s1_Wtm2 = ({W_tm2[16:0], W_tm2[31:17]} ^ {W_tm2[18:0], W_tm2[31:19]} ^ (W_tm2 >> 10));

wire [31:0] W_tm2 = W_stack_q[63:32];
wire [31:0] W_tm15 = W_stack_q[479:448];
wire [31:0] W_tm7 = W_stack_q[223:192];
wire [31:0] W_tm16 = W_stack_q[511:480];

// Wt_next is the next Wt to be pushed to the queue, will be consumed in 16 rounds
wire [31:0] Wt_next = s1_Wtm2 + W_tm7 + s0_Wtm15 + W_tm16;

reg [511:0] W_stack_q;

wire [511:0] W_stack_d = {W_stack_q[479:0], Wt_next};

assign W = W_stack_q[511:480];

always @(posedge clk)
begin
    if (M_v) begin
        W_stack_q <= M;
    end else begin
        W_stack_q <= W_stack_d;
    end
//    $display("W_stack: %h", W_stack_q);
end
endmodule

module K_machine (
    output [31:0] K,
    input rst,
    input clk
    );

reg [2047:0] rom_q;
wire [2047:0] rom_d = { rom_q[2015:0], rom_q[2047:2016] };
assign K = rom_q[2047:2016];

always @(posedge clk)
begin
    if (rst) begin
        rom_q <= {
            32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
            32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
            32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
            32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
            32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
            32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
            32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
            32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
            32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
            32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
            32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
            32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
            32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
            32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
            32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
            32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
        };
    end else begin
        rom_q <= rom_d;
    end
end
endmodule

module H_startup(
    output [255:0] H_init
    );

assign H_init = {
    32'h6A09E667, 32'hBB67AE85, 32'h3C6EF372, 32'hA54FF53A,
    32'h510E527F, 32'h9B05688C, 32'h1F83D9AB, 32'h5BE0CD19
};
endmodule
