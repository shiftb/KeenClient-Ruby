$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'keen'
require 'fakeweb'

describe Keen::Client do

  # Make it so that we don't actually hit keen server during tests:
  before :all do
    FakeWeb.register_uri(:any, %r/https:\/\/api.keen.io\//, :body => '{"message": "You tried to reach Keen"}')
  end
  
  # TODO spec it, lazy!

end
