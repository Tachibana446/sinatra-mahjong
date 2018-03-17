require_relative '../card.rb'
require 'test/unit'

module Mahjong
  class TestCard < Test::Unit::TestCase
    def test_equal
      a = Card.new :pinz, 3
      b = Card.new :pinz, 3
      c = Card.new :manz, 3
      assert_equal true, a == b
      assert_equal false, a == c
    end

    def test_create_supais
      a = []
      Card.create_supais do |p|
        a << p
      end
      b = Card.new Card::SUPAI_LIST[0], 1
      assert_equal true, a[0] == b
    end

    def test_create_jihais
      a = []
      Card.create_jihais do |p|
        a << p
      end
      b = Card.new :sangen, Card::SANGEN_LIST[0]
      c = Card.new :kaze, Card::KAZE_LIST[0]
      assert_equal true, a[0] == b
      assert_equal true, a[3] == c
    end

    def test_haipai
      players = [
        { kaze: :ton }, { kaze: :nan }, { kaze: :sha }, { kaze: :pei }
      ]
      deck = Card.init_pais
      wanpai = Card.create_wanpai deck
      Card.haipai deck, players

      assert_equal 14, wanpai.length
    end
  end
end
