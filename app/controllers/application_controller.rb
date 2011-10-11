class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def rget(key)
    JSON.parse($redis.get key)
  end
  
  def rset(key, val)
    $redis.set key, val.to_json
  end
end