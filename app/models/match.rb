class Match
  attr_accessor :id,
                :deck,
                :hands,
                :players,
                :trump,
                :finished_tricks,
                :cards_played,
                :current_player,
                :current_trick
  
  def initialize(id)
    @id = id
    @deck = build_and_shuffle_deck
    @hands = {}
    @players = []
    @trump = nil
    @finished_tricks = []
    @cards_played = []
    @current_player = nil
    @current_trick = nil
  end
  
  def add_player(handle)
    if @players.length == 4 then raise "Too many players" end
    @players << handle
    assign_hand_to_player(@players.last)
  end
  
  def choose_trump(card)
    @trump = card.last
    deal_the_rest
  end
  
  def deal_the_rest
    @players.each_with_index do |player, i|
      l = 20 + i * 8
      @hands[player] += @deck[l..(l + 7)]
    end
  end
  
  private
  
  def build_and_shuffle_deck
    suits = ["s", "h", "d", "c"]
    ranks = (2..10).collect(&:to_s).to_a | ["J", "Q", "K", "A"]
    deck = ranks.collect {|r| suits.collect {|s| r + s}}.flatten
    deck.shuffle
  end
  
  def assign_hand_to_player(player)
    n = @players.length - 1
    @hands[player] = @deck[(n * 5)..((n + 1) * 5) - 1]
  end
  
end