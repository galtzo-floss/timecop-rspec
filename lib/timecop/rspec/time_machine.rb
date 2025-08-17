require "timecop"

require_relative "example_decorator"

class Timecop
  module Rspec
    # Executes an example using Timecop for a single, isolated time operation.
    class TimeMachine
      # Singleton instance accessor.
      # @return [Timecop::Rspec::TimeMachine]
      def self.instance
        @instance ||= new
      end

      # Run an RSpec example, applying local timecop metadata if present.
      #
      # @param example [#run,#metadata] An RSpec example or object responding to
      #   the example protocol that will be wrapped by ExampleDecorator.
      # @return [Object] the result of running the example
      def run(example)
        example = ExampleDecorator.new(example)

        return example.run unless example.timecop?

        method = example.timecop_method
        time = example.timecop_time

        Timecop.public_send(method, time) do
          example.run
        end
      end
    end
  end
end
