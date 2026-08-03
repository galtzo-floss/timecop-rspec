require "timecop/rspec"

require_relative "a_time_machine"

RSpec.describe Timecop::Rspec::TimeMachine, :skip_global_timecop do
  it_behaves_like "a time machine"
end
