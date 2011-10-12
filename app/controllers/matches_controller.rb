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
  
  private
  
  def get_match_params
    @match_id = params[:id]
    @handle = (session[:handle] ||= "guest_#{rand(10000)}")
  end
  
  def publish(channel, content)
    Juggernaut.publish(channel, content.to_json)
  end
end
