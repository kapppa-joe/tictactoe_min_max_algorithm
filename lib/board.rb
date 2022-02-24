# frozen_string_literal: true

class InvalidInputError < StandardError
  MESSAGE = 'Cannot process that input value'
  def initialize(msg = MESSAGE)
    super
  end
end

class Board
  def initialize(input_string = '000000000')
    if input_string.size != 9 || contain_invalid_char(input_string)
      raise InvalidInputError
    end

    @board = input_string
  end

  def contain_invalid_char(input_string)
    invalid_chars = input_string.chars.difference(%w[0 1 2])
    !invalid_chars.empty?
  end

  def copy
    Board.new(@board)
  end

  def to_s
    @board
  end

  def display_grid
    lines = []
    lines << horizontal_line
    [0, 3, 6].each do |i|
      row = @board[i, 3]
      lines << display_row(row)
    end
    lines << horizontal_line

    lines.join("\n")
  end

  def horizontal_line
    ' -------'
  end

  def display_row(row)
    a, b, c = row.tr('012', '.XO').chars
    "| #{a} #{b} #{c} |"
  end

end