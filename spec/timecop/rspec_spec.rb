RSpec.describe Timecop::Rspec do
  it "has a version number" do
    expect(Timecop::Rspec::VERSION).not_to be_nil
  end

  describe "::time_machine" do
    it "returns a TimeMachine instance by default" do
      expect(described_class.time_machine).to be_a(Timecop::Rspec::TimeMachine)
    end

    it "returns the same TimeMachine instance on repeated calls" do
      first = described_class.time_machine
      expect(described_class.time_machine).to be(first)
    end

    it "returns a SequentialTimeMachine when sequential: true" do
      expect(described_class.time_machine(:sequential => true)).to be_a(Timecop::Rspec::SequentialTimeMachine)
    end

    it "returns the same SequentialTimeMachine instance on repeated calls" do
      first = described_class.time_machine(:sequential => true)
      expect(described_class.time_machine(:sequential => true)).to be(first)
    end
  end

  describe "global time config and value" do
    # Helper to clear memoized global_time between examples
    def clear_global_time_memo!
      sc = Timecop::Rspec.singleton_class
      sc.remove_instance_variable(:@global_time) if sc.instance_variable_defined?(:@global_time)
      Timecop::Rspec.remove_instance_variable(:@global_time) if Timecop::Rspec.instance_variable_defined?(:@global_time)
    end

    before do
      clear_global_time_memo!
      allow(ENV).to receive(:[]).and_call_original
    end

    after { clear_global_time_memo! }

    it "is not configured when no env vars present" do
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return(nil)
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return(nil)
      expect(described_class.global_time_configured?).to be(false)
    end

    it "is configured when GLOBAL_TIME_TRAVEL_TIME is set" do
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return("2015-02-09")
      expect(described_class.global_time_configured?).to be(true)
    end

    it "is configured when GLOBAL_TIME_TRAVEL_DATE is set" do
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return(nil)
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return("2016-03-04")
      expect(described_class.global_time_configured?).to be(true)
    end

    it "parses from GLOBAL_TIME_TRAVEL_TIME" do
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return(nil)
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return("2015-02-09")
      expect(described_class.global_time).to eq(Time.parse("2015-02-09"))
    end

    it "memoizes global_time across calls" do
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return(nil)
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return("2015-02-09")
      cached = described_class.global_time
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return("2020-01-01")
      expect(described_class.global_time).to be(cached)
    end

    it "recomputes global_time after memo is cleared" do
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return(nil)
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return("2020-01-01")
      clear_global_time_memo!
      expect(described_class.global_time).to eq(Time.parse("2020-01-01"))
    end

    it "falls back to GLOBAL_TIME_TRAVEL_DATE when TIME is not set" do
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return(nil)
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return("2017-08-09")
      expect(described_class.global_time).to eq(Time.parse("2017-08-09"))
    end

    it "TIME takes precedence when both TIME and DATE are set" do
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return("2030-12-25")
      allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return("1999-01-01")
      expect(described_class.global_time).to eq(Time.parse("2030-12-25"))
    end
  end
end
