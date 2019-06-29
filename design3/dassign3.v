`timescale 1ns / 1ps

/* 
 * Definition: X is 1, O is 0
 */
`define X_TILE 1'b1
`define O_TILE 1'b0

/* 
 * Optional: (you may use if you want)
 * Game states 
 */
`define GAME_ST_START	  4'b0000
`define GAME_ST_TURN_X 	4'b0001
`define GAME_ST_ERR_X 	4'b0010
`define GAME_ST_CHKV_X 	4'b0011
`define GAME_ST_CHKW_X 	4'b0100
`define GAME_ST_WIN_X 	4'b0101
`define GAME_ST_TURN_O 	4'b0110
`define GAME_ST_ERR_O 	4'b0111
`define GAME_ST_CHKV_O 	4'b1000
`define GAME_ST_CHKW_O 	4'b1001
`define GAME_ST_WIN_O 	4'b1010
`define GAME_ST_CATS 	  4'b1011

  /* The grid looks like this:
   * 8 | 7 | 6
   * --|---|---
   * 5 | 4 | 3
   * --|---|---
   * 2 | 1 | 0
   */

  /* 
   * Winning combinations (treys) are the following:
   * 852, 741, 630, 876, 543, 210, 840, 642
   */
  
  /* Suggestions
   * Create a module to check for a validity of a move
   * Create modules to check for a victory in the treys
   */

module CheckValid(valid, occ_square, sel_pos);
  output valid;
  input [8:0] occ_square, sel_pos;

  // TODO: 确认
  assign valid = ~((occ_square[0] & sel_pos[0]) | (occ_square[1] & sel_pos[1]) | (occ_square[2] & sel_pos[2]) | 
                   (occ_square[3] & sel_pos[3]) | (occ_square[4] & sel_pos[4]) | (occ_square[5] & sel_pos[5]) |
                   (occ_square[6] & sel_pos[6]) | (occ_square[7] & sel_pos[7]) | (occ_square[8] & sel_pos[8]) );
endmodule

module CheckWin(WinX, WinO, Cats, Full, occ_square, occ_player);
  output WinX;
  output WinO;
  output Cats;
  output Full;
  input [8:0] occ_square, occ_player;

  // TODO: 确认
  assign WinX = (occ_square[0] & occ_square[1] & occ_square[2] & occ_player[0] & occ_player[1] & occ_player[2]) |
                (occ_square[3] & occ_square[4] & occ_square[5] & occ_player[3] & occ_player[4] & occ_player[5]) |
                (occ_square[6] & occ_square[7] & occ_square[8] & occ_player[6] & occ_player[7] & occ_player[8]) |
                (occ_square[0] & occ_square[3] & occ_square[6] & occ_player[0] & occ_player[3] & occ_player[6]) |
                (occ_square[1] & occ_square[4] & occ_square[7] & occ_player[1] & occ_player[4] & occ_player[7]) |
                (occ_square[2] & occ_square[5] & occ_square[8] & occ_player[2] & occ_player[5] & occ_player[8]) |
                (occ_square[2] & occ_square[4] & occ_square[6] & occ_player[2] & occ_player[4] & occ_player[6]) |
                (occ_square[0] & occ_square[4] & occ_square[8] & occ_player[0] & occ_player[4] & occ_player[8]) ;

  assign WinO = (occ_square[0] & occ_square[1] & occ_square[2] & ~occ_player[0] & ~occ_player[1] & ~occ_player[2]) |
                (occ_square[3] & occ_square[4] & occ_square[5] & ~occ_player[3] & ~occ_player[4] & ~occ_player[5]) |
                (occ_square[6] & occ_square[7] & occ_square[8] & ~occ_player[6] & ~occ_player[7] & ~occ_player[8]) |
                (occ_square[0] & occ_square[3] & occ_square[6] & ~occ_player[0] & ~occ_player[3] & ~occ_player[6]) |
                (occ_square[1] & occ_square[4] & occ_square[7] & ~occ_player[1] & ~occ_player[4] & ~occ_player[7]) |
                (occ_square[2] & occ_square[5] & occ_square[8] & ~occ_player[2] & ~occ_player[5] & ~occ_player[8]) |
                (occ_square[2] & occ_square[4] & occ_square[6] & ~occ_player[2] & ~occ_player[4] & ~occ_player[6]) |
                (occ_square[0] & occ_square[4] & occ_square[8] & ~occ_player[0] & ~occ_player[4] & ~occ_player[8]) ;

  assign Cats = occ_square[0] & occ_square[1] & occ_square[2] & occ_square[3] & occ_square[4] &
                occ_square[5] & occ_square[6] & occ_square[7] & occ_square[8] & ~WinX & ~WinO ;
endmodule

module tictactoe(turnX, turnO, occ_pos, occ_square, occ_player, game_st_ascii, reset, clk, flash_clk, sel_pos, buttonX, buttonO);
  output turnX;
  output turnO;
  output [8:0] occ_pos, occ_square, occ_player;
  output [7:0] game_st_ascii;

  input reset, clk, flash_clk;
  input [8:0] sel_pos;
  input buttonX, buttonO;

  /* 
   * occ_square states if there's a tile in this square or not 
   * occ_player states which type of tile is in the square 
   * game_state is the 4 bit curent state;
   * occ_pos is the board with flashing 
   */
  reg [8:0] occ_square = 9'b000000000;
  reg [8:0] occ_player = 9'b000000000;
  reg [3:0] game_state;
  // wire [8:0] occ_pos;
  reg [8:0] occ_pos; // ?

  // wire [3:0] nx_game_state;
  reg [3:0] nx_game_state; // ?

  reg turnX, turnO; // ?

  reg[7:0] game_st_ascii = 8'b01101110; // n = 110

  // TODO: 确认
  reg [8:0] nx_occ_player = 9'b000000000;
  reg [8:0] nx_occ_square = 9'b000000000;

  
  wire valid = 1;
  CheckValid cv(valid, occ_square, sel_pos);

  wire WinX, WinO, Cats, Full;
  CheckWin cw(WinX, WinO, Cats, Full, occ_square, occ_player);

  /*
   * Registers
   *  -- game_state register is provided to get you started
   */ 
  always @(posedge clk) begin
    game_state <= nx_game_state;
    // TODO: 确认
    if (valid) begin
      occ_square <= nx_occ_square;
      occ_player <= nx_occ_player;
    end
  end
  
  integer i; // for for loop
  always @(*) begin
    if (WinX || WinO) begin // only care about occ_pos when X or O wins
      for (i = 0; i < 9; i = i + 1) begin
        if (occ_square[i] && occ_player[i]) begin // occupied by X
          occ_pos[i] = 1;
        end
      end
    end
  end

  reg flag = 0; // flag to realize half flash_clk
  always @(posedge flash_clk) begin
    flag = ~flag;
    if (WinX || WinO) begin // only care about occ_pos when X or O wins
      if (!flag) begin // means we are in HIGH at 1/2 flash_clk
        for (i = 0; i < 9; i = i + 1) begin
          if (occ_square[i] && !occ_player[i]) begin // occupied by O
            occ_pos[i] = ~occ_pos[i];
          end
        end
      end

      /* BEGIN detect winning positions */
      if ((occ_square[0] && occ_square[1] && occ_square[2] &&  occ_player[0] &&  occ_player[1] &&  occ_player[2]) || 
          (occ_square[0] && occ_square[1] && occ_square[2] && !occ_player[0] && !occ_player[1] && !occ_player[2])) begin
        occ_pos[0] = ~occ_pos[0];
        occ_pos[1] = ~occ_pos[1];
        occ_pos[2] = ~occ_pos[2];
      end

      if ((occ_square[3] && occ_square[4] && occ_square[5] &&  occ_player[3] &&  occ_player[4] &&  occ_player[5]) ||
          (occ_square[3] && occ_square[4] && occ_square[5] && !occ_player[3] && !occ_player[4] && !occ_player[5])) begin
        occ_pos[3] = ~occ_pos[3];
        occ_pos[4] = ~occ_pos[4];
        occ_pos[5] = ~occ_pos[5];
      end

      if ((occ_square[6] && occ_square[7] && occ_square[8] &&  occ_player[6] &&  occ_player[7] &&  occ_player[8]) ||
          (occ_square[6] && occ_square[7] && occ_square[8] && !occ_player[6] && !occ_player[7] && !occ_player[8])) begin
        occ_pos[6] = ~occ_pos[6];
        occ_pos[7] = ~occ_pos[7];
        occ_pos[8] = ~occ_pos[8];
      end

      if ((occ_square[0] && occ_square[3] && occ_square[6] &&  occ_player[0] &&  occ_player[3] &&  occ_player[6]) ||
          (occ_square[0] && occ_square[3] && occ_square[6] && !occ_player[0] && !occ_player[3] && !occ_player[6])) begin
        occ_pos[0] = ~occ_pos[0];
        occ_pos[3] = ~occ_pos[3];
        occ_pos[6] = ~occ_pos[6];
      end

      if ((occ_square[1] && occ_square[4] && occ_square[7] &&  occ_player[1] &&  occ_player[4] &&  occ_player[7]) ||
          (occ_square[1] && occ_square[4] && occ_square[7] && !occ_player[1] && !occ_player[4] && !occ_player[7])) begin
        occ_pos[1] = ~occ_pos[1];
        occ_pos[4] = ~occ_pos[4];
        occ_pos[7] = ~occ_pos[7];
      end

      if ((occ_square[2] && occ_square[5] && occ_square[8] &&  occ_player[2] &&  occ_player[5] &&  occ_player[8]) ||
          (occ_square[2] && occ_square[5] && occ_square[8] && !occ_player[2] && !occ_player[5] && !occ_player[8])) begin
        occ_pos[2] = ~occ_pos[2];
        occ_pos[5] = ~occ_pos[5];
        occ_pos[8] = ~occ_pos[8];
      end

      if ((occ_square[2] && occ_square[4] && occ_square[6] &&  occ_player[2] &&  occ_player[4] &&  occ_player[6]) ||
          (occ_square[2] && occ_square[4] && occ_square[6] && !occ_player[2] && !occ_player[4] && !occ_player[6])) begin
        occ_pos[2] = ~occ_pos[2];
        occ_pos[4] = ~occ_pos[4];
        occ_pos[6] = ~occ_pos[6];
      end

      if ((occ_square[0] && occ_square[4] && occ_square[8] &&  occ_player[0] &&  occ_player[4] &&  occ_player[8]) ||
          (occ_square[0] && occ_square[4] && occ_square[8] && !occ_player[0] && !occ_player[4] && !occ_player[8])) begin
        occ_pos[0] = ~occ_pos[0];
        occ_pos[4] = ~occ_pos[4];
        occ_pos[8] = ~occ_pos[8];
      end
      /* END detect winning positions */
    end
  end

  always @(*) begin
    if (reset) begin
      turnX = 1'b0;
      turnO = 1'b0;
      game_st_ascii = 8'b01101110; // n = 110
      occ_square    = 9'b000000000;
      occ_player    = 9'b000000000;
      occ_pos       = 9'b000000000;
      nx_occ_square = 9'b000000000;
      nx_occ_player = 9'b000000000;
      nx_game_state = `GAME_ST_START;
    end
    else begin
      case(game_state)
        `GAME_ST_START: begin
          turnX = 1'b0;
          turnO = 1'b0;
          game_st_ascii = 8'b01101110; // n = 110
          nx_game_state = `GAME_ST_TURN_X;
        end

        `GAME_ST_TURN_X: begin
          turnX = 1'b1;
          turnO = 1'b0;
          game_st_ascii = 8'b01101110; // n = 110

          if (buttonO) begin
            nx_game_state = `GAME_ST_ERR_X;
          end
          else if (buttonX) begin
            nx_game_state = `GAME_ST_CHKV_X;
          end
          else begin // !buttonO && !buttonX
            nx_game_state = `GAME_ST_TURN_X;
          end
        end

        `GAME_ST_ERR_X: begin
          turnX = 1'b1;
          turnO = 1'b0;
          game_st_ascii = 8'b01000101; // E = 69
          nx_occ_square = occ_square;
          nx_occ_player = occ_player;

          if (buttonX) begin
            nx_game_state = `GAME_ST_CHKV_X;
          end
          else begin
            nx_game_state = `GAME_ST_ERR_X;
          end
        end

        `GAME_ST_CHKV_X: begin
          turnX = 1'b0;
          turnO = 1'b0;
          game_st_ascii = 8'b01101110; // n = 110
          // update posX
          nx_occ_square = occ_square | sel_pos;
          nx_occ_player = occ_player | sel_pos;

          
          if (valid) begin
            nx_game_state = `GAME_ST_CHKW_X;
          end
          else begin
            nx_game_state = `GAME_ST_ERR_X;
          end
        end

        `GAME_ST_CHKW_X: begin
          turnX = 1'b0;
          turnO = 1'b0;
          game_st_ascii = 8'b01101110; // n = 110
          
          if (WinX) begin
            nx_game_state = `GAME_ST_WIN_X;
          end
          else if (Cats) begin
            nx_game_state = `GAME_ST_CATS;
          end
          else begin
            nx_game_state = `GAME_ST_TURN_O;
          end
        end

        `GAME_ST_WIN_X: begin
          turnX = 1'b0;
          turnO = 1'b0;
          game_st_ascii = 8'b01011000; // X = 88
          nx_game_state = `GAME_ST_WIN_X;
        end

        `GAME_ST_TURN_O: begin
          turnX = 1'b0;
          turnO = 1'b1;
          game_st_ascii = 8'b01101110; // n = 110

          if (buttonO) begin
            nx_game_state = `GAME_ST_CHKV_O;
          end
          else if (buttonX) begin
            nx_game_state = `GAME_ST_ERR_O;
          end
          else begin // !buttonO && !buttonX
            nx_game_state = `GAME_ST_TURN_O;
          end
        end

        `GAME_ST_ERR_O: begin
          turnX = 1'b0;
          turnO = 1'b1;
          game_st_ascii = 8'b01000101; // E = 69
          nx_occ_square = occ_square;
          nx_occ_player = occ_player;

          if (buttonO) begin
            nx_game_state = `GAME_ST_CHKV_O;
          end
          else begin
            nx_game_state = `GAME_ST_ERR_O;
          end
        end

        `GAME_ST_CHKV_O: begin
          turnX = 1'b0;
          turnO = 1'b0;
          game_st_ascii = 8'b01101110; // n = 110

          // update posO
          nx_occ_square = occ_square | sel_pos;

          if (valid) begin
            nx_game_state = `GAME_ST_CHKW_O;
          end
          else begin
            nx_game_state = `GAME_ST_ERR_O;
          end
        end

        `GAME_ST_CHKW_O: begin
          turnX = 1'b0;
          turnO = 1'b0;
          game_st_ascii = 8'b01101110; // n = 110

          if (WinO) begin
            nx_game_state = `GAME_ST_WIN_O;
          end
          else if (Cats) begin
            nx_game_state = `GAME_ST_CATS;
          end
          else begin
            nx_game_state = `GAME_ST_TURN_X;
          end
        end

        `GAME_ST_WIN_O: begin
          turnX = 1'b0;
          turnO = 1'b0;
          game_st_ascii = 8'b01001111; // O = 79
          nx_game_state = `GAME_ST_WIN_O;
        end

        `GAME_ST_CATS: begin
          turnX = 1'b0;
          turnO = 1'b0;
          game_st_ascii = 8'b01000011; // C = 67
          nx_game_state = `GAME_ST_CATS;
        end
      endcase
    end
  end
endmodule
