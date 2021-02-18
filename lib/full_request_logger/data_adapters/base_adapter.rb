require "zlib"

module FullRequestLogger::DataAdapters
  class BaseAdapter
    def self.object
      @object ||= new
    end

    def write(_key)
      raise NotImplementedError, 'subclass did not define #write'
    end

    def find(_id)
      raise NotImplementedError, 'subclass did not define #find'
    end

    def all(_page: 1, _per_page: 50, _query: nil)
      raise NotImplementedError, 'subclass did not define #all'
    end

    def clear
      raise NotImplementedError, 'subclass did not define #clear'
    end

    def close; end

    def request_key(id)
      "full_request_logger/requests/#{id}"
    end

    def compress(text)
      Zlib::Deflate.deflate(text)
    end

    def uncompress(text)
      Zlib::Inflate.inflate(text)
    end

    class FullRequestLog < OpenStruct
      def to_hash
        to_h
      end
    end
  end
end
