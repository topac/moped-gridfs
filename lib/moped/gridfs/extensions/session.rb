require "moped"
require "moped/gridfs/bucket"
require "moped/gridfs/buckets"

module Moped
  module GridFS
    module Extensions
      module Session
        def bucket
          Bucket.new(self)
        end

        def buckets
          Buckets.new(self)
        end
      end
    end
  end
end

Moped::Session.__send__(:include, Moped::GridFS::Extensions::Session)
