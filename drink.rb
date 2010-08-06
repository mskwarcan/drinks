require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'lib/authorization'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/bars.db")

class Bar
  
  include DataMapper::Resource
  
  property :id,         Serial
  property :name,       String
  property :address,    String
  property :city,       String
  property :state,      String
  property :zip,        String
  property :phone,      String
  property :email,      String
  property :url,        String
  property :password,   String
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :clicks
  has n, :details

end

class Event
  include DataMapper::Resource
  
  property :id,          Serial
  property :title,       String
  
end

class Detail
  include DataMapper::Resource
  
  property :id,          Serial
  property :day_of_week, String
  property :hours,       String
  property :cover,       String
  property :dance_floor,Boolean
  
  has n, :specials
  belongs_to :bar
  
end

class Special
  include DataMapper::Resource
  
  property :id,          Serial
  property :drink_name,  String
  property :price,       Decimal
  property :day_of_week, String
  
  belongs_to :detail
  
end

class Click
  include DataMapper::Resource
  
  property :id,         Serial
  property :ip_address, String
  property :created_at, DateTime
  
  belongs_to :bar
  
end

#Create or upgrade all tables
DataMapper.auto_upgrade!

helpers do
  include Sinatra::Authorization
end

get '/' do
  @title = "Welcome to Drinks"
  erb :welcome
end

get '/bar' do
  @bars = Bar.all(:order => [:name.asc])
end

get '/list' do
  @title = ' Search Bars'
  @bars = Bar.all(:order => [:created_at.desc])
  erb :list
end

get '/new' do
  #require_admin
  @title = "Share you bar with the world."
  erb :newBar
end

get '/event' do
  #require_admin
  erb :event
end

get '/details/:id' do
  #require_admin
  @title = "Share you bar with the world."
  erb :details
end

post '/create' do
  #require_admin
  @bar = Bar.new(params[:bar])
  if @bar.save
    redirect "/show/#{@bar.id}"
  else
    redirect('/new')
  end
end

post '/newEvent' do
  #require_admin
  @event = Event.new(params[:event])
  if @event.save
    redirect "/list"
  else
    redirect('/event')
  end
end

get '/delete/:id' do
  #require_admin
  bar = Bar.get(params[:id])
  unless bar.nil?
    bar.destroy
  end
  redirect('/list')
end

get '/show/:id' do
  #require_admin
  @bar = Bar.get(params[:id])
  if @bar
    erb :show
  else
    redirect('/list')
  end
end

get '/edit/:id' do
  #require_admin
  @bar = Bar.get(params[:id])
  if @bar
    erb :edit
  else
    redirect('/list')
  end
end

put '/update/:id' do
  @bar = Bar.new(params[:bar])
  Bar.get(params[:id]).update(@bar.attributes)
  redirect "/show/#{@bar2.id}"
end

get '/click/:id' do
  bar = Bar.get(params[:id])
  bar.clicks.create(:ip_address => env["REMOTE_ADDR"])
  redirect "/show/#{bar.id}"
end
