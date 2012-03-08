module Keen
  class Client
    
    @auth_token

    def initialize(project_id, auth_token)
    end

    def add_event(collection_name, event_body)
      validate_collection_name(collection_name)

    end

    def self.process_queue(options)
      mode = options[:storage_mode].to_sym
      case mode
      when :flat_file
        self.process_queue_from_flat_file(options)
      when :redis
        self.process_queue_from_redis(options)
      else
        raise "Unknown storage_mode sent: `#{mode}`"
      end
    end

    def self.process_queue_from_redis(options)
      require 'keen/storage/redis_handler'
      handler = Keen::Storage::RedisHandler.new
      collated = handler.process_queue

      collated.each do |project_id, batch|
        self.send_batch(project_id, batch)
      end
    end
    
    def send_batch(project_id, batch)
      # TODO DK:  need to send this batch of Keen::Storage::Item instances
      # to API!  we can just use the first auth_token we find on an Item.
      # If something fails, stick the item into the prior_failures queue
      # using push
    end

    def self.process_queue_from_flat_file(options)
      raise "this feature isn't supported yet!!!"
    end
  end
end
