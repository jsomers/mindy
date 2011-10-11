class MatchesController < ApplicationController
  protect_from_forgery
  
  before_filter :get_match_id
  
  def play
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
