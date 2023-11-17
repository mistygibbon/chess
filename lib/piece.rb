class Piece
  attr_accessor :type, :side, :position
  attr_reader :is_moved, :inc, :transformation

  def initialize(type, side, position)
    @type = type
    @side = side
    @position = position
    set_transformation(@type)
  end
  def change_position(new_position)
    if self.type == 'pawn' || self.type == 'king' || self.type == 'rook'
      @is_moved = true
      if self.type == 'pawn'
        @transformation = pawn_transformation
      end
    end
    @position = new_position
  end

  def pawn_transformation
    if @is_moved
      return [[1, 0]] if @side == 'white'
      return [[-1, 0]] if @side == 'black'
    else
      return [[1, 0], [2, 0]] if @side == 'white'
      return [[-1, 0], [-2, 0]] if @side == 'black'
    end
  end

  def promote_to(type)
    if @type == 'pawn'
      @type = type
      set_transformation(type)
    end
  end

  def set_transformation(type)
    case type
    when 'knight'
      @transformation = [[1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1], [-2, 1], [-1, 2]]
    when 'pawn'
      @transformation = pawn_transformation
      @is_moved = false
    when 'king'
      @transformation = [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]]
      @is_moved = false
    when 'rook'
      @transformation = [[0, 1], [1, 0], [0, -1], [-1, 0]]
      @is_moved = false
      @inc = true
    when 'queen'
      @transformation = [[1, 1], [1, -1], [-1, -1], [-1, 1], [0, 1], [1, 0], [0, -1], [-1, 0]]
      @inc = true
    when 'bishop'
      @transformation = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
      @inc = true
    else raise 'Invalid piece type'
    end
  end
end
