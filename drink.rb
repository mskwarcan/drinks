require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'config/database'
require 'helpers/sinatra'
require 'lib/authorization'
require 'lib/geokit'
require 'lib/contact'

enable :sessions

helpers do
  include Sinatra::Authorization
end

############################Home Page
get '/' do
  erb :welcome
end
############################End Home Page

############################About Page
get '/about' do
  erb :about
end
############################End About Page

############################FAQs Page
get '/faq' do
  erb :faq
end
############################End FAQs Page

############################Contact Page
get '/contact' do
  @contact_form = ContactForm.new
  erb :contact
end

post '/contact' do
  @contact_form = ContactForm.new(params[:contact])
  if @contact_form.valid?
    #@contact_form.send_email('Drinkr Contact Form')
    @contact_form.clear
    erb :contact
  else
    erb :contact
  end
end
############################End Contact Page

############################Login
post '/login' do
  
  if Person.authenticate(params["email"], params["password"])
      @user = Person.first(:email => params["email"])
      session[:user] = @user.id
      session[:flash] = "Login successful"
      redirect '/bar'
  else
      session[:error] = "Login failed - Try again"
      redirect '/'
  end

end

get '/logout' do
  session[:user] = nil
  redirect '/'
end
############################End Login

############################Search
post '/search' do
  @address = Person.new(params[:bar])
  @latlon = Geokit::Geocoders::YahooGeocoder.geocode "#{@address.address}, #{@address.city} #{@address.state}"
  
  @bars = Bar.all(:address.near => {:origin => @latlon, :distance => 5.mi})
  
  session[:error] = @bars
  
end

############################End Search

############################Register Page
get '/register' do
  erb :register
end

post '/register' do
  @user = Person.new(params[:person])
  
  if @user.save
      flash("Thank you for registering. Login to create you first bar.")
      redirect '/'
  else
    tmp = []
    @user.errors.each do |e|
      tmp << "#{e}. <br/>"
    end
    session[:error] = tmp
    redirect '/register'
  end
end
############################End Register Page

############################Main Page
get '/bar' do
  if !logged_in?
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
  
  @bars = Bar.all(:order => [:name.asc], :person_id => session[:user])
  erb :bar
end
############################Main Page

############################list of all bars
get '/list' do
  @specials = Special.all()
  @bars = Bar.all(:order => [:created_at.desc])
  erb :list
end

############################New bar
get '/new' do
  if !logged_in?
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
  erb :newBar
end

post '/create' do
  if !logged_in?
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
  
  @bar = Bar.new(params[:bar])
  if @bar.save
    redirect "/show/#{@bar.id}"
  else
    tmp = []
    @bar.errors.each do |e|
      tmp << "#{e}. <br/>"
    end
    session[:error] = tmp
    redirect('/new')
  end
end
############################End New Bar

############################Bar Details
get '/details/:id' do
  @bar = Bar.get(params[:id])
  @img = true
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
       @days = Day.all(:bar_id => :id)
       erb :details
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

post '/addDetails/:id' do 
  @bar = Bar.get(params[:id])
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
      params[:days].each do |day|
        Day.new(day).save
      end

      params[:event].each do |events|
        BarEvent.new(events).save
      end
      redirect "/show/#{@bar.id}"
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end
############################End Bar Details

############################New Event
get '/event' do
  #require_admin
  erb :event
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
############################End New Event

############################Drink Specials
get '/special/:id' do
  @bar = Bar.get(params[:id])
  @img = true
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
      @bar = Bar.get(params[:id])
      erb :special
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

post '/addSpecial/:id' do
  @bar = Bar.get(params[:id])
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
      params[:special].each do |specials|
        Special.new(specials).save
      end
      redirect '/bar'
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end
############################END Drink Specials

############################Account
get '/account/:id' do
  if logged_in?
    @user = Person.get(params[:id])
    erb :account
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

get '/editAccount/:id' do
  if logged_in?
    @user = Person.get(params[:id])
    erb :editAccount
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

post '/editAccount/:id' do
  @user = Person.get(params[:id])

  if logged_in?
    if (@user.id == session[:user])
      @update = Person.new(params[:person])
      if Person.get(params[:id]).update(@update.attributes)
        redirect "/account/#{@user.id}"
      else
        tmp = []
        @update.errors.each do |e|
          tmp << "#{e}. <br/>"
        end
        session[:error] = tmp
        redirect("/editAccount/#{@user.id}")
      end
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

############################END Account

############################Bar Actions
get '/delete/:id' do
  @bar = Bar.get(params[:id])
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
      bar = Bar.get(params[:id])
      unless bar.nil?
        bar.destroy
      end
      redirect('/bar')
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

get '/show/:id' do
  @bar = Bar.get(params[:id])
  @days = Day.all(:bar_id => @bar.id)
  @specials = Special.all(:bar_id => @bar.id)
  
  if @bar
    erb :show
  else
    redirect('/list')
  end
end

get '/edit/:id' do
  @bar = Bar.get(params[:id])
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
      erb :edit
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

put '/update/:id' do
  @bar = Bar.get(params[:id])
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
      @update = Bar.new(params[:bar])
      Bar.get(params[:id]).update(@update.attributes)
      redirect "/show/#{@bar.id}"
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end
############################End CRUD Commands

############################Clicks
get '/click/:id' do
  bar = Bar.get(params[:id])
  bar.clicks.create(:ip_address => env["REMOTE_ADDR"])
  redirect "/show/#{bar.id}"
end
############################End Clicks