require 'sinatra/reloader'

module Mahjong
  # 麻雀牌のクラス
  class Card
    # 字牌のシンボルリストを返す
    JIHAI_LIST = %i[ton nan sha pei haku hatsu chun].freeze
    # 風牌のリストを返す
    KAZE_LIST = %i[ton nan sha pei].freeze
    # 三元牌のリストを返す
    SANGEN_LIST = %i[haku hatsu chun].freeze

    # 数牌のソートのリスト
    SUPAI_LIST = %i[pinz sorz manz].freeze

    # 字牌のソートのリスト
    JIHAI_TYPES = %i[sangen kaze].freeze

    attr_reader :sort, :isnumber, :number, :moji

    # コンストラクタ
    # ==== Args
    # _sort_ :: 萬子・筒子・索子・三元・風(:manz :sorz :pinz :sangen :kaze)のいずれか
    # _number_or_str_ :: 萬子・索子・筒子の場合は1~9, 字牌であれば東南西北白發中
    def initialize(sort, number_or_str)
      @sort = sort
      # エラーチェック
      if SUPAI_LIST.include? @sort
        @isnumber = true
        raise '数字が範囲をオーバーしています' if number_or_str <= 0 || number_or_str > 9
        @number = number_or_str
      elsif JIHAI_TYPES.include? @sort
        @isnumber = false
        raise '字牌がおかしい' unless JIHAI_LIST.include? number_or_str
        @moji = number_or_str
      else
        raise 'ソートが違います'
      end
    end

    # 文字列を返す
    # ==== Examples
    # - '伍筒'
    # - '東東'
    def to_s
      if @isnumber
        s = { pinz: '筒', sorz: '索', manz: '萬' }[@sort]
        n = '一,二,三,四,伍,六,七,八,九'.split(',')[@number - 1]
        n + s
      else
        h = { ton: '東', nan: '南', sha: '西', pei: '北',
              haku: '白', hatsu: '發', chun: '中' }
        s = h[@moji]
        s * 2
      end
    end

    def self.create_supais
      SUPAI_LIST.each do |sort|
        (1..9).each do |n|
          yield Card.new sort, n
        end
      end
    end

    def self.create_jihais
      SANGEN_LIST.each do |moji|
        yield Card.new :sangen, moji
      end
      KAZE_LIST.each do |moji|
        yield Card.new :kaze, moji
      end
    end

    def ==(other)
      (@sort == other.sort && @isnumber == other.isnumber &&
        @number == other.number && @moji == other.moji)
    end

    # 各牌が4枚ずつはいった配列を返す
    # ==== Return
    # Array [Card]
    def self.init_pais
      deck = []
      4.times do
        Card.create_supais do |p|
          deck << p
        end
        Card.create_jihais do |p|
          deck << p
        end
      end
      deck.shuffle
    end

    # 王牌14枚
    # ==== Args
    # _deck_ :: Array [Card]
    def self.create_wanpai(deck)
      deck.pop 14
    end

    # プレイヤーに配牌する
    # ==== Args
    # _deck_ :: Array [Card]
    # _players_ :: Array [Hash], 4人以上
    def self.haipai(deck, players)
      4.times do |i|
        players[i][:hand] = deck.pop 13
      end
      oya = (players.slice(0...4).select { |p| p[:kaze] == :ton }).first
      oya[:hand] << deck.pop # 親は一枚多い
      [deck, players]
    end

    # 対象の家が自分から見てどの位置か
    # ==== Args
    # _player_ :: シンボル
    # _other_ :: シンボル
    def self.relative_position(player, other)
      p other
      p player
      diff = KAZE_LIST.index(other.to_sym) - KAZE_LIST.index(player.to_sym)
      %i[none right forward left][diff % 4]
    end
  end
end
