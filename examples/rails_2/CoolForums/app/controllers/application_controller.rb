require 'json'
require 'keen'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :track_pageview


  # Runs before every request:
  def track_pageview

    # Get these from the keen.io website:
    project_id = "4f5775ad163d666a6100000e"
    auth_token = "a5d4eaf432914823a94ecd7e0cb547b9"

    # First you must setup the client:
    keen = Keen::Client.new(project_id, auth_token, :storage_mode => :redis)

    # Log the event with Keen:
    keen.add_event("pageviews", {
      :params   => params,
      :url      => request.url,
    })

  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
