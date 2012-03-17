require 'keen/storage/redis_handler'
require 'json'
require "net/http"
require "uri"


module Keen

  BATCH_SIZE = 100


  class Client

    def self.batch_url(project_id)
      "http://api.keen.io/1.0/projects/#{project_id}/_events"
    end
    
    def initialize(project_id, auth_token)
      @project_id = project_id
      @auth_token = auth_token
    end

    def add_event(collection_name, event_body)
      validate_collection_name(collection_name)

      item = Keen::Storage::Item.new({
        :project_id => @project_id,
        :auth_token => @auth_token,
        :collection_name => collection_name,
        :event_body => event_body,
      })

      item.save
    end

    def validate_collection_name(collection_name)
      # TODO
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
      handler = Keen::Storage::RedisHandler.new

      queue_length = handler.count_active_queue

      batch_size = Keen::BATCH_SIZE

      num_batches = queue_length / batch_size

      num_batches.times do
        collated = handler.grab_and_collate(batch_size)

        collated.each do |project_id, batch|
          self.send_batch(project_id, batch)
        end
      end


      # TODO: remove this mock:
      #collated = {
        #"4f5775ad163d666a6100000e" => {
          #"clicks" => [
            #Keen::Storage::Item.new({
              #:project_id => "4f5775ad163d666a6100000e",
              #:auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
              #:collection_name => "clicks",
              #:event_body => {:user_id => "12345"},
            #}),
            #Keen::Storage::Item.new({
              #:project_id => "4f5775ad163d666a6100000e",
              #:auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
              #:collection_name => "clicks",
              #:event_body => {:user_id => "12345"},
            #}),
            #Keen::Storage::Item.new({
              #:project_id => "4f5775ad163d666a6100000e",
              #:auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
              #:collection_name => "clicks",
              #:event_body => {:user_id => "12345"},
            #}),
          #],
          #"purchases" => [
            #Keen::Storage::Item.new({
              #:project_id => "4f5775ad163d666a6100000e",
              #:auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
              #:collection_name => "purchases",
              #:event_body => {:user_id => "12345"},
            #}),
            #Keen::Storage::Item.new({
              #:project_id => "4f5775ad163d666a6100000e",
              #:auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
              #:collection_name => "purchases",
              #:event_body => {:user_id => "12345"},
            #}),
            #Keen::Storage::Item.new({
              #:project_id => "4f5775ad163d666a6100000e",
              #:auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
              #:collection_name => "purchases",
              #:event_body => {:user_id => "12345"},
            #}),
          #],
        #}
      #}

    end
    
    def self.send_batch(project_id, batch)
      if not batch
        return
      end
      
      first_key = batch.keys[0]
      item_list = batch[first_key]
      puts item_list[0].class
      auth_token = item_list[0].auth_token
      
      uri = URI.parse(self.batch_url(project_id))

      request = Net::HTTP::Post.new(uri.path)
      request.body = batch.to_json
      request["Content-Type"] = "application/json"
      request["Authorization"] = auth_token

      response = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(request)
      }

      puts response

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
