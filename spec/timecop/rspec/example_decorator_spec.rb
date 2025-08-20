require "timecop/rspec"

RSpec.describe Timecop::Rspec::ExampleDecorator do
  subject(:decorator) { described_class.new(example_procsy) }

  let(:some_example) { instance_double(RSpec::Core::Example) }
  let(:metadata) { {} }
  let(:example_procsy) do
    instance_double(
      RSpec::Core::Example::Procsy,
      :example => some_example,
      :metadata => metadata,
    )
  end

  before do
    # Preserve original behavior for other keys, but control the globals explicitly
    allow(ENV).to receive(:[]).and_call_original
  end

  describe "#global_timecop_method and #global_timecop_time" do
    context "when global time travel is NOT configured" do
      before do
        allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return(nil)
        allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return(nil)
      end

      it "returns nil for method" do
        expect(decorator.send(:global_timecop_method)).to be_nil
      end

      it "returns nil for time" do
        expect(decorator.send(:global_timecop_time)).to be_nil
      end
    end

    context "when global time travel is configured" do
      let(:global_time_str) { "2015-02-09" }

      before do
        allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return(global_time_str)
        # ensure DATE fallback isn't accidentally read in this context
        allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return(nil)
        # Clear any memoized value to ensure deterministic assertions
        sc = Timecop::Rspec.singleton_class
        sc.remove_instance_variable(:@global_time) if sc.instance_variable_defined?(:@global_time)
      end

      it "returns :travel for method" do
        expect(decorator.send(:global_timecop_method)).to eq(:travel)
      end

      it "returns the parsed global time for time" do
        expect(decorator.send(:global_timecop_time)).to eq(Time.parse(global_time_str))
      end
    end

    context "when global time travel is configured and when :skip_global_timecop metadata is set" do
      let(:global_time_str) { "2015-02-09" }

      before do
        allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_TIME").and_return(global_time_str)
        allow(ENV).to receive(:[]).with("GLOBAL_TIME_TRAVEL_DATE").and_return(nil)
        sc = Timecop::Rspec.singleton_class
        sc.remove_instance_variable(:@global_time) if sc.instance_variable_defined?(:@global_time)
        metadata[:skip_global_timecop] = true
      end

      it "returns nil for method" do
        expect(decorator.send(:global_timecop_method)).to be_nil
      end

      it "returns nil for time" do
        expect(decorator.send(:global_timecop_time)).to be_nil
      end
    end
  end
end
