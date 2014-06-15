require "moped/gridfs/inspectable"
require "moped/gridfs/bucketable"
require "moped/gridfs/access_modes"

module Moped
  module GridFS
    class File
      include Bucketable
      include Inspectable
      include AccessModes

      attr_reader :mode, :attributes, :bucket, :pos

      def initialize(bucket, mode, selector)
        selector = parse_selector(selector)
        @mode = mode
        @bucket = bucket
        @cached_chunk = nil
        @pos = 0

        raise ArgumentError.new("Invalid access mode #{mode}") unless ACCESS_MODES.include?(mode)

        document = files_collection.find(selector).first

        raise "No such file" if need_file? and !document

        if document and truncate?
          chunks_collection.find(files_id: document['_id']).remove_all
          files_collection.find(_id: document['_id']).remove_all

          @attributes = normalize_attributes(selector)
        else
          @attributes = normalize_attributes(document || selector)
          @attributes.freeze if read_only?
        end

        define_dynamic_accessors

        file_query.upsert(attributes) if writable?

        @pos = length if append_only?
      end

      alias :tell :pos

      def pos=(value)
        check_negative_value(value)

        @pos = (append_only? and value < length) ? length : value
      end

      alias :seek :pos=

      def rewind
        self.pos = 0
      end

      def eof?
        raise "Not opened for reading" if write_only?

        pos >= length
      end

      EMPTINESS = ''.force_encoding('BINARY')

      def read(size = length)
        raise "Not opened for reading" if write_only?

        check_negative_value(size)

        chunk_number = pos / chunk_size
        chunk_offset = pos % chunk_size

        data = EMPTINESS

        loop do
          break if data.size >= size
          break unless read_chunk(chunk_number)
          buffer = @cached_chunk[:data][chunk_offset..-1]
          data.empty? ? (data = buffer) : (data << buffer)
          chunk_number += 1
          chunk_offset = 0
        end

        data = data[0..size - 1]
        @pos += data.size
        data
      end

      def write(data)
        raise "Not opened for writing" if read_only?

        data.force_encoding('BINARY') if data.respond_to?(:force_encoding)

        @pos = length if @pos > length
        @pos = length if append?

        chunk_number = pos / chunk_size
        chunk_offset = pos % chunk_size
        written = data.size
        new_length = 0

        loop do
          if buffer = read_chunk(chunk_number)
            data = (chunk_offset.zero? ? EMPTINESS : buffer[0..chunk_offset - 1]) + data + (buffer[chunk_offset + data.size..-1] || EMPTINESS)
          end

          to_write = data[0..chunk_size - 1] || EMPTINESS

          break if to_write.empty?

          new_length = chunk_number * chunk_size + write_chunk(chunk_number, to_write)

          data = data[chunk_size..-1] || EMPTINESS

          break if data.empty?

          chunk_number += 1
          chunk_offset = 0
        end

        # Update internal position
        @pos += written

        # Calculate new md5 (if needed)
        md5 = bucket.md5(@attributes[:_id]) if written > 0

        # Update if something changed
        updates = {}
        updates[:md5] = md5 if md5
        updates[:length] = new_length if new_length > length
        change_attributes(updates) if updates.any?

        written
      end

      DEFAULT_CHUNK_SIZE = 255 * 1024

      def default_chunk_size
        DEFAULT_CHUNK_SIZE
      end

      def inspect
        build_inspect_string(bucket: bucket.name, _id: _id, mode: mode, filename: filename, length: length)
      end

      private

      def normalize_attributes(provided)
        provided.keys.each do |key|
          provided[key.to_sym] = provided.delete(key)
        end

        attrs = {}
        attrs[:_id]         = provided[:_id] ? BSON::ObjectId.from_string(provided[:_id]) : BSON::ObjectId.new
        attrs[:length]      = (provided[:length] || 0).to_i
        attrs[:chunkSize]   = (provided[:chunkSize] || provided[:chunk_size] || default_chunk_size).to_i
        attrs[:filename]    = provided[:filename] || attrs[:_id].to_s
        attrs[:contentType] = provided[:content_type] || provided[:contentType] || 'application/octet-stream'
        attrs[:md5]         = provided[:md5]
        attrs[:aliases]     = provided[:aliases] || []
        attrs[:metadata]    = provided[:metadata] || {}
        attrs[:uploadDate]  = provided[:upload_date] || provided[:uploadDate] || Time.now.utc
        attrs
      end

      PROTECTED_ATTRIBUTES = [:_id, :length, :chunkSize, :md5]

      def define_dynamic_accessors
        attributes.keys.each do |attrname|
          method_name = underscorize(attrname)

          __send__(:define_singleton_method, method_name) { attributes[attrname] }

          if writable? and !PROTECTED_ATTRIBUTES.include?(attrname)
            __send__(:define_singleton_method, :"#{method_name}=") do |value|
              change_attributes(:"#{attrname}" => value)
            end
          end
        end
      end

      def underscorize(name)
        name.to_s.gsub(/([A-Z])/, '_\1').downcase.to_sym
      end

      def check_negative_value(value)
        raise ArgumentError.new("negative value #{value} given") if value < 0
      end

      def change_attributes(hash)
        file_query.update('$set' => hash)
        @attributes.merge!(hash)
      end

      def file_query
        files_collection.find(_id: attributes[:_id])
      end

      def chunk_query(n)
        chunks_collection.find(files_id: attributes[:_id], n: n)
      end

      def chunk(n)
        chunk_query(n).first
      end

      def write_chunk(n, data)
        chunk_query(n).upsert('$set' => {data: binarize(data)})
        @cached_chunk = {n: n, data: data}
        data.size
      end

      def read_chunk(n)
        return @cached_chunk[:data] if @cached_chunk and @cached_chunk[:n] == n
        readed = chunk(n)
        return unless readed
        @cached_chunk = {n: readed['n'], data: readed['data'].data}
        @cached_chunk[:data]
      end

      if Moped::VERSION < '2.0.0'
        def binarize(data)
          BSON::Binary.new(:generic, data)
        end
      else
        def binarize(data)
          BSON::Binary.new(data, :generic)
        end
      end
    end
  end
end
