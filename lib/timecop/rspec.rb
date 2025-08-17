require "timecop/rspec/version"

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
        str = global_time_travel_string
        !(str.nil? || str == "")
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
