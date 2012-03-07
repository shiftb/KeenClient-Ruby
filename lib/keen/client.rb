module Keen
  class Client
    def self.process_queue(options)

      file_handler = Keen::Storage::FlatFileHandler.new(options[:filepath])

      event_lists = ()

      queue = file_handler.rotate_and_process
      queue.each do |job|
        project_id = job.project_id

        if not event_lists.has_key? project_id
          event_lists[project_id] = {
            :auth_token => job.auth_token,
            :events => [],
          }
        end

        event_lists[project_id][:events] << job.event_body
        event_lists[project_id][:events] << job.event_body

      end



      event_list.each do |key, value|
      end

    end
  end
end
