require "moped/gridfs/files"
require "moped/gridfs/file"
require "moped/gridfs/inspectable"
require "moped/gridfs/bucketable"

module Moped
  module GridFS
    class Bucket
      include Bucketable
      include Inspectable

      attr_reader :name, :session

      DEFAULT_NAME = 'fs'

      def initialize(session, name = DEFAULT_NAME)
        @name = name.to_s.strip
        @session = session

        raise ArgumentError.new("Bucket name cannot be empty") if @name.empty?
      end

      def open(selector, mode)
        ensure_indexes
        file = File.new(self, mode, selector)
        block_given? ? yield(file) : file
      end

      def ensure_indexes
        @indexes_ensured ||= begin
          chunks_collection.indexes.create(files_id: 1, n: 1)
          # Optional index on filename
          files_collection.indexes.create({filename: 1}, {background: true})
          true
        end
      end

      def files
        Files.new(self)
      end

      def md5(file_id)
        session.command(filemd5: file_id, root: name)['md5']
      end

      def delete(selector)
        document = files_collection.find(parse_selector(selector)).first
        return unless document
        chunks_collection.find(files_id: document['_id']).remove_all
        files_collection.find(_id: document['_id']).remove_all
        true
      end

      alias :remove :delete

      def drop
        [files_collection, chunks_collection].map(&:drop)
        @indexes_ensured = false
      end

      def inspect
        build_inspect_string(name: name)
      end
    end
  end
end
