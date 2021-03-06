require 'board'
require 'clever_ai'

describe CleverAI do
  describe '#evaluate_score' do
    it 'returns an integer' do
      board = described_class.new('111000000')
      output = board.evaluate_score(1)
      expect(output).to be_an(Integer)
    end

    context '[someone has won]' do
      it 'returns +1 when given board = "111000000" and player == 1' do
        board = described_class.new('111000000')
        player = 1
        expected_output = 1

        output = board.evaluate_score(player)
        expect(output).to eql expected_output
      end

      it 'returns -1 when given board = "111000000" and player == 2' do
        board = described_class.new('111000000')
        player = 2
        expected_output = -1

        output = board.evaluate_score(player)
        expect(output).to eql(expected_output)
      end

      it 'returns +1 when given board = "222000000" and player == 2' do
        board = described_class.new('222000000')
        player = 2
        expected_output = 1

        output = board.evaluate_score(player)
        expect(output).to eql(expected_output)
      end

      it 'return 1 when given board = "111212221" and player == 1' do
        board = described_class.new('111212221')
        player = 1
        output = board.evaluate_score(player)
        expect(output).to eql(1)
      end

      describe 'return +1 when the return value of #find_winner match player number' do
        board = described_class.new

        [1, 2].each do |player|
          it "for player = #{player}" do
            allow(board).to receive(:find_winner).and_return(player)

            output = board.evaluate_score(player)
            expect(output).to eql(1)
          end
        end
      end

      describe 'return -1 when the return value of #find_winner is the opponent player' do
        board = described_class.new

        [1, 2].each do |player|
          it "for player = #{player}" do
            opponent_player = player == 1 ? 2 : 1
            allow(board).to receive(:find_winner).and_return(opponent_player)

            output = board.evaluate_score(player)
            expect(output).to eql(-1)
          end
        end
      end
    end

    context '[draw game]' do
      describe 'return 0 when given board = "121212212"' do
        board = described_class.new('121212212')
        expected_output = 0

        [1, 2].each do |player|
          it "for player = #{player}" do
            expect(board.evaluate_score(player)).to eql expected_output
          end
        end
      end

      describe 'return 0 when the board is full and #find_winner returns nil' do
        [1, 2].each do |player|
          it "for player = #{player}" do
            board = described_class.new
            allow(board).to receive(:full?).and_return(true)
            allow(board).to receive(:find_winner).and_return(nil)
            expect(board.evaluate_score(player)).to eql 0
          end
        end
      end
    end

    context '[in middle of a game]' do
      context 'with only 1 empty cell,' do
        it 'return +1 if player will win after playing at empty cell' do
          board = described_class.new('121212210')
          player = 1

          expect(board.evaluate_score(player)).to eql 1
        end

        it 'return 0 if it will be a draw game after playing at empty cell' do
          board = described_class.new('121212210')
          player = 2

          expect(board.evaluate_score(player)).to eql 0
        end
      end

      context 'with 2 empty cells,' do
        it 'return +1 if player can win by playing at one of the cells' do
          board = described_class.new('122211010')
          player = 1

          expect(board.evaluate_score(player)).to eql 1
        end

        it 'return -1 if player will always lose by playing at one any of the cells' do
          board = described_class.new('121112020')
          player = 2

          expect(board.evaluate_score(player)).to eql(-1)

          board2 = described_class.new('100122221')
          player = 1
          expect(board2.evaluate_score(player)).to eql(-1)
        end

        it 'return 0 if two available moves scores -1 and 0' do
          board = described_class.new('121221010')
          player = 2

          expect(board.evaluate_score(player)).to eql(0)
        end
      end

      context 'with more than 2 empty cells' do
        context 'when an instant win move is available' do
          test_cases = %w[
            201102120
            100000221
            021012021
            001120100
            012200112
          ]
          test_cases.each do |input_string|
            it "board: #{input_string}" do
              board = described_class.new(input_string)
              player = 1

              expect(board.evaluate_score(player)).to eql 1
            end
          end
        end

        context 'more complex cases' do
          test_cases = {
            '201120120' => -1,
            '121200000' => 1,
            '002210200' => -1,
            '210221010' => -1,
            '210120201' => 0,
            '010221102' => 0,
            '001020020' => 0,
            '020102211' => 0
          }
          test_cases.each do |input_string, expected_output|
            it "board: #{input_string}" do
              board = described_class.new(input_string)
              player = 1

              expect(board.evaluate_score(player)).to eql expected_output
            end
          end
        end
      end
    end

    # === skip the below test in guard spec due to taking too nuch time ===
    it 'an empty board should score as 0', :slow do
      player = 1
      clever_ai = described_class.new('000000000')
      expect(clever_ai.evaluate_score(player)).to eql 0
    end
  end

  describe '#analyse_each_move' do
    context 'when board is full' do
      it 'return an empty hash' do
        board = described_class.new('121212211')
        output = board.analyse_each_move(1)

        expect(output).to eql({})
      end
    end

    context 'when board has only 1 empty cell' do
      test_cases = [
        ['021121212', { 0 => 0 }],
        ['120211212', { 2 => 0 }],
        ['121212210', { 8 => 1 }],
        ['121211022', { 6 => 1 }]
      ]
      test_cases.each do |input_string, expected_output|
        it "return a hash with a cell index and a score of that move, board = #{input_string}" do
          board = described_class.new(input_string)
          player = 1
          actual_output = board.analyse_each_move(player)

          expect(actual_output).to eql expected_output
        end
      end
    end

    context 'when board has 2 or more empty cell' do
      test_cases = [
        ['012022011', { 0 => -1, 3 => -1, 6 => 1 }],
        ['021100221', { 0 => -1, 4 => 1, 5 => 1 }],
        ['210001212', { 2 => -1, 3 => -1, 4 => 1 }],
        ['010200201', { 0 => 1, 2 => -1, 4 => -1, 5 => -1, 7 => -1 }],
        ['122000001', { 3 => 1, 4 => 1, 5 => -1, 6 => 1, 7 => 1 }]
      ]
      test_cases.each do |input_string, expected_output|
        it "return a hash with index of each empty cell and the score of that move, board = #{input_string}" do
          board = described_class.new(input_string)
          player = 1
          actual_output = board.analyse_each_move(player)

          expect(actual_output).to eql expected_output
        end
      end
    end

    context 'when a block is given to this method' do
      describe 'yields once for each empty cell in the board' do
        test_cases = {
          '121212121' => 0,
          '101212121' => 1,
          '121012021' => 2,
          '122000001' => 5
        }
        test_cases.each do |input_string, n|
          it "for #{n} empty cell(s)" do
            expect do |block|
              described_class.new(input_string).analyse_each_move(1, &block)
            end.to yield_control.exactly(n).times
          end
        end
      end

      it 'yields with argument of each cell index and its score' do
        input_string = '122000001'
        board = described_class.new(input_string)
        expected_args = { 3 => 1, 4 => 1, 5 => -1, 6 => 1, 7 => 1 }.to_a
        expect do |block|
          board.analyse_each_move(1, &block)
        end.to yield_successive_args(*expected_args)
      end
    end
  end

  describe '#suggest_next_move' do
    context 'edge cases' do
      it 'returns nil if no empty cell on the board' do
        board = described_class.new('121212121')
        [1, 2].each do |player|
          expect(board.suggest_next_move(player)).to be_nil
        end
      end

      it 'returns a number representing the only one available cell,
        if there is only one empty cell on the board' do
        test_cases = {
          '021212121' => 0,
          '120212121' => 2,
          '121202121' => 4,
          '121212101' => 7,
          '121212110' => 8
        }
        test_cases.each do |input_string, expected_output|
          board = described_class.new(input_string)
          [1, 2].each do |player|
            expect(board.suggest_next_move(player)).to eql expected_output
          end
        end
      end
    end

    context 'two or more possible moves' do
      test_cases_with_quick_wins = {
        '012022011' => 6,
        '012200112' => 4,
        '012210102' => 7,
        '021012021' => 0,
        '121221010' => 8,
        '201102120' => 4,
        '210001212' => 4
      }
      test_cases_with_quick_wins.each do |input_string, expected_output|
        it "can spot a move which immediately leads to winning, board = #{input_string}" do
          clever_ai = described_class.new(input_string)
          actual_output = clever_ai.suggest_next_move(1)
          expect(actual_output).to eql expected_output
        end
      end

      test_cases_with_a_non_obvious_best_move = {
        '121200000' => 4,
        '120020010' => 6,
        '200000000' => 4,
        '000020000' => 0,
        '020002100' => 0
      }
      test_cases_with_a_non_obvious_best_move.each do |input_string, expected_output|
        it "can spot a best move that eventually leads to winning, board = #{input_string}" do
          clever_ai = described_class.new(input_string)
          actual_output = clever_ai.suggest_next_move(1)
          expect(actual_output).to eql expected_output
        end
      end
    end

    it 'returns the 0th cell if board is empty', :slow do
      [1, 2].each do |player|
        clever_ai = described_class.new
        expect(clever_ai.suggest_next_move(player)).to eql 0
      end
    end
  end

  describe '::suggest_next_move' do
    it 'give the same result as the instance method of the same name' do
      10.times do
        input_string = rand(3 ** 9).to_s(3).rjust(9, '0')
        player_number = rand(1..2)
        expected_output = described_class.new(input_string).suggest_next_move(player_number)
        actual_output = described_class.suggest_next_move(input_string, player_number)
        expect(actual_output).to eql expected_output
      end
    end
  end
end
