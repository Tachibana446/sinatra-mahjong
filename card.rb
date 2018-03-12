module Mahjong
  # 麻雀牌のクラス
  class Card
    # コンストラクタ
    # ==== Args
    # _sort_ :: 萬子・筒子・索子・三元・風(:manz :sorz :pinz :sangen :kaze)のいずれか
    # _number_or_str_ :: 萬子・索子・筒子の場合は1~9, 字牌であれば東南西北白發中
    def initialize(sort, number_or_str)
      @sort = sort
      # エラーチェック
      if supai_list.include? @sort
        @isnumber = true
        raise '数字が範囲をオーバーしています' if number_or_str <= 0 || number > 9
        @number = number_or_str
      elsif jihai_sort_list.include? @sort
        @isnumber = false
        raise '字牌がおかしい' unless jihai_list.include? number_or_str
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

    # 字牌のシンボルリストを返す
    # ==== Return
    # :ton :nan :sha :pei :haku :hatsu :chun
    def self.jihai_list
      %i[ton nan sha pei haku hatsu chun]
    end

    # 風牌のリストを返す
    def self.kaze_list
      %i[ton nan sha pei]
    end

    # 三元牌のリストを返す
    def self.sangen_list
      %i[haku hatsu chun]
    end

    # 数牌のソートのリスト
    # ==== Return
    # :pinz :sorz :manz
    def self.supai_list
      %i[pinz sorz manz]
    end

    # 字牌のソートのリスト
    # ==== Return
    # :sangen :kaze
    def self.jihai_sort_list
      %i[sangen kaze]
    end

    def self.create_supais
      supai_list.each do |sort|
        1..9.each do |n|
          yield Card.new sort, n
        end
      end
    end

    def self.create_jihais
      sangen_list.each do |moji|
        yield Card.new :sangen, moji
      end
      kaze.each do |moji|
        yield Card.new :kaze, moji
      end
    end
  end
end
