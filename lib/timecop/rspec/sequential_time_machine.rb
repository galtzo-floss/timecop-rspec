require_relative "example_decorator"
require_relative "traveler"
require_relative "travel_log"

class Timecop
  module Rspec
    # Executes examples while allowing time travel to continue across examples.
    #
    # Uses TravelLog to coalesce sequential :travel operations when the same
    # method and start time are reused, enabling long-running time journeys
    # across multiple examples.
    class SequentialTimeMachine
      # Singleton instance accessor.
      # @return [Timecop::Rspec::SequentialTimeMachine]
      def self.instance
        @instance ||= new
      end

      # Run an example with either local or global travel, or without any timecop.
      # @param example [#run,#metadata]
      # @return [Object]
      def run(example)
        example = ExampleDecorator.new(example)

        runner_for(example).run
      end

      private

      # Selects the appropriate runner for the example.
      # @param example [ExampleDecorator]
      # @return [#run]
      def runner_for(example)
        if example.local_timecop?
          Traveler.new(example, local_travel_log)
        elsif example.global_timecop?
          Traveler.new(example, global_travel_log)
        else
          example
        end
      end

      # Local travel log used for examples that specify local timecop metadata.
      # @return [TravelLog]
      def local_travel_log
        @local_travel_log ||= TravelLog.new
      end

      # Global travel log used when a global time is configured.
      # @return [TravelLog]
      def global_travel_log
        @global_travel_log ||= TravelLog.new(:travel, Rspec.global_time)
      end
    end
  end
end
