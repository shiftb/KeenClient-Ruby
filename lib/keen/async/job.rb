require 'keen/async/storage/redis_handler'

module Keen
  module Async
    class Job
      # Represents one job.
      #
      #

      attr_accessor :project_id, :auth_token, :collection_name, :event_body
      
      def to_json(options=nil)
        @definition.to_json
      end


      def to_s
        self.to_json
      end
      
      def initialize(handler, definition={})

        load_definition(definition)
        @handler = handler
        
      end

      def load_definition(definition)

        definition = Keen::Utils.symbolize_keys(definition)

        # define some key lists:
        required_keys = [:project_id, :auth_token, :collection_name, :event_body]
        optional_keys = []
        all_keys = required_keys + optional_keys


        # don't allow them to send nil values for anything
        definition.each do |key, value|
          # reject unrecognized keys:
          raise "Unrecognized key: #{key}" unless all_keys.include? key.to_sym
        end


        required_keys.each do |key|
          value = definition[key]

          raise "You sent a nil value for the #{key}." if value.nil?
        end


        all_keys.each do |key|
          value = definition[key]
          self.instance_variable_set("@#{key}", value)
        end

        @definition = definition


      end

      def save
        @handler.record_job(self)
      end

    end
  end
end


