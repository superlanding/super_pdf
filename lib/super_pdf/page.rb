module SuperPDF
  module Page
    extend ActiveSupport::Concern

    DEFAULT_SIZE = 'A4'
    SIZE = {}

    included do
      def page_size
        self.class.custom_page_size || DEFAULT_SIZE
      end
    end

    class_methods do
      attr_reader :custom_page_size

      def page_size(key_or_size)
        @custom_page_size ||= Page.real_size(key_or_size)
      end
    end

    def self.real_size(key_or_size)
      SIZE[key_or_size]
    end
  end
end
