class HandlesController < ApplicationController
  protect_from_forgery
  
  def handle
  end
  
  def set_handle
    session[:handle] = params[:handle].strip
    redirect_to "/matches/play/" + params[:match_id]
  end
  
end
