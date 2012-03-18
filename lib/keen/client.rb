require 'keen/async/storage/redis_handler'
require 'keen/async/job'
require 'json'
require "net/http"
require "uri"


module Keen

  class Client

    attr_accessor :storage_handler, :project_id, :auth_token

    def initialize(project_id, auth_token, options = {})

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
        mode = @storage_mode

        case mode
        when :redis
          @storage_handler = Keen::Async::Storage::RedisHandler.new
        else
          raise "Unknown storage_mode sent to client: `#{mode}`"
        end

      end

      @storage_handler
    end

    def add_event(collection_name, event_body)
      validate_collection_name(collection_name)

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

  end
end
