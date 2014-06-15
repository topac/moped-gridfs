require "moped/gridfs/bucketable"
require "moped/gridfs/file"

module Moped
  module GridFS
    class Files
      include Enumerable
      include Bucketable

      attr_reader :bucket

      def initialize(bucket)
        @bucket = bucket
      end

      def [](id)
        bucket.open(id, 'r')
      end

      def count
        files_collection.find.count
      end

      def each(&block)
        files_collection.find.each { |document| yield(self[document['_id']]) }
      end
    end
  end
end
