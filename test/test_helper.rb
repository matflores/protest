require "protest"

module TestHelpers
  class IORecorder
    attr_reader :messages

    def initialize
      @messages = []
    end

    def puts(msg=nil)
      @messages << msg
    end

    def print(msg=nil)
      @messages << msg
    end
  end

  def silent_report(type=:progress)
    Protest.report(type, IORecorder.new)
  end

  def mock_test_case(report=:progress, &block)
    test_case = Protest.describe(name, &block)
    test_case.description = ""
    nested_contexts = Protest.test_cases.select {|t| t < test_case }

    report = silent_report(report)
    Protest::Runner.new(report).run(*[test_case, *nested_contexts])
    report
  end
end

class Protest::TestCase
  include TestHelpers
end
