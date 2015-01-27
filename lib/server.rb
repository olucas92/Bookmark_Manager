require 'data_mapper'
require 'sinatra'
require 'rack-flash'


env = ENV['RACK_ENV'] || 'development'

# We're telling datamapper to use a postgres database on localhost. The name will be "bookmark_manager_test" or "bookmark_manager_development" depending on the environment
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link' #this needs to be done after datamapper is initialized
require './lib/tag'
require './lib/user'

# After declaring your models, you should finalise them
DataMapper.finalize

# However, the database tables don't exist yet. Let's tell datamapper to create them
DataMapper.auto_upgrade!

set :views, Proc.new { File.join(root, "..", "views")}
enable :sessions
set :session_secret, 'super secret'
use Rack::Flash
# attr_reader :password
# attr_accessor :password_confirmation

# # this is datamaper's method of validating the model.
# # The model will not be save unless both password
# # and password_confirmation are the same

# validated_confirmation_of :password


get '/' do
  @links = Link.all
  erb :index
end

post '/links' do
  url = params["url"]
  title = params["title"]
  tags = params["tags"].split(" ").map { |tag| Tag.first_or_create(:text => tag) }
  # this will either find this tag or create
  # if one doesn't exist already
  Link.create(:url => url, :title => title, :tags => tags)
  redirect to('/')
end

get '/tags/:text' do
  tag = Tag.first(:text => params[:text])
  @links = tag ? tag.links : []
  erb :index
end

get '/users/new' do
  @user = User.new
  # note the view is in views/users/new.erb
  # we need the quotes because otherwise
  # ruby would divide the symbol :users by the
  # variable new (which makes no sense)
  erb :"users/new"
end

post '/users' do
  # We just initializa the object
  # without saving it. it may be invalid
  @user = User.create(:email => params[:email],
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])
  # let's try saving it
  # if the model is valid,
  # it will be saved
  if @user.save
    session[:user_id] = @user.id
    redirect to ('/')
  # if it's not valid, we'll show the same form again
  else
    flash.now[:errors] = @user.errors.full_messages
    erb :"users/new"
  end
end

get '/sessions/new' do
  erb :"sessions/new"
end

post '/sessions' do
  email, password = params[:email], params[:password]
  user = User.authenticate(email, password)
  if user
    session[:user_id] = user.id
    redirect to('/')
  else
    flash[:errors] = ["The email or password is incorrect"]
    erb :"sessions/new"
  end
end

helpers do

  def current_user
    @current_user ||=User.get(session[:user_id]) if session[:user_id]
  end

end