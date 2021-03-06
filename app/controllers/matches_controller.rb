class MatchesController < ApplicationController
  protect_from_forgery
  
  before_filter :get_match_params, :except => [:create]
  
  def create
    name = params[:name]
    id = id_ify(name)
    match = Match.new(id, name)
    rset(id, match)
    redirect_to "/matches/play/#{id}"
  end
  
  def play
    id = params[:id]
    if !session[:handle] || session[:handle].blank?
      redirect_to "/handle?match_id=#{id}"
    end
    match = rget(@match_id)
    if !match || match.finished?
      match = Match.new(id)
      rset(id, match)
    end
    @title = "Mindy Coat: \"#{match.name}\""
  end
  
  def register
    match = rget(@match_id)
    if !match
      redirect_to "/matches/new"
    end
    match.add_player(params[:handle])
    publish(@match_id, {
      :type => "registered", :match => match.to_json, :player => params[:handle]
    })
    
    if match.players.length == 4 && !match.started?
      match.start
      publish(@match_id, {
        :type => "start", :match => match.to_json
      })
    elsif match.players.length == 4 && !match.paused?
      publish(@match_id, {
        :type => "restart", :match => match.to_json
      })
    end
    
    render :text => "registered"
  end
  
  def message
    publish(@match_id, {
      :type => "message",
      :content => params[:content],
      :sender => params[:handle]
    })
    render :text => "message sent"
  end
  
  def part
    match = rget(@match_id)
    match.remove_player(params[:handle])
    publish(@match_id, {
      :type => "part", :match => match.to_json, :player => params[:handle]
    })
    render :text => "player parted"
  end
  
  def choose_trump
    match = rget(@match_id)
    match.choose_trump(params[:card])
    publish(@match_id, {
      :type => "trump_chosen", :match => match.to_json
    })
    render :text => "trump chosen"
  end
  
  def play_card
    match = rget(@match_id)
    match.play_card(params[:card], params[:handle])
    if match.finished?
      publish(@match_id, {
        :type => "game_over", :match => match.to_json
      })
    else
      publish(@match_id, {
        :type => "card_played", :match => match.to_json
      })
      render :text => "card played"
    end
  end
  
  def game_over
    @match = rget(@match_id)
  end
    
  private
  
  def get_match_params
    @match_id = (params[:id])
    @handle = (session[:handle])
  end
  
  def publish(channel, content)
    Juggernaut.publish(channel, content.to_json)
  end
  
  def id_ify(name)
    name.gsub(/[^\w+]/, "-").gsub("--", "-").chomp("-")
  end
end