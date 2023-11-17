require_relative 'board'
require_relative 'display'
require_relative 'history'

class Game

  attr_accessor :board
  attr_reader :hist, :board_data

  def initialize
    @board = Board.new
    @board_data = @board.data
    @hist = History.new([], @board)
    @en_passant_eligible = []
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
      @board_data[row][4] = Piece.new('king', colour, [row, 4])
      @board_data[row][3] = Piece.new('queen', colour, [row, 3])
      @board_data[row][0] = Piece.new('rook', colour, [row, 0])
      @board_data[row][7] = Piece.new('rook', colour, [row, 7])
      @board_data[row][2] = Piece.new('bishop', colour, [row, 2])
      @board_data[row][5] = Piece.new('bishop', colour, [row, 5])
      @board_data[row][1] = Piece.new('knight', colour, [row, 1])
      @board_data[row][6] = Piece.new('knight', colour, [row, 6])
      8.times { |inc| @board_data[pawn_row][inc] = Piece.new('pawn', colour, [pawn_row, inc]) }
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
      selected_piece = @board.get_piece(initial)
      if selected_piece.nil?
        puts 'There is no piece in this location'
        next
      end
      unless selected_piece.side == side
        puts 'The chess piece you chose is on the wrong side'
        next
      end
      puts "You have chosen a #{selected_piece.side} #{selected_piece.type}"

      final_input = gets.chomp
      final = input_translator(final_input)
      legal_moves = legal_moves(initial)
      en_passant_moves = []
      if selected_piece.type == 'pawn'
        en_passant_moves = get_en_passant_moves(initial)
        legal_moves = legal_moves + en_passant_moves
        unless selected_piece.is_moved
          two_square_move = selected_piece.transformation[1]
          two_square_move_result = [initial[0]+two_square_move[0],initial[1]+two_square_move[1]]
        end
      end
      if selected_piece.type == 'king'
        legal_moves = legal_moves + castling_moves()
      end

      if legal_moves.include?(final) && selected_piece.side == side
        if selected_piece.type == 'pawn' && final == two_square_move_result && selected_piece.is_moved==false
          @en_passant_eligible << selected_piece
        end
        if en_passant_moves.include?(final)
          piece_to_be_captured = @board.get_piece([initial[0],final[1]])
          if @en_passant_eligible.include?(piece_to_be_captured)
            @board.remove_piece([initial[0],final[1]])
          end
        end
        break
      else
        puts 'illegal move'
      end
    end
    @hist.record_history(initial, final, nil, capture?(initial,final))
    @board.change_position(initial, final)
    [initial, final]
  end

  def rounds
    i = 0
    while true
      @board.print_board
      side = 'white' if i.even?
      side = 'black' if i.odd?
      en_passant_clear(side)
      move = move_piece(side)
      if promotion_detection(side)
        puts 'promotion detected'
      end
      break if won
      i += 1
      p hist.data
    end
  end

  def promotion_detection(side)
    row = nil
    if side == 'white'
      row = 7
    end
    if side == 'black'
      row = 0
    end
    if row == 7 || row == 0
     @board_data[row].any?{|piece| piece.is_a?(Piece) ? piece.type=='pawn'&&piece.side==side:false}
    else
      false
    end
  end

  def won
  end

  def capture?(initial, final)
    piece = @board_data[initial[0]][initial[1]]
    p final_pos = @board_data[final[0]][final[1]]
    if final_pos.nil? == false
      return true if final_pos.side != piece.side
    else
      return false
    end
  end

  def legal_moves(position)
    piece = @board_data[position[0]][position[1]]
    result = []
    if piece.type == 'pawn' # pawn diagonal capture pattern
      result = result + get_pawn_capture_moves(position)
    end

    if piece.inc
      result = result + valid_moves_inc(piece.side, piece.transformation, position)
    else
      result = result + valid_moves_nor(position)
    end
    result
  end

  private

  def en_passant_clear(side)
    @en_passant_eligible.reject!{|piece| piece.side == side}
  end

  def get_en_passant_moves(position)
    result = []
    pawn = @board.get_piece(position)
    row_position = position[0]
    col_position = position[1]
    transformation = pawn.transformation[0]
    row_trans = transformation[0]
    col_trans = transformation[1]
    [[row_position, col_position+ 1],[row_position, col_position - 1]].each do |adjacent_position|
      piece_at_location = @board.get_piece(adjacent_position)
      if piece_at_location.nil?
        next
      elsif piece_at_location.side != pawn.side && piece_at_location.type == 'pawn' && @en_passant_eligible.include?(piece_at_location)
        result << [adjacent_position[0]+row_trans,adjacent_position[1]]
      end
    end
    result
  end

  def get_pawn_capture_moves(position)
    result = []
    pawn = @board.get_piece(position)
    transformation = pawn.transformation[0]
    row_position = position[0]
    col_position = position[1]
    row_trans = transformation[0]
    col_trans = transformation[1]

    # diagonal capture pattern
    [[row_position+row_trans, col_position+col_trans + 1],[row_position+row_trans, col_position+col_trans - 1]].each do |new_location|
      piece_at_location = @board.get_piece(new_location)
      if piece_at_location.nil?
        next
      elsif piece_at_location.side != pawn.side
        result<<new_location
      end
    end
    result
    # piece1 = @board.get_piece([transformation[0], transformation[1] + 1])
    # if piece1.side != piece.side
    #   result << [[transformation[0], transformation[1] + 1]]
    # end
    # piece2 = @board.get_piece([transformation[0], transformation[1] - 1])
    # if piece2.side != piece.side
    #   result << [[transformation[0], transformation[1] - 1]]
    # end
  end

  def valid_moves_nor(position)
    result = []
    piece = @board_data[position[0]][position[1]]
    piece.transformation.each do |value|
      pos = [position[0] + value[0], position[1] + value[1]]
      if pos[0] < 8 && pos[0] >= 0 && pos[1] < 8 && pos[1] >= 0
        if @board_data[pos[0]][pos[1]].nil? || @board_data[pos[0]][pos[1]].side != piece.side
          result << pos
        end
      end
    end
    if piece.type == 'pawn'
      transformation = piece.transformation[0]
      transformation1 = [transformation[0], transformation[1] + 1]
      transformation2 = [transformation[0], transformation[1] - 1]

    end
    result
  end

  def valid_moves_inc(side, transformation, position, result = [])
    transformation = [transformation] unless transformation[0].is_a? Array
    transformation.each do |value|
      pos = [position[0] + value[0], position[1] + value[1]]
      if pos[0] < 8 && pos[0] >= 0 && pos[1] < 8 && pos[1] >= 0
        pos_side = @board_data[pos[0]][pos[1]].side unless @board_data[pos[0]][pos[1]].nil?
        next if pos_side == side
        result << pos
        next if pos_side != side && pos_side
        result += valid_moves_inc(side, value, pos)
      end
    end
    result
  end
end

g = Game.new
g.board.print_board
p g.legal_moves([6, 7])
p g.input_translator('a2')
g.rounds
g.board.print_board
p g.hist.data
