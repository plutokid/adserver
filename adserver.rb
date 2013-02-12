require 'sinatra/base'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'haml'

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
end


class Click
  include DataMapper::Resource

  property :id,           Serial
  property :ip_address,   String
  property :created_at,   DateTime

  belongs_to :ad
end


class AdServer < Sinatra::Base

  DataMapper::auto_upgrade! 
  
  before do
    @stylesheets = ['main-style.css']
    @ads = Ad.all(:order => [:created_at.desc])
    @scripts = []
  end


  get '/' do
    redirect '/list'
  end


  get '/ad' do
    random_id = repository(:default).adapter.select(
        'SELECT id FROM ads ORDER BY random() LIMIT 1;'
    )
    @ad = Ad.get(random_id)
    erb :ad, layout: false
  end


  get '/sample-ad' do
    @title = 'A Sample Ad'
    haml :'sample-ad'
  end


  get '/list' do
    @title = 'List Ads'
    @ads = Ad.all(:order => [:created_at.desc])
    @stylesheets += ['list-ads.css']
    haml :list
  end

  get '/new' do
    @title = "Create A New Ad"
    @stylesheets += ['new-ad.css', 'buttons.css',]
    @scripts += ['jquery-1.9.1.min.js', 'new-ad.js']
    haml :new
  end


  post '/new' do
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


  get '/delete/:id' do
    ad = Ad.get(params[:id])
    unless ad.nil?
      path = File.join(Dir.pwd, '/public/ads/', ad.filename)
      File.delete(path)
      ad.destroy
    end
    redirect '/list'
  end


  get '/display/:id' do
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