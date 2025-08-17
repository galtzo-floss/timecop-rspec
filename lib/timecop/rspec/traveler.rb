class Timecop
  module Rspec
    # Runs an example, optionally continuing a travel across invocations.
    class Traveler
      # @param example [ExampleDecorator]
      # @param travel_log [TravelLog]
      def initialize(example, travel_log)
        @example = example
        @travel_log = travel_log
      end

      # Executes the example within the appropriate Timecop context.
      # If the method is :travel, the starting time may be adjusted based on
      # prior trips recorded in the travel log.
      #
      # @return [Object]
      def run
        method = example.timecop_method
        time = example.timecop_time

        if method == :travel
          time = travel_log.resume_or_new_trip(
            example.timecop_method, example.timecop_time
          )
        end

        ::Timecop.public_send(method, time) do
          begin
            example.run
          ensure
            travel_log.pause_trip if method == :travel
          end
        end
      end

      private

      # @return [ExampleDecorator]
      attr_reader :example
      # @return [TravelLog]
      attr_reader :travel_log
    end
  end
end
