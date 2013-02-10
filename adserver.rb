require 'sinatra/base'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/adserver.db")

class Ad

  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  property :content,      Text
  property :width,        Integer
  property :height,       Integer
  property :filename,     String
  property :url,          String
  property :is_active,    Boolean
  property :created_at,   DateTime
  property :updated_at,   DateTime
  property :size,         Integer
  property :content_type, String

end

class AdServer < Sinatra::Base

  DataMapper::auto_upgrade! 

  get '/' do
    haml "hello"
  end
  
  get '/ad' do
  end

  get '/list' do
  end

  get '/new' do
  end

  post '/create' do
  end

  get '/delete/:id' do
  end

  get '/show/:id' do
  end

  get '/click/:id' do
  end

end