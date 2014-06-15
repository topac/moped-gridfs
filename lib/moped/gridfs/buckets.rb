require "moped/gridfs/bucket"

module Moped
  module GridFS
    class Buckets
      include Enumerable

      attr_reader :session

      def initialize(session)
        @session = session
      end

      def names
        collections.map { |collection| collection.name.gsub('.files', '') }
      end

      def count
        collections.size
      end

      def [](name)
        Bucket.new(session, name)
      end

      def each(&block)
        names.each { |name| yield(self[name]) }
      end

      private

      def collections
        session.collections.select { |collection| collection.name =~ /.+\.files\z/ }
      end
    end
  end
end
