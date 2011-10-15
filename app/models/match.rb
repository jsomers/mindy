class Match
  attr_accessor :id,
                :deck,
                :hands,
                :players,
                :pairs,
                :scores,
                :points_earned,
                :trump,
                :finished_tricks,
                :cards_played,
                :current_player,
                :current_trick
  
  @@suits = ["s", "h", "d", "c"]
  @@ranks = (2..10).collect(&:to_s).to_a | ["J", "Q", "K", "A"]
  
  def self.from_hash(hash)
    match = self.new(hash["id"])
    match.deck = hash["deck"]
    match.hands = hash["hands"]
    match.players = hash["players"]
    match.pairs = hash["pairs"]
    match.scores = hash["scores"]
    match.points_earned = hash["points_earned"]
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
    @pairs = {}
    @scores = {}
    @points_earned = 0
    @trump = nil
    @finished_tricks = []
    @cards_played = []
    @current_player = nil
    @current_trick = []
  end
  
  def add_player(handle)
    return if @players.length == 4
    return if @players.include? handle
    @players << handle
    assign_hand_to_player(@players.last)
    @scores[handle] = 0
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
    assign_players_to_pairs
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

  def play_card(card, player)
    return if @cards_played.include? [player, card]
    @cards_played << [player, card]
    @hands[player].delete(card)
    @current_trick << [player, card]
    if @current_trick.length == 5
      last = @current_trick.pop
      @finished_tricks << @current_trick
      update_score
      @current_trick = [last]
    end
    update_current_player
    save!
  end
  
  private
  
  def build_and_shuffle_deck
    deck = @@ranks.collect {|r| @@suits.collect {|s| r + s}}.flatten
    deck.shuffle
  end
  
  def assign_hand_to_player(player)
    n = @players.length - 1
    @hands[player] = @deck[(n * 5)..((n + 1) * 5) - 1]
  end
  
  def assign_players_to_pairs
    t = @players.shuffle
    t.each_with_index do |player, i|
      @pairs[player] = t[(i + 2) % 4]
    end
  end
  
  def update_score
    last_trick = @finished_tricks.last
    winning_play = last_trick.sort { |play_a, play_b|
      card_a, card_b = play_a[1], play_b[1]
      strength(card_a) <=> strength(card_b)
    }.last
    winning_player = winning_play[0]
    pts_to_add = 1 + number_of_tens(last_trick)
    @scores[winning_player] += pts_to_add
    @scores[@pairs[winning_player]] += pts_to_add
    @points_earned += pts_to_add
  end
  
  def strength(card)
    suit, rank = suit_and_rank(card)
    led_suit = suit_and_rank((@finished_tricks.last).first[1])[0]
    if suit == @trump
      score = 100 + rank
    else
      score = (suit == led_suit ? rank : 0)
    end
    return score
  end
  
  def number_of_tens(trick)
    cards = trick.collect {|tr| tr[1]}
    cards.select {|c| c.include? "10"}.length
  end
  
  def suit_and_rank(card)
    pieces = card.split("")
    return [pieces.last, 8] if card.include? "10"
    [pieces.last, @@ranks.index(pieces.first)]
  end
  
  def update_current_player
    @current_player = @players[(@players.index(@current_player) + 1) % @players.length]
  end
  
  def save!
    $redis.set self.id, self.to_json
    self
  end
  
end