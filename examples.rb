require 'rubygems'
require 'keen'
 
# Get these from the keen.io website:
project_id = 'asdfasldkfjalsdkfalskdfj'
auth_token = 'asldfjklj325tkl32jaskdlfjaf'

# First you must setup the client:
keen = Keen::Client.new(project_id, auth_token, :storage_mode => :redis)

# Then, you can use that client to send events.  

keen.add_event("purchases", {
  :quantity   => @quantity,
  :user       => @user.hashify,
  :item       => @item.hashify,
  :session    => @session.hashify,
})

keen.add_event("pageviews", {
  :user       => @user.hashify,
  :route      => @current_route,
  :session    => @session.hashify,
})

# (These examples pretend your important objects all have a method called
# "hashify", and that method serializes state information you wish to track.)
