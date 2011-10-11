class MatchesController < ApplicationController
  protect_from_forgery
  
  before_filter :get_match_id
  
  def play
  end
  
  def register
    unless (match = rget(@match_id))
      match = Match.new(@match_id)
    end
    match.add_player(params[:handle])
    # TODO: on fourth player, fire a "chooseTrump" directive to the current player.
    publish(@match_id, match.to_json)
  end
  
  def message
    publish(@match_id, {
      :type => "message",
      :content => params[:content],
      :sender => "someone"
    })
    render :text => "message sent"
  end
  
  private
  
  def get_match_id
    @match_id = params[:id]
  end
  
  def publish(channel, content)
    Juggernaut.publish(channel, content.to_json)
  end
end
