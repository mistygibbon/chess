require_relative 'board'
require_relative 'game'
require_relative 'piece'

class String
  def is_integer?
    self.to_i.to_s == self
  end

  def is_lower?
    return false if self.size > 1
    ('a'..'z').include? self
  end

  def is_upper?
    return false if self.size > 1
    ('A'..'Z').include? self
  end
end

module Import
  def import_fen(fen)
    fen_arr = fen.split(' ')
    board = import_fen_piece_placement(fen)
    get_fen_active_color(fen)
    set_fen_castling(fen, board)
    en_passant_eligible = get_fen_en_passant(fen)
    halfmove_clock = 0
    fullmove_number = 0
    halfmove_clock = fen_arr[4] if fen_arr[4].is_integer?
    fullmove_number = fen_arr[5] if fen_arr[5].is_integer?
    Game.new(board, en_passant_eligible, halfmove_clock, fullmove_number)
  end

  def get_fen_en_passant(fen)
    fen_arr = fen.split(' ')
    en_passant = fen_arr[3]
    arr = []
    until en_passant.empty?
      arr << fen_input_translator(en_passant.slice!(0..1))
    end
    arr
  end

  def fen_input_translator(input)
    return [] unless input.match(/^[a-h]\d$/)
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

  def get_fen_active_color(fen)
    fen_arr = fen.split(' ')
    active_color = fen_arr[1]
    if active_color == 'b'
      'black'
    elsif active_color == 'w'
      'white'
    end
  end

  def set_fen_castling(fen, board)
    fen_arr = fen.split(' ')
    castling = fen_arr[2]
    castling = castling.split('')
    castling.each do |entry|
      row = nil
      if entry.is_upper?
        row = 0
      end
      if entry.is_lower?
        row = 7
      end
      rooks = board.get_all_pieces.filter { |piece| piece.type == 'rook' }
      rooks.each { |rook| rook.set_is_moved(true) }
      if entry.downcase == 'q'
        board.get_piece([row, 0]).set_is_moved(false)
      elsif entry.downcase == 'k'
        board.get_piece([row, 7]).set_is_moved(false)
      end
    end
  end

  def import_fen_piece_placement(fen)
    fen_arr = fen.split(' ')
    board = Board.new
    piece_placements = fen_arr[0].split('/')
    piece_placements.each_with_index do |row_data, index|
      row_index = board.data.size - 1 - index
      current_col_index = 0
      row_data.split('').each_with_index do |entry, entry_index|
        side = nil
        if entry.is_integer?
          current_col_index += entry.to_i
          next
        end
        side = 'white' if entry.is_upper?
        side = 'black' if entry.is_lower?
        conversion_table = {
          'k' => 'king',
          'q' => 'queen',
          'r' => 'rook',
          'b' => 'bishop',
          'n' => 'knight',
          'p' => 'pawn'
        }
        position = [row_index, current_col_index]
        board.set_piece(position, Piece.new(conversion_table.fetch(entry.downcase), side, position))
        current_col_index += 1
      end
    end
    board
  end

  def export_fen(game)
    unless game.is_a? Game
      raise 'Illegal argument game'
    end
    board = game.board
    export_fen_piece_placement(board)
  end

  def get_alphabet(piece)
    conversion_table = {
      'king'=> 'k',
      'queen'=> 'q',
      'rook'=>'r',
      'bishop'=>'b',
      'knight'=>'n',
      'pawn'=>'p'
    }
    if piece.side=='white'
      conversion_table.fetch(piece.type).upcase
    else
      conversion_table.fetch(piece.type)
    end
  end

  def export_fen_piece_placement(board)
    placement_arr = board.data.reverse.map do |row|
      char_row = row.map{|piece| piece.nil? ? nil:get_alphabet(piece)}
      char_group = char_row.chunk_while{|i,j| i.nil?&&j.nil?}
      char_group = char_group.map do |group|
        if group.uniq.size==1&&group.include?(nil)
          group.size
        else
          group
        end
      end
      char_group.flatten
      char_group.join('')
    end
    placement_arr.join('/')
  end
end
class Wow
  extend Import
end
b = Wow.import_fen_piece_placement('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
p Wow.export_fen_piece_placement(b)
b= Wow.import_fen_piece_placement('rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2')
p Wow.export_fen_piece_placement(b)