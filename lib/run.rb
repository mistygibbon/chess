require_relative 'game'
g = Game.new
g.import_fen('8/8/8/4p1K1/2k1P3/8/8/8 b - - 0 1').board.print_board
# g.import_fen('rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2').board.print_board
# g.import_fen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1').board.print_board
# g.board.print_board
# p g.legal_moves([6, 7])
# p g.input_translator('a2')
g.rounds
# g.board.print_board
# p g.hist.data