class MatchesController < ApplicationController
  protect_from_forgery
  
  before_filter :get_match_params
  
  def play
  end
  
  def register
    match = rget(@match_id)
    match.add_player(params[:handle])
    publish(@match_id, {
      :type => "registered", :match => match.to_json, :player => params[:handle]
    })
    
    if match.players.length == 4
      publish(@match_id, {
        :type => "start", :match => match.start.to_json
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
    @match_id = (params[:id] ||= "something_else")
    @handle = (session[:handle] ||= "guest_#{rand(1000000000)}")
  end
  
  def publish(channel, content)
    Juggernaut.publish(channel, content.to_json)
  end
end
