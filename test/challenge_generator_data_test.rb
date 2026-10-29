require 'minitest/autorun'
require_relative '../Data/Scripts/018_Alternate battle modes/003_Battle Frontier generator/001_ChallengeGenerator_Data.rb'

class InverseRestrictionTest < Minitest::Test
  class MockRestriction
    def initialize(result)
      @result = result
    end

    def isValid?(pkmn)
      @result
    end
  end

  def test_is_valid_returns_false_when_inner_returns_true
    inner = MockRestriction.new(true)
    restriction = InverseRestriction.new(inner)
    assert_equal false, restriction.isValid?(:dummy_pkmn)
  end

  def test_is_valid_returns_true_when_inner_returns_false
    inner = MockRestriction.new(false)
    restriction = InverseRestriction.new(inner)
    assert_equal true, restriction.isValid?(:dummy_pkmn)
  end
end
