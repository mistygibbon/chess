require_relative 'board'
require_relative 'display'
require_relative 'history'

class Game

  attr_accessor :b
  attr_reader :hist, :board

  def initialize
    @b = Board.new
    @board = @b.data
    @hist = History.new([], @b)
    set_pieces
  end

  def set_pieces
    2.times do |i|
      if i == 0
        row = 0
        pawn_row = 1
        colour = 'white'
      else
        row = 7
        pawn_row = 6
        colour = 'black'
      end
      @board[row][4] = Piece.new('king', colour, [row, 4])
      @board[row][3] = Piece.new('queen', colour, [row, 3])
      @board[row][0] = Piece.new('rook', colour, [row, 0])
      @board[row][7] = Piece.new('rook', colour, [row, 7])
      @board[row][2] = Piece.new('bishop', colour, [row, 2])
      @board[row][5] = Piece.new('bishop', colour, [row, 5])
      @board[row][1] = Piece.new('knight', colour, [row, 1])
      @board[row][6] = Piece.new('knight', colour, [row, 6])
      8.times { |inc| @board[pawn_row][inc] = Piece.new('pawn', colour, [pawn_row, inc]) }
    end
  end

  def input_translator(input)
    data = input.split('')
    conversion_table = {
      'a' => 0,
      'b' => 1,
      'c' => 2,
      'd' => 3,
      'e' => 4,
      'f' => 5,
      'g' => 6,
      'h' => 7
    }
    data = [data[1].to_i - 1, conversion_table.fetch(data[0])]
  end

  def move_piece(side)
    while true
      initial_input = gets.chomp
      initial = input_translator(initial_input)
      puts "You have chosen a #{@board[initial[0]][initial[1]].side} #{@board[initial[0]][initial[1]].type}"
      final_input = gets.chomp
      final = input_translator(final_input)
      if @b.legal_moves(initial).include?(final) && @board[initial[0]][initial[1]].side == side
        break
      else
        puts 'illegal move'
      end
    end
    @hist.record_history(initial, final)
    @b.change_position(initial, final)
  end

  def rounds
    i = 0
    while true
      @b.print_board
      side = 'white' if i.even?
      side = 'black' if i.odd?
      move_piece(side)
      break if won
      i += 1
      p hist.data
    end
  end

  def won
  end

end

g = Game.new
g.b.print_board
p g.b.legal_moves([6, 7])
p g.input_translator('a2')
g.rounds
g.b.print_board
p g.hist.data
