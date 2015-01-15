require 'data_mapper'
require 'tag'

env = ENV['RACK_ENV'] || 'development'

# We're telling datamapper to use a postgres database on localhost. The name will be "bookmark_manager_test" or "bookmark_manager_development" depending on the environment
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link' #this needs to be done after datamapper is initialized

# After declaring your models, you should finalise them
DataMapper.finalize

# However, the database tables don't exist yet. Let's tell datamapper to create them
DataMapper.auto_upgrade!

set :views, Proc.new { File.join(root, "..", "views")}


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