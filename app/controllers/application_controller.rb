class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def rget(key)
    if (raw = $redis.get(key))
      match = Match.from_hash(JSON.parse(raw))
    else
      match = Match.new(key)
    end
  end
  
  def rset(key, val)
    $redis.set key, val.to_json
  end
end