def capture?(initial, final)
  piece = @data[initial[0]][initial[1]]
  p final_pos = @data[final[0]][final[1]]
  if final_pos.nil? == false
    return true if final_pos.side != piece.side
  else
    return false
  end
end

private

def valid_moves_nor(position)
  result = []
  piece = @data[position[0]][position[1]]
  piece.transformation.each do |value|
    pos = [position[0] + value[0], position[1] + value[1]]
    if pos[0] < 8 && pos[0] >= 0 && pos[1] < 8 && pos[1] >= 0
      if @data[pos[0]][pos[1]].nil? || @data[pos[0]][pos[1]].side != piece.side
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
      pos_side = @data[pos[0]][pos[1]].side unless @data[pos[0]][pos[1]].nil?
      next if pos_side == side
      result << pos
      next if pos_side != side && pos_side
      result += valid_moves_inc(side, value, pos)
    end
  end
  result
end

def legal_moves(position)
  piece = @data[position[0]][position[1]]
  if piece.inc
    result = valid_moves_inc(piece.side, piece.transformation, position)
  else
    result = valid_moves_nor(position)
  end
  result
end
