require 'fileutils'
require 'redis'
require 'json'
require 'time'

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

    class RedisHandler

      # Keys
      # ----

      def global_key_prefix
        "keen-" + Keen::VERSION
      end
      
      def active_queue_key
        "#{global_key_prefix}.active_queue_key"
      end

      def failed_queue_key
        "#{global_key_prefix}.failed_queue_key"
      end

      def add_to_active_queue(value)
        @redis.lpush active_queue_key, value
        puts "added #{value} to active queue; length is now #{@redis.llen active_queue_key}"
      end

      def record_job(job)
        add_to_active_queue JSON.generate(job)
      end

      def handle_prior_failures
        # TODO consume the failed_queue and do something with it (loggly? retry? flat file?)
      end

      def initialize
        @redis = Redis.new
      end

      def count_active_queue
        @redis.llen active_queue_key
      end

      def grab_and_collate(how_many)
        handle_prior_failures

        key = active_queue_key

        jobs = []

        how_many.times do
          this = @redis.lpop key
          jobs.push JSON.parse this
        end

        collate_jobs(jobs)
      end

      def collate_jobs(queue)
        collated = {}

        # traverse backwards so the most recent auth tokens take precedent:
        queue.reverse_each do |job_hash|

          job = Keen::Storage::Job.new(job_hash)

          if not collated.has_key? job.project_id
            collated[job.project_id] = {}
          end

          if not collated[job.project_id].has_key? job.collection_name
            collated[job.project_id][job.collection_name] = []
          end

          collated[job.project_id][job.collection_name].push(job)
        end

        collated
      end

    end
  end
end
