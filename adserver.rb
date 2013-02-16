require 'rack'
require 'sinatra/base'
require 'sinatra/contrib'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-serializer'
require 'haml'
require './lib/authorization'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/adserver.db")

class Ad
  attr_reader :image

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

  has n, :clicks
  has n, :displays
end


class Click
  include DataMapper::Resource

  property :id,           Serial
  property :ip_address,   String
  property :created_at,   DateTime

  belongs_to :ad
end


class Display
  include DataMapper::Resource

  property :id,           Serial
  property :ip_address,   String
  property :created_at,   DateTime

  belongs_to :ad
end


class AdServer < Sinatra::Base
  use Rack::ETag

  include Sinatra::Authorization
  register Sinatra::RespondWith

  configure :development do
    DataMapper::auto_upgrade!
  end

  enable :sessions
  configure(:development) {
    set :session_secret, "secret"
  }

  enable :method_override
  set :username, 'pooria'
  set :password, '12345'



  
  before do
    @stylesheets = ['main-style.css']
    @scripts = ['jquery-1.9.1.min.js', 'site-main.js', 'spin.min.js']
  end



  get '/' do
    if authorized?
      redirect '/list'
    else
      redirect '/sample-ad'
    end
  end


  get '/login' do
    @stylesheets += ['login.css', 'buttons.css']
    @title = 'Login'
    haml :login
  end

  post '/login' do
    if authorize(params[:username], params[:password])
      redirect unescape(params[:redirect_to]) || '/'
    else
      redirect '/login'
    end
  end


  get '/logout' do
    logout!
    redirect '/'
  end


  get '/ad' do
    random_id = repository(:default).adapter.select(
        'SELECT id FROM ads ORDER BY random() LIMIT 1;'
    )
    @ad = Ad.get(random_id)
    @ad.displays.create(:ip_address => env["REMOTE_ADDR"])
    erb :ad, layout: false
  end


  get '/sample-ad' do
    @title = 'A Sample Ad'
    haml :'sample-ad'
  end


  get '/list' do
    require_authorize!
    @ads = Ad.all(:order => [:created_at.desc])
    respond_with :list do |wants|
      wants.html do
        @title = 'List Ads'
        @stylesheets += ['list-ads.css']
        haml :list
      end
      wants.json do
        @ads.to_json(:only => [:title, :id])
      end
    end
  end


  get '/new' do
    require_authorize!
    @title = "Create A New Ad"
    @stylesheets += ['new-ad.css', 'buttons.css',]
    @scripts += ['new-ad.js']
    haml :new
  end


  post '/new' do
    require_authorize!
    if !params[:image]
      redirect '/new'
    end

    @ad = Ad.new(params[:ad])
    @ad.content_type = params[:image][:type]
    @ad.size = File.size(params[:image][:tempfile])

    if @ad.save
      path = File.join(Dir.pwd, '/public/ads/', @ad.filename)
      File.open(path, 'wb') do |f|
        f.write(params[:image][:tempfile].read)
      end
      redirect "/display/#{@ad.id}"
    else
      redirect '/new'
    end
  end


  delete '/:id' do
    require_authorize!
    ad = Ad.get(params[:id])
    unless ad.nil?
      path = File.join(Dir.pwd, '/public/ads/', ad.filename)
      File.delete(path)
      ad.destroy
    end
    redirect '/list'
  end


  get '/display/:id' do
    require_authorize!
    @ad = Ad.get(params[:id])
    if @ad
      @title = "Display Ad: '#{@ad.title}'"
      @stylesheets += ['display-ad.css']
      haml :display
    else
      redirect '/list'
    end
  end


  get '/click/:id' do
    ad = Ad.get(params[:id])
    ad.clicks.create(:ip_address => env["REMOTE_ADDR"])
    redirect ad.url
  end


end