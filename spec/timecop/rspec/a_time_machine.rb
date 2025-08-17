RSpec.shared_examples "a time machine" do
  subject(:time_machine) { described_class.new }

  let(:example_procsy) do
    instance_double(
      RSpec::Core::Example::Procsy,
      :example => some_example,
      :metadata => {},
    )
  end

  let(:some_example) { instance_double(RSpec::Core::Example) }

  # ActiveSupport::TimeZone removed; tests no longer depend on Time.zone
  let(:us_tz) { nil }
  let(:gb_tz) { nil }

  describe "#run" do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return(global_travel_time)
      # Time.zone is not used without ActiveSupport
    end

    context "global time travel disabled" do
      let(:global_travel_time) { nil }

      it "runs the example in real time when no time travel specified" do
        original_time = Time.now

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(1).of(original_time)
        end

        time_machine.run(example_procsy)
      end

      it "runs the example in travelled time with a date/time" do
        travel_date = Date.new(2016, 12, 15)
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Date.today).to eq travel_date
        end

        time_machine.run(example_procsy)
      end

      it "runs the example in frozen time with a date/time" do
        travel_time = Time.new(2016, 12, 15, 3, 2, 1)
        example_procsy.metadata[:freeze] = travel_time

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to eq travel_time
        end

        time_machine.run(example_procsy)
      end

      it "advances example and context level time travel time when executing successive examples with the same travel start value" do
        travel_date = Date.new(2016, 12, 15)
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(2).of(Time.local(2016, 12, 15, 0, 0, 0))
        end
        time_machine.run(example_procsy)

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(2).of(Time.local(2016, 12, 15, 0, 0, 0))
        end
        time_machine.run(example_procsy)

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(2).of(Time.local(2016, 12, 15, 0, 0, 0))
        end
        time_machine.run(example_procsy)
      end

      it "accepts string date/time values" do
        travel_date = "2015-7-14 12:00:00"
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(1).of(Time.local(2015, 7, 14, 12, 0, 0))
        end
        time_machine.run(example_procsy)
      end

      it "works correctly with DateTime objects" do
        travel_date = DateTime.new(2016, 7, 15, 16, 28)
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          # The assertion is time shifted in CST, because DateTime.new uses UTC zone if none is specified
          # and will be coerced into local time zone when timecop mutates time.  The lesson here is to be sure
          # your specified DateTime zone matches your test's effective timezone when using timecop.
          expect(Time.now).to be_within(1).of(Time.utc(2016, 7, 15, 16, 28, 0).getlocal)
        end
        time_machine.run(example_procsy)
      end

      it "does not continue time when Date follows similar DateTime" do
        travel_date = DateTime.new(2016, 7, 15)
        travel_date_2 = Date.new(2016, 7, 15)

        # Ruby considers a DateTime at start of day to be equal to a Date on the same day
        expect(travel_date).to eql travel_date_2

        example_procsy.metadata[:travel] = travel_date
        expect(example_procsy).to receive(:run) do
          # The assertion is time shifted in CST, because DateTime.new uses UTC zone if none is specified
          # and will be coerced into local time zone when timecop mutates time.  The lesson here is to be sure
          # your specified DateTime zone matches your test's effective timezone when using timecop.
          expect(Time.now).to be_within(1).of(Time.utc(2016, 7, 15, 0, 0, 0).getlocal)
        end
        time_machine.run(example_procsy)

        example_procsy.metadata[:travel] = travel_date_2
        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(1).of(Time.local(2016, 7, 15, 0, 0, 0))
        end
        time_machine.run(example_procsy)
      end

      it "does not advance example or context level time travel time when executing successive examples with the same freeze start value" do
        travel_date = Time.local(2016, 12, 15, 0, 0, 0)
        example_procsy.metadata[:freeze] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to eq travel_date
        end
        time_machine.run(example_procsy)

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to eq travel_date
        end
        time_machine.run(example_procsy)

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to eq travel_date
        end
        time_machine.run(example_procsy)
      end

      context "specifying a proc for time travel" do
        it "runs the example in travelled time with a proc evaluated against the example" do
          some_example.instance_variable_set(:@my_date, Date.new(2016, 6, 1))
          travel_date = -> { @my_date }
          example_procsy.metadata[:travel] = travel_date

          expect(example_procsy).to receive(:run) do
            expect(Date.today).to eq Date.new(2016, 6, 1)
          end

          time_machine.run(example_procsy)
        end

        it "runs the example in frozen time with a proc evaluated against the example" do
          some_example.instance_variable_set(:@my_time, Time.new(2016, 12, 15, 3, 2, 1))
          travel_time = -> { @my_time }
          example_procsy.metadata[:freeze] = travel_time

          expect(example_procsy).to receive(:run) do
            expect(Time.now).to eq Time.new(2016, 12, 15, 3, 2, 1)
          end

          time_machine.run(example_procsy)
        end
      end
    end

    context "global time travel enabled" do
      let(:global_travel_time) { "2015-02-09" }

      it "runs the example in global time travel time" do
        expect(example_procsy).to receive(:run) do
          # Interpret the global travel time as a local midnight anchor and
          # assert on Date.today to avoid timezone-specific APIs.
          expected_date = Date.new(2015, 2, 9)
          expect(Date.today).to eq expected_date
        end

        time_machine.run(example_procsy)
      end

      it "runs the example in real time when :skip_global_timecop specified" do
        original_time = Time.now
        example_procsy.metadata[:skip_global_timecop] = true

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(1).of(original_time)
        end

        time_machine.run(example_procsy)
      end

      it "runs the example in travelled example time when :travel specified" do
        travel_date = Date.new(2016, 12, 15)
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Date.today).to eq travel_date
        end

        time_machine.run(example_procsy)
      end

      it "runs the example in frozen example time when :freeze specified" do
        travel_time = Time.new(2016, 12, 15, 3, 2, 1)
        example_procsy.metadata[:freeze] = travel_time

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to eq travel_time
        end

        time_machine.run(example_procsy)
      end
    end
  end
end
