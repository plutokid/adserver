require 'sinatra/base'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'haml'

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
  
  before do
    @stylesheets = ['main-style.css']
    @scripts = []
  end

  get '/' do
    @title = "Welcome to AdServer"
    haml "hello"
  end
  
  get '/ad' do
  end

  get '/list' do
  end

  get '/new' do
    @title = "Create A New Ad"
    @stylesheets += ['new-ad.css', 'buttons.css',]
    @scripts += ['jquery-1.9.1.min.js', 'new-ad.js']
    haml :new
  end

  post '/new' do
    @ad = Ad.new(params[:ad])
    @ad.content_type = params[:image][:type]
    @ad.size = File.size(params[:image][:tempfile])

    if @ad.save
      path = File.join(Dir.pwd, '/public/ads/', @ad.filename)
      File.open(path, 'wb') do |f|
        f.write(params[:image][:tempfile]).read)
      end
      redirect "/show/#{@ad.id}"
    else
      redirect '/list'
    end
  end

  get '/delete/:id' do
  end

  get '/show/:id' do
  end

  get '/click/:id' do
  end

end