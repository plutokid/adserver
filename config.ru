require './adserver.rb'

map '/' do
  run AdServer
end