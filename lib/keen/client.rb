module Keen
  class Client

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
      Keen::Storage::RedisHandler.process_queue
    end

    def self.process_queue_from_flat_file(options)

      file_handler = Keen::Storage::FlatFileHandler.new(options[:filepath])
      
      event_lists = ()

      queue = file_handler.rotate_and_process
      queue.each do |job|
        project_id = job.project_id
        collection_name = job.collection_name
        
        key = project_id + collection_name

        if not event_lists.has_key? project_id
          event_lists[project_id] = {
            :events => [],
          }
        end

        event_lists[project_id][:events] << job.event_body
        # TODO:  collate errrthing

      end

      event_list.each do |key, value|
        # TODO: call Sender class to actually do something
        
      end

    end
  end
end
