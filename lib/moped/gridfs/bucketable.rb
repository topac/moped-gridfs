module Moped
  module GridFS
    module Bucketable
      def files_collection
        if self.respond_to?(:session)
          session[:"#{name}.files"]
        else
          bucket.files_collection
        end
      end

      def chunks_collection
        if self.respond_to?(:session)
          session[:"#{name}.chunks"]
        else
          bucket.chunks_collection
        end
      end

      private

      def parse_selector(selector)
        if selector.kind_of?(String)
          {filename: selector}
        elsif selector.kind_of?(BSON::ObjectId)
          {_id: selector}
        else
          selector
        end
      end
    end
  end
end
