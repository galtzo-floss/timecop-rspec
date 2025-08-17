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

class Timecop
  module Rspec
    # Decorates an RSpec example to interpret timecop metadata.
    #
    # Recognized metadata keys:
    # - :freeze => Time/Date/DateTime/String/Proc to freeze time to
    # - :travel => Time/Date/DateTime/String/Proc to travel to (and optionally continue)
    # - :skip_global_timecop => when present, disables global time for this example
    class ExampleDecorator < SimpleDelegator
      # @return [Boolean] whether any timecop behavior applies to the example
      def timecop?
        local_timecop? || global_timecop?
      end

      # Determines the timecop method to invoke.
      # @return [Symbol, nil] :freeze, :travel, or nil
      def timecop_method
        local_timecop_method || global_timecop_method
      end

      # Determines the time to use for the chosen timecop method.
      # @return [Object, nil] a time-like object or nil when not applicable
      def timecop_time
        local_timecop_time || global_timecop_time
      end

      # Whether the example has local timecop metadata.
      # @return [Boolean]
      def local_timecop?
        local_timecop_method.present?
      end

      # Whether a global time is configured and not skipped by the example.
      # @return [Boolean]
      def global_timecop?
        Rspec.global_time_configured? && !skip_global_timecop?
      end

      # Whether the example requested skipping global timecop behavior.
      # @return [Boolean]
      def skip_global_timecop?
        metadata.key?(:skip_global_timecop)
      end

      private

      # Reads the timecop method from example metadata.
      # @return [Symbol, nil]
      def local_timecop_method
        metadata.keys.find do |key|
          key == :freeze || key == :travel
        end
      end

      # Evaluates local timecop time, supporting Proc values evaluated in the example context.
      # @return [Object, nil]
      def local_timecop_time
        time = metadata[timecop_method]
        return if time.nil?
        time.respond_to?(:call) ? example.instance_exec(&time) : time
      end

      # Global time always uses :travel.
      # @return [Symbol, nil]
      def global_timecop_method
        :travel if global_timecop?
      end

      # Global time value when applicable.
      # @return [Time, nil]
      def global_timecop_time
        Rspec.global_time if global_timecop?
      end
    end
  end
end
