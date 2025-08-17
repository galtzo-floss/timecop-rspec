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
    # Tracks details about a time travel operation that can be resumed later.
    class TravelLog
      # @param travel_method [Symbol, nil] :travel or :freeze (or nil)
      # @param start_time [Object, nil] a time-like object or string
      def initialize(travel_method = nil, start_time = nil)
        new_trip(travel_method, start_time)
      end

      # Either resumes a previous trip or starts a new one.
      # @param travel_method [Symbol] :travel or :freeze
      # @param start_time [Object] a time-like object or string
      # @return [Object] the computed starting time for the trip
      def resume_or_new_trip(travel_method, start_time)
        if resume_trip?(travel_method, start_time)
          resume_trip
        else
          new_trip(travel_method, start_time)
        end
      end

      # Pauses the current trip, recording its duration.
      # @return [void]
      def pause_trip
        self.trip_duration = Time.current - coalesced_start_time
      end

      private

      attr_accessor :travel_method, :start_time, :trip_duration

      # Starts a new trip tracking session.
      # @param travel_method [Symbol, nil]
      # @param start_time [Object, nil]
      # @return [void]
      def new_trip(travel_method, start_time)
        reset_duration
        self.travel_method = travel_method
        self.start_time = start_time
      end

      # Determines whether the provided method/time match the current trip.
      # @return [Boolean]
      def resume_trip?(other_travel_method, other_start_time)
        travel_method == other_travel_method &&
          start_time == other_start_time &&
          start_time.class == other_start_time.class
      end

      # The start time for resuming a trip including the elapsed duration.
      # @return [Object]
      def resume_trip
        coalesced_start_time + trip_duration.seconds
      end

      # Coerces various time-like inputs into a Time-like baseline.
      # @return [Object]
      def coalesced_start_time
        case start_time
        when DateTime
          start_time
        when Date
          start_time.at_beginning_of_day
        when String
          Time.parse(start_time)
        else
          start_time
        end
      end

      # Resets the recorded duration.
      # @return [void]
      def reset_duration
        self.trip_duration = 0
      end
    end
  end
end
