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
        !local_timecop_method.nil?
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
