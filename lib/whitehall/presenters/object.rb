module Whitehall
  module Presenters
    class Object < Delegator
      def initialize(record)
        super(record)
        @record = record
      end

      def class
        @record.class
      end

      def inspect
        "<Presenter:#{super}>"
      end

      def __is_presenter?
        true
      end

      def __setobj__(record)
        @record = record
      end

      def __getobj__
        @record
      end
    end
  end
end