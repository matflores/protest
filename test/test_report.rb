require "test_helper"

module Protest
  class Reports::Test < Report
    include Utils::Summaries
    include Utils::ColorfulOutput

    attr_reader :stream #:nodoc:

    # Set the stream where the report will be written to. STDOUT by default.
    def initialize(stream=STDOUT)
      @stream = stream
    end

    on :start     do |report           | report.puts "start"     end
    on :enter     do |report, test_case| report.puts "enter"     end
    on :test      do |report, test     | report.puts "test"      end
    on :assertion do |report           | report.puts "assertion" end
    on :pass      do |report, pass     | report.puts "pass"      end
    on :pending   do |report, pending  | report.puts "pending"   end
    on :failure   do |report, failure  | report.puts "failure"   end
    on :error     do |report, error    | report.puts "error"     end
    on :exit      do |report, test_case| report.puts "exit"      end
    on :end       do |report           | report.puts "end"       end
  end

  add_report :test, Reports::Test
end

Protest.describe("A report") do
  it "handles all events fired by the runner" do
    report = mock_test_case(:test) do
      test("passing test") { assert true  }
      test("pending test") { pending      }
      test("failing test") { assert false }
      test("errored test") { raise "foo"  }
    end

    expected_sequence = %w(start enter test assertion pass test pending test assertion failure test error exit end)

    assert_equal expected_sequence, report.stream.messages
  end

  it "records the total number of tests" do
    report = mock_test_case(:test) do
      test("passing test") { assert true  }
      test("pending test") { pending      }
      test("failing test") { assert false }
      test("errored test") { raise "foo"  }
    end

    assert_equal 4, report.total_tests
  end

  it "records the number of passed tests" do
    report = mock_test_case(:test) do
      test("passing test") { assert true  }
      test("pending test") { pending      }
      test("failing test") { assert false }
      test("errored test") { raise "foo"  }
    end

    assert_equal 1, report.passes.size
  end

  it "records the number of pending tests" do
    report = mock_test_case(:test) do
      test("passing test") { assert true  }
      test("pending test") { pending      }
      test("failing test") { assert false }
      test("errored test") { raise "foo"  }
    end

    assert_equal 1, report.pendings.size
  end

  it "records the number of failures" do
    report = mock_test_case(:test) do
      test("passing test") { assert true  }
      test("pending test") { pending      }
      test("failing test") { assert false }
      test("errored test") { raise "foo"  }
    end

    assert_equal 1, report.failures.size
  end

  it "records the number of errors" do
    report = mock_test_case(:test) do
      test("passing test") { assert true  }
      test("pending test") { pending      }
      test("failing test") { assert false }
      test("errored test") { raise "foo"  }
    end

    assert_equal 1, report.errors.size
  end
end
