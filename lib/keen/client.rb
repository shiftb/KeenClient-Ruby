require "keen/async/storage/redis_handler"
require "keen/async/job"
require "json"
require "uri"
require "time"


module Keen

  class Client

    attr_accessor :storage_handler, :project_id, :auth_token

    def initialize(project_id, auth_token, options = {})

      raise "project_id must be string" unless project_id.kind_of? String
      raise "auth_token must be string" unless auth_token.kind_of? String

      default_options = {
        :storage_mode => :redis,
      }
      
      options = default_options.update(options)

      @project_id = project_id
      @auth_token = auth_token
      @storage_mode = options[:storage_mode]
    end

    def handler

      unless @storage_handler
        @storage_handler = self.class.create_new_storage_handler(@storage_mode)
      end

      @storage_handler
    end

    def add_event(collection_name, event_body, timestamp=nil)
      #
      # `collection_name` should be a string
      #
      # `event_body` should be a JSON-serializable hash
      #
      # `timestamp` is optional. If sent, it should be a Time instance.  
      #  If it's not sent, we'll use the current time.

      validate_collection_name(collection_name)

      unless timestamp
        timestamp = Time.now
      end

      event_body[:_timestamp] = timestamp.utc.iso8601

      job = Keen::Async::Job.new(handler, {
        :project_id => @project_id,
        :auth_token => @auth_token,
        :collection_name => collection_name,
        :event_body => event_body,
      })

      job.save
    end

    def validate_collection_name(collection_name)
      # TODO
    end

    def self.create_new_storage_handler(storage_mode)
      case storage_mode.to_sym
      when :redis
        Keen::Async::Storage::RedisHandler.new
      else
        raise "Unknown storage_mode sent to client: `#{storage_mode}`"
      end
    end

  end
end
