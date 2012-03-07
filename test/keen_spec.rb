$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'keen'
require 'fakeweb'

describe Keen::Client do

  # Make it so that we don't actually hit keen server during tests:
  before :all do
    FakeWeb.register_uri(:any, %r/https:\/\/api.keen.io\//, :body => '{"message": "You tried to reach Keen"}')
  end
  
  # TODO spec it out, lazy bones!
  #
  #
  # Each time an event is logged, we'll store a json-serialized, base64-
  # encoded, and gzipped hash that loos like this:
  #
  # {
  #   :project_id       => "alsdjfaldskfjadskladsklj",
  #   :auth_token       => "aslkjflk3wjfaklsjdflkasdjflkadjflakdj211",
  #   :collection_name  => "purchases",
  #   :event_body       => {:prop1 => "val1", :prop2 => "val2"},
  # }

end
