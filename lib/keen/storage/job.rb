module Keen
  module Storage
    class Job
      # Represents one job in the Redis queue.
      #
      #

      attr_accessor :project_id, :auth_token, :collection_name, :event_body, :timestamp
      
      def to_json(options=nil)
        @definition.to_json
      end


      def to_s
        self.to_json
      end
      
      def initialize(definition={})
        @definition = definition
        
        @project_id = definition[:project_id]
        @auth_token = definition[:auth_token]
        @collection_name = definition[:collection_name]
        @event_body = definition[:event_body]
        @timestamp = Time.now.utc.iso8601

        @definition[:timestamp] = @timestamp
        
      end

      def save
        handler = Keen::Storage::RedisHandler.new
        handler.record_job(self)
      end

    end
  end
end


