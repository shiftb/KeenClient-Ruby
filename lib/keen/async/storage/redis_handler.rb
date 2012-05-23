require 'fileutils'
require 'redis'
require 'json'
require 'time'

module Keen
  module Async
    module Storage
      class RedisHandler

        # Keys
        # ----

        def global_key_prefix
          "keen_415" + Keen::VERSION
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
        
        def redis=(connection)
          @redis = connection
        end

        def count_active_queue
          @redis.llen active_queue_key
        end

        def get_collated_jobs(how_many)

          # Returns a hash of the next `how_many` jobs, indexed on project_id and then collection_name.
          #
          # It looks like this:
          #
          #  collated = {
          #    "4f5775ad163d666a6100000e" => {
          #      "clicks" => [
          #        Keen::Storage::Job.new({
          #          :project_id => "4f5775ad163d666a6100000e",
          #          :auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
          #          :collection_name => "clicks",
          #          :event_body => {:user_id => "12345"},
          #        }),
          #        Keen::Storage::Job.new({
          #          :project_id => "4f5775ad163d666a6100000e",
          #          :auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
          #          :collection_name => "clicks",
          #          :event_body => {:user_id => "12345"},
          #        }),
          #        Keen::Storage::Job.new({
          #          :project_id => "4f5775ad163d666a6100000e",
          #          :auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
          #          :collection_name => "clicks",
          #          :event_body => {:user_id => "12345"},
          #        }),
          #      ],
          #      "purchases" => [
          #        Keen::Storage::Job.new({
          #          :project_id => "4f5775ad163d666a6100000e",
          #          :auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
          #          :collection_name => "purchases",
          #          :event_body => {:user_id => "12345"},
          #        }),
          #        Keen::Storage::Job.new({
          #          :project_id => "4f5775ad163d666a6100000e",
          #          :auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
          #          :collection_name => "purchases",
          #          :event_body => {:user_id => "12345"},
          #        }),
          #        Keen::Storage::Job.new({
          #          :project_id => "4f5775ad163d666a6100000e",
          #          :auth_token => "a5d4eaf432914823a94ecd7e0cb547b9",
          #          :collection_name => "purchases",
          #          :event_body => {:user_id => "12345"},
          #        }),
          #      ],
          #    }
          #  }

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

          queue.each do |job_hash|

            job = Keen::Async::Job.new(self, job_hash)

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
end
