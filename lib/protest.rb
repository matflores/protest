module Protest
  # Exception raised when an assertion fails. See TestCase#assert
  class AssertionFailed < StandardError; end

  # Exception raised to mark a test as pending. See TestCase#pending
  class Pending < StandardError; end

  # Register a new Report. This will make your report available to Protest,
  # allowing you to run your tests through this report. For example
  #
  #     module Protest
  #       class Reports::MyAwesomeReport < Report
  #       end
  #
  #       add_report :awesomesauce, MyAwesomeReport
  #     end
  #
  # See Protest.report_with to see how to select which report will be used.
  def self.add_report(name, report)
    reports[name] = report
  end

  # Set to +false+ to avoid running tests +at_exit+. Default is +true+.
  def self.autorun=(flag)
    @autorun = flag
  end

  # Checks to see if tests should be run +at_exit+ or not. Default is +true+.
  # See Protest.autorun=
  def self.autorun?
    !!@autorun
  end

  # Run all registered test cases through the selected report. You can pass
  # arguments to the Report constructor here.
  #
  # See Protest.add_test_case and Protest.report_with
  def self.run_all_tests!(*report_args)
    Runner.new(@report).run(*test_cases)
  end

  # Select the name of the Report to use when running tests. See
  # Protest.add_report for more information on registering a report.
  #
  # Any extra arguments will be forwarded to the report's #initialize method.
  #
  # The default report is Protest::Reports::Documentation
  def self.report_with(name, *report_args)
    @report = report(name, *report_args)
  end

  # Load a report by name, initializing it with the extra arguments provided.
  # If the given +name+ doesn't match a report registered via
  # Protest.add_report then the method will raise IndexError.
  def self.report(name, *report_args)
    reports.fetch(name).new(*report_args)
  end

  # Set what object will filter the backtrace. It must respond to
  # +filter_backtrace+, taking a backtrace array and a prefix path.
  def self.backtrace_filter=(filter)
    @backtrace_filter = filter
  end

  # The object that filters the backtrace
  def self.backtrace_filter
    @backtrace_filter
  end

  def self.test_cases
    @test_cases ||= []
  end

  def self.reports
    @reports ||= {}
  end
  private_class_method :reports
end

require "protest/version"
require "protest/utils"
require "protest/utils/backtrace_filter"
require "protest/utils/summaries"
require "protest/utils/colorful_output"
require "protest/test_case"
require "protest/tests"
require "protest/runner"
require "protest/report"
require "protest/reports"
require "protest/reports/progress"
require "protest/reports/documentation"
require "protest/reports/turn"
require "protest/reports/summary"

Protest.autorun = true
Protest.report_with((ENV["PROTEST_REPORT"] || "documentation").to_sym)
Protest.backtrace_filter = Protest::Utils::BacktraceFilter.new

at_exit do
  if Protest.autorun?
    Protest.run_all_tests!
    report = Protest.instance_variable_get(:@report)
    exit report.failures_and_errors.empty?
  end
end
