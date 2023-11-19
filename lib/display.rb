require 'io/console'
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

  CHESS_PIECES = {
    'king' => '♚',
    'queen' => '♛',
    'rook' => '♜',
    'bishop' => '♝',
    'knight' => '♞',
    'pawn' => '♟︎'
  }

  TEXT_COLOR_CODE = {
    'black' => "\033[38;5;232m",
    'white' => "\033[38;5;255m"
  }

  BACKGROUND_COLOR_CODE = [
    "\033[48;5;240m", # black
    "\033[48;5;250m", # white
    "\033[0m", # reset
    "\033[1m" # bold
  ]

  def self.print_board(board)
    lambda = lambda { |item| item.side == 'white' ? Display::WHITE_PIECES.fetch(item.type) : Display::BLACK_PIECES.fetch(item.type) }
    board.reverse.each_with_index do |row, index|
      row_index = board.length - 1 - index
      display_row_index = board.length - index
      print "#{display_row_index} "
      row.each_with_index do |piece, col_index|
        index_sum = index + col_index + 1
        piece_display = " "
        text_color = ""
        unless piece.nil?
          piece_display = CHESS_PIECES.fetch(piece.type)
          text_color = TEXT_COLOR_CODE.fetch(piece.side)
        end
        print "#{BACKGROUND_COLOR_CODE[index_sum % 2]} #{text_color}#{piece_display} #{BACKGROUND_COLOR_CODE[2]}"
      end
      # row = [board.length - index] + row.map { |item| item ? lambda.call(item) : '-' }
      # puts row.join(' ')
      puts ''
    end
    puts [' ', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'].join('  ')
  end

  def self.intro()
    puts "Welcome to a game of Chess\n
          White pieces is indicated by                             "

  end

  def self.clear()
    system("clear") || system("cls")
  end

end