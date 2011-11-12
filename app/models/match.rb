class Match
  attr_accessor :id,
                :name,
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
                :current_trick,
                :started_at,
                :finished_at,
                :paused
  
  @@suits = ["s", "h", "d", "c"]
  @@ranks = (2..10).collect(&:to_s).to_a | ["J", "Q", "K", "A"]
  
  def self.from_hash(hash)
    match = self.new(hash["id"])
    match.name = hash["name"]
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
    match.started_at = hash["started_at"]
    match.finished_at = hash["finished_at"]
    match.paused = hash["paused"]
    match
  end
  
  def initialize(id, name=nil)
    @id = id
    @name = name || id
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
    @started_at = nil
    @finished_at = nil
    @paused = false
  end
  
  def add_player(handle)
    return if @players.include? handle
    if !self.started?
      @players << handle
      assign_hand_to_player(@players.last)
      @scores[handle] = 0
    else
      empty_id = @players.find {|pl| pl.include? "[empty][#{handle}]"} || @players.find {|pl| pl.include? "[empty]"}
      raise "No empty seat to re-fill?" if empty_id.nil?
      @players[@players.index(empty_id)] = handle
      @scores[handle] = @scores[empty_id]
      @scores.delete(empty_id)
      @hands[handle] = @hands[empty_id]
      @hands.delete(empty_id)
      if @current_player == empty_id
        @current_player = handle
      end
      @pairs[handle] = @pairs[empty_id]
      @pairs[@pairs[empty_id]] = handle
      @pairs.delete(empty_id)
      if !@players.find {|pl| pl.include? "[empty]"} && @players.length == 4
        @paused = false
      end
    end
    save!
  end
  
  def remove_player(handle)
    if !self.started?
      @players.delete(handle)
      @hands.delete(handle)
      @scores.delete(handle)
      @current_player = @players.sample if @current_player == handle
    else
      empty_their_seat(handle)
    end
    save!
  end
  
  def start
    @current_player = @players.sample
    assign_players_to_pairs
    @started_at = DateTime.now
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
    update_current_player
    if @current_trick.length == 4
      finish_trick!
      finish_the_match! if @finished_tricks.length == 13
    end
    save!
  end
  
  def finish_trick!
    @finished_tricks << @current_trick
    @current_player = update_score_and_return_winning_player
    @current_trick = []
  end
  
  def finish_the_match!
    @finished_at = DateTime.now
    histories = JSON.parse( $redis.get("histories") )
    histories.push(@finished_tricks)
    $redis.set("histories", histories.to_json)
  end
  
  def started?
    @started_at.present?
  end
  
  def finished?
    @finished_at.present?
  end
  
  def paused?
    @paused
  end
  
  def in_progress?
    started? && !finished?
  end
  
  def save!
    $redis.set self.id, self.to_json
    self
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
    @players.each_with_index do |player, i|
      @pairs[player] = @players[(i + 2) % 4]
    end
  end
  
  def update_score_and_return_winning_player
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
    winning_player
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
  
  def empty_their_seat(handle)
    id = handle
    @players[@players.index(handle)] = "[empty][#{id}]"
    @scores["[empty][#{id}]"] = @scores[handle]
    @scores.delete(handle)
    @hands["[empty][#{id}]"] = @hands[handle]
    @hands.delete(handle)
    if @current_player == handle
      @current_player = "[empty][#{id}]"
    end
    @pairs["[empty][#{id}]"] = @pairs[handle]
    @pairs[@pairs[handle]] = "[empty][#{id}]"
    @pairs.delete(handle)
    @paused = true
  end

end