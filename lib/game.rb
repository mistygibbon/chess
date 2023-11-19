require_relative 'board'
require_relative 'display'
require_relative 'history'
require_relative 'import'

class Game

  include Display, Import

  attr_accessor :board
  attr_reader :hist, :board_data

  def initialize(board = nil, en_passant_eligible = [], halfmove_clock = 0, fullmove_number = 0)
    new_game = nil
    @board = if board.nil?
               new_game = true
               Board.new
             else
               new_game = false
               board
             end
    @board_data = @board.data
    @hist = History.new([], @board)
    @en_passant_eligible = en_passant_eligible
    @halfmove_clock = halfmove_clock
    @fullmove_number = fullmove_number
    if new_game
      set_pieces
    end
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
    return [] unless input.match(/^[a-hA-H]\d$/)
    data = input.downcase.split('')
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
    [data[1].to_i - 1, conversion_table.fetch(data[0])]
  end

  def initial_position_validator(initial_position, side)
    selected_piece = @board.get_piece(initial_position)
    if selected_piece.nil?
      puts 'There is no piece in this location'
      return false
    end
    unless selected_piece.side == side
      puts 'The chess piece you chose is on the wrong side'
      return false
    end
    true
  end

  def move_piece(side)
    # king_hinted = false
    while true
      # Hint for king under check
      # king = @board.get_all_pieces_with_side(side).filter{|piece|piece.type == 'king'}[0]
      # if is_in_check(king.position,side) && king_hinted == false
      #   puts 'King is under check'
      #   king_hinted = true
      # end

      # Initial position input and validation
      initial_input = gets.chomp
      initial = input_translator(initial_input)
      if initial.empty?
        puts 'Wrong input format, please try again'
        next
      end
      selected_piece = @board.get_piece(initial)
      unless initial_position_validator(initial, side)
        next
      end
      puts "You have chosen a #{selected_piece.side} #{selected_piece.type}"

      # Final position input
      final_input = gets.chomp
      final = input_translator(final_input)

      # Generate legal moves
      legal_moves = legal_moves(initial)
      en_passant_moves = []
      castling_moves = []

      if selected_piece.type == 'pawn'
        en_passant_moves = get_en_passant_moves(initial)
        legal_moves += en_passant_moves
        unless selected_piece.is_moved
          two_square_move = selected_piece.transformation[1]
          two_square_move_result = [initial[0] + two_square_move[0], initial[1] + two_square_move[1]]
        end
      end

      if selected_piece.type == 'king' && selected_piece.is_moved == false
        castling_moves = get_castling_moves(side)
        legal_moves += castling_moves
      end

      if legal_moves.include?(final) && selected_piece.side == side
        is_capture = capture?(initial, final)
        if selected_piece.type == 'pawn' && get_pawn_capture_moves(initial).include?(final) == false && is_capture == true
          puts 'illegal move'
          next
        end
        if selected_piece.type == 'pawn' && final == two_square_move_result && selected_piece.is_moved == false
          @en_passant_eligible << selected_piece
        end
        if en_passant_moves.include?(final)
          piece_to_be_captured = @board.get_piece([initial[0], final[1]])
          if @en_passant_eligible.include?(piece_to_be_captured)
            @board.remove_piece([initial[0], final[1]])
            is_capture = true
          end
        end
        if (castling_moves.empty? == false) && castling_moves.include?(final)
          @board.change_position(initial, final)
          if final[1] < 4 # queenside castling
            @board.change_position([final[0], 0], [final[0], final[1] + 1])
          elsif final[1] > 4 # kingside castling
            @board.change_position([final[0], 7], [final[0], final[1] - 1])
          else
            raise 'Invalid move'
          end
          return
        end

        if is_king_in_check_after_move(initial, final)
          puts 'King under check'
          next
        end

        break
      else
        puts 'illegal move'
      end
    end
    # Write move to board and add to history
    @hist.record_history(initial, final, nil, is_capture)
    @board.change_position(initial, final)
    [initial, final]
  end

  def is_king_in_check_after_move(initial, final)
    false
    temp_board = @board
    @board = Marshal.load(Marshal.dump(@board)) # copy of the board
    @board_data = @board.data
    @board.change_position(initial, final) # load changes
    piece = @board.get_piece(final)
    side = piece.side
    king = @board.get_all_pieces_with_side(side).filter { |piece| piece.type == 'king' }[0]
    result = if is_in_check(king.position, side)
               true
             else
               false
             end
    @board = temp_board
    @board_data = @board.data
    result
  end

  def get_full_legal_moves(position)
    moves = []
    piece = @board.get_piece(position)
    side = piece.side
    moves += legal_moves(position)
    if piece.type == 'pawn'
      moves += get_en_passant_moves(position)
    end
    if piece.type = 'king'
      moves + get_castling_moves(side)
    end
  end

  def rounds
    i = 0
    while true
      Display.clear
      @board.print_board
      side = 'white' if i.even?
      side = 'black' if i.odd?
      puts "#{side.capitalize} player's turn"
      en_passant_clear(side)
      if checkmate_detection(side)
        puts "Checkmate, #{get_opposite_side(side)} wins"
        break
      end
      if stalemate_detection(side)
        puts 'stalemate'
        break
      end
      move = move_piece(side)
      if promotion_detection(side)
        puts 'Your pawn can be promoted. Please choose from queen, rook, bishop or knight'
        input = gets.chomp
        @board.get_piece(move[1]).promote_to(input)
      end
      break if won
      i += 1
      if i % 2 == 0
        @fullmove_number += 1
      end
    end
  end

  def start
    g.rounds
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
      @board_data[row].any? { |piece| piece.is_a?(Piece) ? piece.type == 'pawn' && piece.side == side : false }
    else
      false
    end
  end

  def checkmate_detection(side)
    # threatened with capture and no way to escape
    # king is under check
    # available squares to move are either unavailable or under check by other pieces
    # the piece checking the king cannot be captured
    if side == 'white'
      0
    elsif side == 'black'
      7
    else
      raise 'Invalid side argument'
    end
    king = @board.get_all_pieces_with_side(side).filter { |piece| piece.type == 'king' }[0]
    if is_in_check(king.position, side) == false
      return false
    end
    king_movements = legal_moves(king.position)
    other_pieces = @board.get_all_pieces_with_side(get_opposite_side(side))
    checking_pieces = []
    other_pieces.each do |piece|
      legal_moves = legal_moves(piece.position)
      if legal_moves.include?(king.position)
        checking_pieces << piece
      end
    end
    # are the piece checking the king can be captured immediately?
    if checking_pieces.size == 1 # && is_in_check(checking_pieces[0].position,side)
      checking_piece = checking_pieces[0]
      my_pieces = @board.get_all_pieces_with_side(side)
      my_movable_pieces = []
      my_pieces.each do |piece|
        moves = legal_moves(piece.position)
        if moves.include?(king.position)
          my_movable_pieces << piece
        end
      end
      my_movable_pieces.filter! do |piece|
        if is_king_in_check_after_move(piece.position, checking_piece.position)
          false
        else
          true
        end
      end
      if my_movable_pieces.empty?
        return true
      end
    end
    if king_movements.all? { |move| is_in_check(move, side) } == false
      return false
    end
    true
  end

  def stalemate_detection(side)
    # available squares to move are either unavailable or under check by other pieces
    king = @board.get_all_pieces_with_side(side).filter { |piece| piece.type == 'king' }[0]
    if is_in_check(king.position, side) == true
      return false
    end

    @board.get_all_pieces_with_side(side).each do |piece|
      legal_moves = legal_moves(piece.position)
      legal_moves.each do |move|
        if is_king_in_check_after_move(piece.position, move) == false
          return false # There exist a move such that king remains not checked
        end
      end
    end

    true
  end

  def won
  end

  # def save_game
  #   content = Marshal.dump(self)
  #   puts 'Enter save name'
  #   filename = gets.chomp
  #   File.write(filename,content)
  # end
  #
  # def load_game
  #   puts 'Enter save name'
  #   filename = gets.chomp
  #   content = File.read(filename)
  #   game = Marshal.load(content)
  #   if game.is_a? Game
  #     @board = game.board
  #     @board_data = board.data
  #   end
  # end

  def capture?(initial, final)
    piece = @board_data[initial[0]][initial[1]]
    final_pos = @board_data[final[0]][final[1]]
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
      result += get_pawn_capture_moves(position)
    end

    result += if piece.inc
                valid_moves_inc(piece.side, piece.transformation, position)
              else
                valid_moves_nor(position)
              end
    result
  end

  private

  def en_passant_clear(side)
    @en_passant_eligible.reject! { |piece| piece.side == side }
  end

  def get_en_passant_moves(position)
    result = []
    pawn = @board.get_piece(position)
    row_position = position[0]
    col_position = position[1]
    transformation = pawn.transformation[0]
    row_trans = transformation[0]
    transformation[1]
    [[row_position, col_position + 1], [row_position, col_position - 1]].each do |adjacent_position|
      piece_at_location = @board.get_piece(adjacent_position)
      if piece_at_location.nil?
        next
      elsif piece_at_location.side != pawn.side && piece_at_location.type == 'pawn' && @en_passant_eligible.include?(piece_at_location)
        result << [adjacent_position[0] + row_trans, adjacent_position[1]]
      end
    end
    result
  end

  def get_castling_moves(side)
    # Conditions for castling to happen
    # King cannot castle out of, into or through check
    # No pieces between king and rook
    # Neither king or rook on that side has been moved
    row = nil
    if side == 'white'
      row = 0
    elsif side == 'black'
      row = 7
    else
      raise 'Invalid side argument'
    end
    result = []
    king = @board.get_piece([row, 4])
    queen_rook = @board.get_piece([row, 0])
    king_rook = @board.get_piece([row, 7])
    if is_in_check([row, 4], side) == true
      return result
    end

    if queen_rook.nil? == false && king.nil? == false
      if queen_rook.is_moved == false
        piece1 = @board.get_piece([row, 3])
        piece2 = @board.get_piece([row, 2])
        if piece1.nil? && piece2.nil?
          if is_in_check([row, 3], side) == false && is_in_check([row, 2], side) == false
            result << [row, 2]
          end
        end
      end
    end

    if king_rook.nil? == false && king.nil? == false
      if king.is_moved == false
        piece1 = @board.get_piece([row, 5])
        piece2 = @board.get_piece([row, 6])
        if piece1.nil? && piece2.nil?
          if is_in_check([row, 5], side) == false && is_in_check([row, 6], side) == false
            result << [row, 6]
          end
        end
      end
    end
    result
  end

  def is_in_check(location, side)
    capture_moves = []
    @board.get_all_pieces_with_side(get_opposite_side(side)).each do |piece|
      capture_moves += get_capture_moves(piece.position)
    end
    capture_moves.include?(location)
  end

  def get_capture_moves(position)
    piece = @board.get_piece(position)
    result = []
    if piece.type == 'pawn' # pawn diagonal capture pattern
      result = get_pawn_capture_moves(position)
      return result
    end

    result += if piece.inc
                valid_moves_inc(piece.side, piece.transformation, position)
              else
                valid_moves_nor(position)
              end
    result
  end

  def get_opposite_side(side)
    if side == 'white'
      'black'
    elsif side == 'black'
      'white'
    else
      raise 'Invalid side argument'
    end
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
    [[row_position + row_trans, col_position + col_trans + 1], [row_position + row_trans, col_position + col_trans - 1]].each do |new_location|
      piece_at_location = @board.get_piece(new_location)
      if piece_at_location.nil?
        next
      elsif piece_at_location.side != pawn.side
        result << new_location
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
        if piece.type == 'pawn' && @board_data[pos[0]][pos[1]].nil? == false
          if value[0] == 1 || value[0] == -1
            return []
          elsif value[0] == 2 || value[0] == -2
            result -= pos
            return result
          end
        end
      end
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

