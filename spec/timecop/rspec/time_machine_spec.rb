require "timecop/rspec"

require_relative "a_time_machine"

RSpec.describe Timecop::Rspec::TimeMachine do
  it_behaves_like "a time machine"
end
