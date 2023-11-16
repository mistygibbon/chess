class History

  attr_reader :data

  conversion_table = { 1 => 'a', 2 => 'b', 3 => 'c', 4 => 'd', 5 => 'e', 6 => 'f', 7 => 'g', 8 => 'h' }


  def initialize(data = [], board)
    @data = data
    @board = board
    @raw_data = []
  end

  def record_history(initial, final, type = nil, capture = nil)
    capture = @board.capture?(initial, final) if capture.nil?
    type = @board.data[initial[0]][initial[1]].type if type.nil?
    initial = initial.reverse
    final = final.reverse
    p pending = type + initial.join + (capture ? 'x' : '') + final.join
    data << pending
    @raw_data << [initial,final,capture]
  end

end