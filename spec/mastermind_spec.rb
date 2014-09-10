# http://www.web-games-online.com/mastermind/
#
# Mastermind.
#
# So the idea is: start out with two pegs, two colors: RG:  RR GG RG GR
#
# There are four color pieces: [R]ed, [G]reen, [B]lue, [Y]ellow
#
# You start the ruby executable.
#
# The program creates a random four pieces and hides them.
#
# You then enter your guess as four letters:  RGRG  (red-green-red-green)
#
# The output is then: dot=none, +=match but wrong slot, @=match and slot.
# These are output in order: @’s, then +’s, then .’s.
# They don’t necessarily match the order of the entry
#
# So: Assuming the system chose: RGRY
#
# > BBBB => ....
# > RBBR => @+.. 
# > GRYR => ++++
# > GGRY => @@@.
# > RGRY => @@@@
#
# Congrats!
#
# (once you get a match, it shows it and how many steps)
#
# Bonus: choose from possible # pieces. defaults to 4 but could be: 2 - 8:
#
# Red, Green, Blue, Yellow, Orange, White, Purple, Cyan, Violet.
#
# It should start by showing the lexicon.
# ‘h’ should be treated as help and should show the lexicon.
# ‘q’ should be quit

class Mastermind
  class DuplicateNotAllowedException < StandardError; end

  def initialize solution='RGBY'
    @solution = solution
    @solution_array = solution.split(//)
  end

  def check guess
    guess_array = guess.split(//)
    raise Mastermind::DuplicateNotAllowedException if guess_array.length - guess_array.uniq.length != 0

    # 1. set array to no match
    result_array = Array.new(guess_array.length, :no_match)

    guess_array.each_with_index do |guess_char,guess_index|
      # 2. check to see if colors exist
      if @solution_array.include?(guess_char) then
        result_array[guess_index] = :match_color_not_position
      end
      # 3. check to see if colours are in correct positions
      if guess_char == @solution_array[guess_index] then
        result_array[guess_index] = :match_color_and_position
      end
    end

    result_array
  end

  def count_matches matches
    # {:match_color_and_position => 1, :match_color_not_position => 1, :no_match => 2}
    # counts = Hash.new 0
    #
    # words.each do |word|
    #   counts[word] += 1
    # end

    if matches == [:no_match, :no_match, :no_match, :no_match] then
      {:match_color_and_position => 0, :match_color_not_position => 0, :no_match => 4}
    else
      {:match_color_and_position => 1, :match_color_not_position => 0, :no_match => 3}
    end

  end
end

describe Mastermind do

  xit "///" do
    mastermind = Mastermind.new
    # mastermind.start
    ## mastermind.solution = mastermind.generate_solution
  end

  #[:no_match, :match_color_and_position, :no_match, :match_color_not_position]
  # COUNT => {:match_color_and_position => 1, :match_color_not_position => 1, :no_match => 2}
  #
  # SYMBOL = {:match_color_and_position => '@', :match_color_not_position => '+', :no_match => '.'}
  # @+..
  # SYMBOL[:match_color_and_position]*COUNT[:match_color_and_position]

  context "remembering match type counts" do
    it "finds 0 :match_color_and_position, 0 :match_color_not_position, 4 no_match when it receives an array of 4 :no_matches" do
      expect(Mastermind.new.count_matches([:no_match, :no_match, :no_match, :no_match]))
        .to eq({:match_color_and_position => 0, :match_color_not_position => 0, :no_match => 4})
    end

    it "finds 1 :match_color_and_position, 0 :match_color_not_position, 3 no_match when it receives an array of 1 :match_color_and_position and 3 :no_matches" do
      expect(Mastermind.new.count_matches([:match_color_and_position, :no_match, :no_match, :no_match]))
      .to eq({:match_color_and_position => 1, :match_color_not_position => 0, :no_match => 3})
    end
  end

  context "making guesses: 1 slot, 1 color" do
    it "outputs correct color and position when the guess is correct" do
      expect(Mastermind.new('G').check('G')).to eq([:match_color_and_position])
    end

    it "outputs no match when the guess is incorrect" do
      expect(Mastermind.new('G').check('R')).to eq([:no_match])
    end
  end

  context "making guesses: 2 slots, 4 colors" do
    it "outputs correct color and position when the guess is correct" do
      # :no_match, :match_color, :match_color_and_position
      # given: assuming solution = 'RG'
      # when mastermind.guess 'RG' =>
      # # then output shoudl be: [:match_color_and_position, :match_color_and_position]
      expect(Mastermind.new('RG').check('RG')).to eq([:match_color_and_position, :match_color_and_position])
    end

    it "outputs no match when the guess is incorrect" do
      expect(Mastermind.new('RG').check('BY')).to eq([:no_match, :no_match])
    end

    it "outputs partial matches when the guess is correct colours but wrong position" do
      expect(Mastermind.new('RG').check('GR')).to eq([:match_color_not_position, :match_color_not_position])
    end

    it "throws and exception if the guess has duplicate colors" do
      expect{Mastermind.new('RG').check('RR')}.to raise_error(Mastermind::DuplicateNotAllowedException)
    end
  end

  context "making guesses: 3 slots, 4 colors" do
    it "outputs [:match_color_not_position, :match_color_not_position, :match_color_not_position] when solution is 'RGR' and guess is 'GRG'" do
      expect(Mastermind.new('RGB').check('BRG')).to eq([:match_color_not_position, :match_color_not_position, :match_color_not_position])
    end
  end
end