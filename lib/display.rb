module Display
  WHITE_PIECES = {
    'king' => '♔',
    'queen' => '♕',
    'rook' => '♖',
    'bishop' => '♗',
    'knight' => '♘',
    'pawn' => '♙'
  }
  BLACK_PIECES = {
    'king' => '♚',
    'queen' => '♛',
    'rook' => '♜',
    'bishop' => '♝',
    'knight' => '♞',
    'pawn' => '♟︎'
  }

  def self.print_board(board)
    lambda = lambda { |item| item.side == 'white' ? Display::WHITE_PIECES.fetch(item.type) : Display::BLACK_PIECES.fetch(item.type) }
    board.reverse.each_with_index do |row, index|
      row = [board.length - index] + row.map { |item| item ? lambda.call(item) : '-' }
      puts row.join(' ')
    end
    puts [' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].join(' ')
  end

  def self.intro()
    puts "Welcome to a game of Chess\n
          White pieces is indicated by                             "

  end

end