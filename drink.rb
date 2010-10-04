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
  @bars = Bar.all(:order => [ :created_at.desc ], :limit => 5)
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
  @img = true

  address = Bar.new(params[:bar])
  newAddress = Geokit::Geocoders::YahooGeocoder.geocode "#{address.address}, #{address.city} #{address.state}, #{address.zip}"
  bars = Bar.all()
  
  @bars = []
  
  bars.each do |bar|
    barAddress = Geokit::Geocoders::YahooGeocoder.geocode "#{bar.address}, #{bar.city} #{bar.state}, #{bar.zip}"
    dis = newAddress.distance_to(barAddress)
    if dis <= 10
      @bars << {:bar => Bar.first(:id => bar.id), :distance => dis}
    end
  end
  
  @bars.sort! { |a,b| a[:distance] <=> b[:distance] }
  
  t = Time.now 
  t = t - + (60 * 60 * 5)
  @today = t.strftime("%A")
  
  todays_specials = []
  specials = Special.all(:day_of_week => @today, :order => [ :price.asc ])
  
  specials.each do |special|
    @bars.each do |bar|
      if bar[:bar].id == special.bar_id
        todays_specials << Special.first(:id => special.id)
      end
    end
  end
  
  @beer = []
  @pitcher = []
  @mixed = []
  @shot = []
  @wine = []
  
  todays_specials.each do |special|
    if special.type == 'Beer'
      @beer << Special.first(:id => special.id)
    end
    if special.type == 'Pitcher'
      @pitcher << Special.first(:id => special.id)
    end
    if special.type == 'Mixed'
      @mixed << Special.first(:id => special.id)
    end
    if special.type == 'Shot'
      @shot << Special.first(:id => special.id)
    end
    if special.type == 'Wine'
      @wine << Special.first(:id => special.id)
    end
  end
  
  erb :list
  
end

############################End Search

############################Register Page
get '/register' do
  @user = Person.new()
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
    erb :register
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
  @bar = Bar.new()
  @new = true
  
  if !logged_in?
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
  erb :newBar
end

post '/new' do
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
    erb :newBar
  end
end
############################End New Bar

############################Bar Details
get '/details/:id' do
  @day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  @bar = Bar.get(params[:id])
  @img = true
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
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
        weekday = Day.new(day)
        thisday = Day.first(:bar_id => @bar.id, :day_of_week => weekday.day_of_week)
        if thisday
            thisday.update(weekday.attributes)
            session[:flash] = 'Hours Updated'
        else
          if weekday.save
            session[:flash] = 'Hours Updated'
          else
            tmp = []
            weekday.errors.each do |e|
              tmp << "#{e}. <br/>"
            end
            session[:error] = tmp
            redirect("/details/#{@bar.id}")
          end
        end
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

############################ Bar Events
get '/events/:id' do
  @day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  @bar = Bar.get(params[:id])
  @img = true
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
       erb :events
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

post '/events/:id' do 
  @bar = Bar.get(params[:id])
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
      
      params[:event].each do |events|
        if !events.empty?
          evt = BarEvent.new(events)
          if BarEvent.first(:bar_id => @bar.id, :title => evt.title).update(evt.attributes)
              session[:flash] = 'Details Updated'
          else
            if evt.save
              redirect "/show/#{@bar.id}"
            else
              tmp = []
              evt.errors.each do |e|
                tmp << "#{e}. <br/>"
              end
              session[:error] = tmp
              redirect("/events/#{@bar.id}")
            end
          end
        end
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

############################End Bar Events

############################ Event
get '/event' do
  #require_admin
  erb :event
end

post '/newEvent' do
  #require_admin
  @event = Event.new(params[:event])
  if @event.save
    redirect "/event"
  else
    redirect('/event')
  end
end

get '/deleteEvent/:id' do
  event = Event.get(params[:id])
    unless event.nil?
      event.destroy
    end
    redirect('/event')
end
############################End  Event

############################Drink Specials
get '/special/:id' do
  @day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  @bar = Bar.get(params[:id])
  @img = true
  
  if logged_in?
    if Bar.authenticate(@bar.id, session[:user])
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
      redirect "/special/#{@bar.id}"
    else
      session[:error] = "You don't not have permission to view this page."
      redirect "/bar"
    end
  else
    session[:error] = "You must log in to view this page."
    redirect "/"
  end
end

get '/deleteSpecial/:id' do
  special = Special.get(params[:id])
  
  if logged_in?
     if Bar.authenticate(special.bar_id, session[:user])
        unless special.nil?
          special.destroy
        end
        redirect("/special/#{special.bar_id}")
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
        special = Special.all(:bar_id => bar.id)
        special.each do |drink|
          drink.destroy
        end
        day = Day.all(:bar_id => bar.id)
        day.each do |weekday|
          weekday.destroy
        end
        event = BarEvent.all(:bar_id => bar.id)
        event.each do |evt|
          evt.destroy
        end
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
  @img = true
  @day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
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