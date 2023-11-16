require_relative '../lib/piece'

describe Piece do
  describe '#initialize' do
  end

  describe '#change_position' do
    context 'when piece is pawn' do
      subject(:pawn){described_class.new('pawn', 'white', [0,1])}

      it 'changes position as specified' do
        pawn.change_position([0,2])
        expect(pawn.position).to eq([0,2])
      end

      it 'changes is_moved to true' do
        pawn.change_position([0,2])
        expect(pawn.is_moved).to be true
      end
    end
  end

  describe '#set_transformation' do
    context 'when piece is queen' do
      subject(:queen){described_class.new('queen','white',[5,5])}
      it 'returns correct transformation array' do
        result = [[1,1],[1,-1],[-1,-1],[-1,1],[0,1],[1,0],[0,-1],[-1,0]]
        expect(queen.transformation).to eq(result)
      end
    end
  end
end
