require 'elasticsearch/persistence'
require 'ostruct'

module FullRequestLogger::DataAdapters
  class ElastisearchAdapter < BaseAdapter
    def write(**args)
      log = FullRequestLog.new(request_id: request_key(args[:request_id]), body: args[:body])
      repository.save(log)
    end

    def find(request_id)
      repository.search(query: { match: { request_id: request_key(request_id) } }).first
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def all(page: 1, per_page: 50, query: nil)
      results = if query.present?
        repository.search(query: { match: { body: query } }).results
      else
        repository.search({ query: { match_all: {} } }).results
      end

      WillPaginate::Collection.create(page, per_page, results.count) do |pager|
        pager.replace results[pager.offset, pager.per_page].to_a
      end
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def clear
      repository.delete_index!
      @repository = nil
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    private

    def repository
      @repository ||= FullRequestLoggerRepository.new(
        client: Elasticsearch::Client.new(url: ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200')),
        index_name: :full_request_logger,
        document_type: 'log',
        klass: FullRequestLog
      )
    end

    class FullRequestLoggerRepository; include Elasticsearch::Persistence::Repository end
  end
end
