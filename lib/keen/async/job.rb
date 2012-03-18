require 'keen/async/storage/redis_handler'

module Keen
  module Async
    class Job
      # Represents one job.
      #
      #

      attr_accessor :project_id, :auth_token, :collection_name, :event_body, :timestamp
      
      def to_json(options=nil)
        @definition.to_json
      end


      def to_s
        self.to_json
      end
      
      def initialize(handler, definition={})
        @definition = definition
        
        @project_id = definition[:project_id]
        @auth_token = definition[:auth_token]
        @collection_name = definition[:collection_name]
        @event_body = definition[:event_body]
        @timestamp = Time.now.utc.iso8601

        @definition[:timestamp] = @timestamp

        @handler = handler
        
      end

      def save
        @handler.record_job(self)
      end

    end
  end
end


