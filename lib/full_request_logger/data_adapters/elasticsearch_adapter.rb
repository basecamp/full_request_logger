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
      from = (page - 1) * per_page

      results = if query.present?
        repository.search(query: { match: { body: query } }, from: from, size: per_page).results
      else
        repository.search({ query: { match_all: {} } }, from: from, size: per_page).results
      end

      WillPaginate::Collection.create(page, per_page, repository.count) do |pager|
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
        client: Elasticsearch::Client.new(url: ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200'))
      )
    end

    # Need to find a solution to use ttl, one approach is use job and clear at given time
    class FullRequestLoggerRepository
      include Elasticsearch::Persistence::Repository
      include Elasticsearch::Persistence::Repository::DSL

      index_name 'full_request_logger'
      klass FullRequestLogger::DataAdapters::ElastisearchAdapter::FullRequestLog
      document_type 'log'
    end
  end
end
