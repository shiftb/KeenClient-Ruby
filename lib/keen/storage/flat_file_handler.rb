require 'fileutils'
require 'base64'
require 'zlib'



module Keen
  module Storage
    class FlatFileHandler

      # Paths
      # -----
      
      # Where new events go as they come in:
      ACTIVE = "active.txt"

      # The temporary file that will store records during processing:
      PROCESSING = "processing.txt"

      # Records are put here if processing fails:
      FAILED = "failed.txt"

      def initialize(filepath)
        @filepath = filepath
      
        is_directory?
        is_writable?
        is_readable?
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
