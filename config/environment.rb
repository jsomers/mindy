# Load the rails application
require File.expand_path('../application', __FILE__)

$redis = Redis.new

# Initialize the rails application
Mindycoat::Application.initialize!
