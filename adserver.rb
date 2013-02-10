require 'sinatra/base'

class AdServer < Sinatra::Base
  get '/' do
    'hello'
  end
end