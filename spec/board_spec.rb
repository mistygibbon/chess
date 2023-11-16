# frozen_string_literal: true

require_relative '../lib/board'
require './spec/support/board_helpers'

RSpec.configure do |c|
  c.include BoardHelpers
end

describe Board do


  describe '#change_position' do
    context '' do
      it 'changes position as specified' do
        board = Board.new
        setup_chess_board(board)
        board.change_position([1,0],[2,0])
        expect(board.data[1][0]).to(eq(nil))
      end

      it 'changes is_moved to true' do
      end
    end
  end

  describe '#set_transformation' do
    context 'when piece is queen' do
      end
    end
end
