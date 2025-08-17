# The MIT License (MIT)

# Copyright (c) 2014-2017 Avant

# Author Zach Taylor

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
