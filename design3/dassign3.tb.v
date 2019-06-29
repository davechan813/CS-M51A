//TODO make a test bench that reads a charater and sends a signal
//INPUT: File named "moves.txt" that describes a game
//RESULT: Have the testbench stimulate the module s.t. X places a tile in square 0

`timescale 1ns / 1ps
// Compatibility directive for >0.97a
`default_nettype none

/*
 * define statements for game status ascii output
 */
`define ASCII_X 8'b01011000
`define ASCII_O 8'b01001111
`define ASCII_C 8'b01000011
`define ASCII_E 8'b01000101
`define ASCII_NONE 8'b01101110
/*
 * Result bit patterns
 */
`define RESULT_NONE 4'b0000
`define RESULT_ERR 4'd1000
`define RESULT_CATS 4'b0100
`define RESULT_WINO 4'b0010
`define RESULT_WINX 4'd0001

module game_tb(); // No inputs for a testbench

  integer i,j;
  integer outfile;

  /****************************** Unit Under Test *******************************/
  tictactoe TTT0(turnX, turnO, occ_pos, occ_square, occ_player, game_st, reset,
    clk, flash_clk, sel_pos, buttonX, buttonO);

  /********************* Unit Under Test Outputs **********************/
  wire turnX, turnO;
  wire [8:0] occ_pos, occ_square, occ_player;
  wire [7:0] game_st;
  wire [2:0] result;
  /********************** Unit Under Test Inputs **********************/
  reg reset=1'b0, clk=1'b0, flash_clk=1'b0;
  reg buttonX = 1'b0, buttonO = 1'b0;
  wire [8:0] sel_pos; //one hot
  wire [3:0] game_result;

  /********************** Testbench Declarations **********************/
  /*
    Format in MOVES: (total of 37 bits - set for n lines)
    9-bits for the winning 3 mask
    4-bits for the result
    9-bits for the player map after the move
    9-bits for the resulting board occupied position after the move
    2-bits for buttonX and buttonO
    4-bits for position played (>8 is considered a reset)
  */
  reg [36:0] MOVES [0:12];

  reg [3:0] sel_pos_binary = 4'b0000;
  reg [8:0] chk_occ_square = 9'b0_0000_0000, chk_occ_player= 9'b0_0000_0000;
  reg [3:0] chk_result = 4'b0000;

  // Convert the binary number for position select into oneHot 
  decoder sel_pos_dec(sel_pos, sel_pos_binary);
  // Convert game_status to result vector 
  game_st2res result1(game_result,game_st);

  /*************** Dump vars So we can see the waveform ***************/
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end

  initial begin
    /* initialize inputs and long reset*/
    rst_turn(10);
    /*
      Read input section.
      Read the moves file into the RAM array named "MOVES"
    */
    $readmemb("moves.txt", MOVES);
    /*
     * This game is a normal game of 10 moves with 2 incorrect actions
     */
    for(i=0; i<12; i=i+1) begin
      load_move;
      if (sel_pos_binary == 4'b1111) begin
        rst_turn(1);
      end
      else if (sel_pos_binary == 4'b1110) begin
        // ; //unused
      end
      else if (sel_pos_binary == 4'b1101) begin
        $display ("* Status: wait cycles");
        wait_cycles(4);
      end
      else begin
        if (turnX | turnO) begin
          turn;
        end else begin
          no_turn;
        end
        $display("*\n* New Turn\n*");
      end
    end
    $display("*\n*\n* Status: DONE\n*\n*");
    /* Done */
    $finish;
  end

  task turn;
    begin
      case (MOVES[i][5:4])
         2'b00,2'b01,2'b10: begin
           buttonX = MOVES[i][5]; buttonO = MOVES[i][4];
         end
         2'b11: begin
           buttonX = 1'b0; buttonO=1'b0;
           $display("* Error: Improper input condition!");
         end
      endcase
      $display("* Status: Turn @ line #: %d Reset: %b, Turn X,O: %b%b Button Pushed X,O :%b%b\n*\tMove Pos: \n\t%b\n\t%b\n\t%b",
        i, reset, turnX, turnO, buttonX, buttonO,
        sel_pos[8:6], sel_pos[5:3], sel_pos[2:0]);
      tick;
      buttonX = 1'b0; buttonO=1'b0; reset = 1'b0;
      while (!(turnX || turnO || (| game_result))) begin
        tick;
      end
      disp_gamestate;
      chk_placement;
      chk_game_st;
    end
  endtask

  // Utility task when no turn is detected but should still handle any
  task no_turn;
    begin
      case (MOVES[i][5:4])
         2'b00,2'b01,2'b10: begin
           buttonX = MOVES[i][5]; buttonO = MOVES[i][4];
         end
         2'b11: begin
           buttonX = 1'b0; buttonO=1'b0;
           $display("* Error: Improper input condition!");
         end
      endcase
      $display("* Status: No Turn @ line #: %d Reset: %b, Turn X,O: %b%b Button Pushed X,O :%b%b\n",
        i, reset, turnX, turnO, buttonX, buttonO);
      tick;
      buttonX = 1'b0; buttonO=1'b0; reset = 1'b0;
      disp_gamestate;
      chk_placement;
      chk_game_st;
    end
  endtask

  // Utility task to force a reset for a certain # of cycles (input # cycles)
  task rst_turn;
    input cycles;
    integer cycles;
    begin
      reset = 1'b1;
      wait_cycles(cycles);
      reset = 1'b0;
      tick;
      $display("*\n*\n*\n* Command: RESET GAME\n*\n*\n*\n");
    end
  endtask

  // Utility task to wait a certain number of cycles (input # cycles)
  task wait_cycles;
    input cycles;
    integer cycles;

    begin
      j=cycles;
      while (j>0) begin
        tick;
        j=j-1;
      end
    end
  endtask

  // Utility task to display the game board state
  task disp_gamestate;
    begin
      $display("* Status: Result: %b, GameState:%s",
        game_result, game_st);
      $display("*\tX Pos:\tO Pos:\n\t%b\t%b\n\t%b\t%b\n\t%b\t%b\n",
        (occ_player[8:6] & occ_square[8:6]), (~occ_player[8:6] & occ_square[8:6]),
        (occ_player[5:3] & occ_square[5:3]), (~occ_player[5:3] & occ_square[5:3]),
        (occ_player[2:0] & occ_square[2:0]), (~occ_player[2:0] & occ_square[2:0]));
    end
  endtask

  // Utility task to load a move (not really useful)
  task load_move;
    begin
      sel_pos_binary = MOVES[i][3:0];
      #0 //helps sync multiple procedural blocks evaluating
      ;
    end
  endtask

  // Utility task check if game board has the correct placement compared to moves.txt
  task chk_placement;
    begin
      chk_occ_square = MOVES[i][14:6];
      chk_occ_player = MOVES[i][23:15];
      if ((occ_square == chk_occ_square) && (occ_player == chk_occ_player)) begin
        $display("* Status: correct placement");
      end
      else if (occ_square != chk_occ_square) begin
        $display("* Status: INCORRECT occupied square");
      end
      else if (occ_player != chk_occ_player) begin
        $display("* Status: INCORRECT player position");
      end
    end
  endtask

  // Utility task check if game state matches moves.txt
  task chk_game_st;
    begin
      chk_result = MOVES[i][27:24];
      if (chk_result == game_result) begin
        $display("* Status: correct game status, %s", game_st);
      end
      else begin
        $display("* Status: INCORRECT game status, %s", game_st);
      end
    end
  endtask

  // Utility task to step the clock
  task tick;
    begin
      #10;
      clk = 1;
      #10;
      clk = 0;
    end
  endtask

  // Clock section. Clock toggles every 10 time units */
  always begin
    #10;
    clk = ~clk;
  end

  // Clock section. Flash clock toggles every 50 time units */
  always begin
    #50;
    flash_clk = ~flash_clk;
  end

endmodule

/*
 * Convert game status into a result vector
 */
module game_st2res(game_result, game_st);
  output reg [3:0] game_result = 4'b0000;
  input [7:0] game_st;

  always@(*) begin
    if (game_st == `ASCII_NONE)
      game_result = 4'b0000;
    else if (game_st == `ASCII_X)
      game_result = 4'b0001;
    else if (game_st == `ASCII_O)
      game_result = 4'b0010;
    else if (game_st == `ASCII_C)
      game_result = 4'b0100;
    else if (game_st == `ASCII_E)
      game_result = 4'b1000;
    else
      $display("* Error: No mapping for game result");
  end
endmodule

/*
 * Turn 4 bits of hex into 9 bits of one-hot
 */
module decoder(y, in);
  input [3:0] in;
  output reg [8:0] y;

  always@(*) begin
    case(in)
      4'b0000:y= 9'b000000001;
      4'b0001:y= 9'b000000010;
      4'b0010:y= 9'b000000100;
      4'b0011:y= 9'b000001000;
      4'b0100:y= 9'b000010000;
      4'b0101:y= 9'b000100000;
      4'b0110:y= 9'b001000000;
      4'b0111:y= 9'b010000000;
      4'b1000:y= 9'b100000000;
      default: begin
        y= 9'b000000000;
      end
    endcase
  end
endmodule
