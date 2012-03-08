require 'fileutils'
require 'redis'
require 'json'

module Keen
  module Storage
    class Item
      # Represents one item in the Redis queue.
      
      def initialize(definition={})
        @project_id = definition[:project_id]
        @auth_token = definition[:auth_token]
        @collection_name = definition[:collection_name]
        @event_body = definition[:event_body]
        
        # TODO: type checking?
      end

      def save
        handler = Keen::Storage::RedisHandler.new
        handler.add_event(self)
      end

    end

    class ProjectBatch
      # Represents a batch of records (for a given project)
      def initialize(project_id, auth_token)
        @project_id = project_id
        @auth_token = auth_token
        @items = []
      end

      def add_item(item)
        @items.push(item)
      end
    end

    class RedisHandler

      # Keys
      # ----

      def global_key_prefix
        "keen-" + Keen::VERSION
      end
      
      def active_queue_key
        "#{global_key_prefix}.active_queue_key"
      end

      def processing_queue_key
        "#{global_key_prefix}.processing_queue_key"
      end

      def failed_queue_key
        "#{global_key_prefix}.failed_queue_key"
      end

      def lock_active_queue_key
        "lock" + active_queue_key
      end

      def lock_active_queue
        # TODO: add locking
        key = lock_active_queue_key
      end

      def unlock_active_queue
        # TODO: add locking
        key = lock_active_queue_key
      end

      def record_event(collection_name, event_body)
        # TODO this is the main public method!
        # must write..
      end

      def handle_prior_failures
        # TODO consume the failed_queue and do something with it (loggly? retry? flat file?)
      end

      def initialize
        @redis = Redis.new
      end

      def get_active_queue_contents
        # get the list of jsonified hashes back:
        list = @redis.get active_queue_key

        if not list
          []
        end
      end

      def flush_active_queue
        @redis.del active_queue_key
      end

      def set_processing_queue(queue)
      end

      def process_queue
        handle_prior_failures

        lock_active_queue

        queue = get_active_queue_contents

        flush_active_queue

        set_processing_queue(queue)

        unlock_active_queue

        # translate the queue strings into Items
        items = queue.map {|json| Keen::Storage::Item.new(JSON.parse json)}.compact

        collated = collate_items_by_project(items)
      end

      def collate_items_by_project(queue)
        collated = {}

        # traverse backwards so the most recent auth tokens take precedent:
        queue.reverse_each do |item_hash|
          key = item.project_id
          if not collated.has_key? key
            collated[key] = Keen::Storage::ProjectBatch.new
          end

          collated[key].add_item(item)
        end

        collated
      end

    end
  end
end
