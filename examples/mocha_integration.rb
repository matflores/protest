require "protest"
require "mocha"

class Protest::TestCase
  include Mocha::API

  alias :original_run :run
  def run(report)
    original_run(report)
    mocha_verify
  ensure
    mocha_teardown
  end
end

Protest.describe("An expectation") do
  setup do
    @m = mock(:object)
  end

  # An example failure
  it "should call the mock" do
    @m.expects(:call).once
  end

  # An example success
  it "should call the mock, really" do
    @m.expects(:call).once
    @m.call
  end
end
