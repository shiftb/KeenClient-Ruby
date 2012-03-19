require "keen/async/storage/redis_handler"
require "net/http"
require "net/https"



module Keen

  module Async

    # How many events should we send over the wire at a time?
    BATCH_SIZE = 100
    SSL_CA_FILE = File.dirname(__FILE__) + '../../../conf/cacert.pem'
     
    class Worker

      def initialize(handler)
        @handler = handler
      end

      def batch_url(project_id)
        if not project_id
          raise "Missing project_id."
        end
        "https://api.keen.io/1.0/projects/#{project_id}/_events"
      end

      def process_queue

        queue_length = @handler.count_active_queue

        batch_size = Keen::Async::BATCH_SIZE

        num_batches = queue_length / batch_size

        num_batches.times do
          collated = @handler.get_collated_jobs(batch_size)
          collated.each do |project_id, batch|
            send_batch(project_id, batch)
          end
        end
      end
      
      def send_batch(project_id, batch)
        if not batch
          return
        end
        
        first_key = batch.keys[0]
        job_list = batch[first_key]
        auth_token = job_list[0].auth_token
        
        uri = URI.parse(batch_url(project_id))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.ca_file = Keen::Async::SSL_CA_FILE
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_depth = 5

        request = Net::HTTP::Post.new(uri.path)
        request.body = batch.to_json
        request["Content-Type"] = "application/json"
        request["Authorization"] = auth_token

        response = http.request(request)

        #response = Net::HTTP.start(uri.host, uri.port) {|http|
          #http.request(request)
        #}

        puts response
        # TODO: If something fails, we should move the job to the 
        # prior_failures queue by calling, perhaps:
        #
        # @handler.log_failed_job(job)
      end

    end
  end

end
