require 'fileutils'
require 'redis'

module Keen
  module Storage
    class RedisHandler

      # Keys
      # ----

      GLOBAL_KEY_PREFIX = "keen-" + Keen::VERSION
      
      # Where new events go as they come in:
      ACTIVE_QUEUE_KEY = "active_queue"

      # The temporary file that will store records during processing:
      PROCESSING_QUEUE_KEY = "processing_queue"

      # Records are put here if processing fails:
      FAILED_QUEUE_KEY = "failed_queue"

      def active_queue_key
        "#{self.GLOBAL_KEY_PREFIX}.#{self.ACTIVE_QUEUE_KEY}"
      end

      def processing_queue_key
        "#{self.GLOBAL_KEY_PREFIX}.#{self.PROCESSING_QUEUE_KEY}"
      end

      def failed_queue_key
        "#{self.GLOBAL_KEY_PREFIX}.#{self.FAILED_QUEUE_KEY}"
      end

      def lock_active_queue_key
        "lock" + active_queue_key
      end

      def initialize()

      end

      def dump_contents
        # move
      end

      def is_writable?
        if not FileTest.writable? @filepath
          raise "Can't write to file: " + @filepath
        end
      end
      
      def is_readable?
        if not FileTest.readable? @filepath
          raise "Can't read from file: " + @filepath
        end
      end

      def is_directory?
        if not FileTest.directory? @filepath
          raise "Can't read from file: " + @filepath
        end
      end

    end
  end
end
