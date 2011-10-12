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
  
  def self.from_hash(hash)
    match = self.new(hash["id"])
    match.deck = hash["deck"]
    match.hands = hash["hands"]
    match.players = hash["players"]
    match.trump = hash["trump"]
    match.finished_tricks = hash["finished_tricks"]
    match.cards_played = hash["cards_played"]
    match.current_player = hash["current_player"]
    match.current_trick = hash["current_trick"]
    match
  end
  
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
    raise "Too many players" if @players.length == 4
    return if @players.include? handle
    @players << handle
    assign_hand_to_player(@players.last)
    save!
  end
  
  def remove_player(handle)
    @players.delete(handle)
    @hands.delete(handle)
    @current_player = @players.sample if @current_player == handle
    save!
  end
  
  def start
    @current_player = @players.sample
    save!
  end
  
  def choose_trump(card)
    @trump = card.last
    deal_the_rest
    save!
  end
  
  def deal_the_rest
    @players.each_with_index do |player, i|
      l = 20 + i * 8
      @hands[player] += @deck[l..(l + 7)]
    end
    save!
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
  
  def save!
    $redis.set self.id, self.to_json
    self
  end
  
end