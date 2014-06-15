module Moped
  module GridFS
    module AccessModes

      attr_reader :mode

      ACCESS_MODES = %w[r r+ w w+ a a+]

      def readable?
        mode =~ /r|\+/
      end

      def writable?
        mode =~ /w|\+|a/
      end

      def append?
        mode =~ /a/
      end

      def read_only?
        mode == 'r'
      end

      def write_only?
        mode == 'w' or mode == 'a'
      end

      def read_write?
        mode =~ /\+/
      end

      private

      def append_only?
        mode == 'a'
      end

      def need_file?
        mode == 'r' or mode == 'r+'
      end

      def truncate?
        mode == 'w' or mode == 'w+'
      end
    end
  end
end
