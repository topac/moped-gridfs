require 'benchmark'
require_relative '../spec/spec_helper'

if $INCLUDE_MONGO
  require 'mongo'

  def mongo_connection
    client = Mongo::MongoClient.new(ENV["MOPED-GRIDFS_SPEC_HOST"], ENV["MOPED-GRIDFS_SPEC_PORT"])
    client[ENV["MOPED-GRIDFS_SPEC_DB"]]
  end

  module Mongo
    class GridIO
      def warn(*args); end
    end
  end
end

def purge
  drop_all_collections
end

def profile(message, options = {})
  ary = [options[:n] || 1].flatten

  ary.each do |n|
    puts message+" (#{n} times)"

    Benchmark.bm do |bm|
      yield(bm, n)
    end
  end
end
