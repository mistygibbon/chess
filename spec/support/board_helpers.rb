module BoardHelpers
  def setup_chess_board(board)
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
      board.data[row][4] = Piece.new('king', colour, [row, 4])
      board.data[row][3] = Piece.new('queen', colour, [row, 3])
      board.data[row][0] = Piece.new('rook', colour, [row, 0])
      board.data[row][7] = Piece.new('rook', colour, [row, 7])
      board.data[row][2] = Piece.new('bishop', colour, [row, 2])
      board.data[row][5] = Piece.new('bishop', colour, [row, 5])
      board.data[row][1] = Piece.new('knight', colour, [row, 1])
      board.data[row][6] = Piece.new('knight', colour, [row, 6])
      8.times { |inc| board.data[pawn_row][inc] = Piece.new('pawn', colour, [pawn_row, inc]) }
    end
  end
end