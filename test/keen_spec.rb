$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'keen'
require 'fakeweb'

describe Keen::Client do

  # Make it so that we don't actually hit keen server during tests:
  before :all do
    FakeWeb.register_uri(:any, %r/https:\/\/api.keen.io\//, :body => '{"message": "You tried to reach Keen"}')
  end

  describe "#add_event" do
    project_id = "4f5775ad163d666a6100000e"
    auth_token = "a5d4eaf432914823a94ecd7e0cb547b9"

    keen = Keen::Client.new(project_id, auth_token, :storage_mode => :redis)

    310.times do
      keen.add_event("rspec_clicks", {
        :hi => "you",
      })
    end

    worker = Keen::Async::Worker.new(handler = keen.storage_handler)

    worker.process_queue

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
