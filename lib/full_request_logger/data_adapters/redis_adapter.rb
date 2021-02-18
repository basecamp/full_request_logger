require "redis"

module FullRequestLogger::DataAdapters
  class RedisAdapter < BaseAdapter
    def write(**args)
      redis.setex(request_key(args[:key]), args[:ttl], args[:text])
    end

    def find(id)
      redis.get(request_key(id))
    end

    def all(page: 1, per_page: 50, query: nil)
      start_index = (page.to_i - 1) * per_page
      stop_index = page.to_i * per_page - 1

      index = 0
      http_truncated_log_list = []
      # There is not other way to get count of filtered keys in redis
      total_count = 0
      redis.scan_each(match: 'full_request_logger/requests/*') do |key|
        total_count += 1

        if index.between?(start_index, stop_index)
          key = key.gsub('full_request_logger/requests/', '')
          body = find(key)

          if query.blank? || (query.present? && body.include?(query))
            http_truncated_log_list << OpenStruct.new(
              request_id: key,
              body: body.to_s.truncate(100)
            )
          end
        end

        index += 1
      end

      WillPaginate::Collection.create(page.to_i, per_page, total_count) do |pager|
        pager.replace(http_truncated_log_list.to_a)
      end
    end

    def clear
      if (request_keys = redis.keys(request_key("*"))).any?
        redis.del request_keys
      end
    end

    def close
      redis.disconnect!
    end

    private

    def redis
      @redis ||= Redis.new FullRequestLogger.redis
    end
  end
end
