module Moped
  module GridFS
    module Inspectable

      private

      def build_inspect_string(hash)
        memaddr = (__send__(:object_id) << 1).to_s(16)
        string = "#<#{self.class.name}:#{memaddr}"
        hash.each { |k, v| string << " #{k}=#{v}" }
        string << ">"
      end
    end
  end
end
