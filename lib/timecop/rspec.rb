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

require "timecop/rspec/version"
require "active_support/all"

Dir.glob(File.join(__dir__, "rspec", "**", "*.rb")).each { |file| require file }

# Top-level namespace for Timecop helpers.
class Timecop
  # RSpec integration for the timecop gem.
  #
  # Provides helpers to run examples with frozen or traveling time, and an
  # optional global time that applies across examples when configured via ENV.
  #
  # Environment variables:
  # - GLOBAL_TIME_TRAVEL_TIME: String representation of a time (preferred)
  # - GLOBAL_TIME_TRAVEL_DATE: String representation of a date (fallback)
  module Rspec
    class << self
      # Selects a time machine strategy.
      #
      # @param sequential [Boolean] when true, uses a sequential strategy that
      #   can continue a travel across examples; when false, uses a simple per
      #   example strategy.
      # @return [Timecop::Rspec::SequentialTimeMachine, Timecop::Rspec::TimeMachine]
      def time_machine(sequential: false)
        if sequential
          SequentialTimeMachine.instance
        else
          TimeMachine.instance
        end
      end

      # Whether a global time has been configured via ENV.
      # @return [Boolean]
      def global_time_configured?
        global_time_travel_string.present?
      end

      # The globally configured time parsed from ENV.
      # @return [Time] the parsed time
      # @raise [ArgumentError] if ENV contains an unparsable time/date string
      def global_time
        @global_time ||= Time.parse(global_time_travel_string)
      end

      private

      # The raw ENV value used to determine the global time.
      # @return [String, nil]
      def global_time_travel_string
        ENV["GLOBAL_TIME_TRAVEL_TIME"] || ENV["GLOBAL_TIME_TRAVEL_DATE"]
      end
    end
  end
end
