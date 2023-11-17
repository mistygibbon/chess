require_relative 'piece'
require_relative 'display'

class Board

  include Display

  attr_accessor :data

  def initialize
    # The chess board array uses row 1 as first row, column a as first column, so it is from bottom to up
    @data = Array.new(8) { Array.new(8) }
  end

  def print_board
    Display::print_board(@data)
  end

  def get_piece(location)
    location.each do |coord|
      if coord>=8 || coord < 0
        return nil
      end
    end
    piece = @data[location[0]][location[1]]
    # if piece.nil?
    #   raise 'Piece not found at specified location'
    # end
  end

  def set_piece(location, piece)
    @data[location[0]][location[1]] = piece
  end

  def remove_piece(location)
    @data[location[0]][location[1]] = nil
  end

  def change_position(initial, final)
    piece = @data[initial[0]][initial[1]]
    final_pos = @data[final[0]][final[1]]
    piece.position = [final[0], final[1]]
    if piece.nil?
      raise 'There is no chess piece in initial position for the move'
    end
    if final_pos
      @data[final[0]][final[1]] = piece if final_pos.side != piece.side
    else
      @data[final[0]][final[1]] = piece
    end
    @data[initial[0]][initial[1]] = nil
    piece.change_position(final)
  end

end
