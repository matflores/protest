module Protest
  class Runner
    # Set up the test runner. Takes in a report that will be passed to test
    # cases for reporting.
    def initialize(report)
      @report = report
    end

    # Run a set of test cases, provided as arguments. This will fire relevant
    # events on the runner's report, at the +start+ and +end+ of the test run,
    # and before and after each test case (+enter+ and +exit+.)
    def run(test_cases, options = {})
      fire_event :start

      if options[:line_numbers]
        test_groups = nearest_test_groups(test_cases, options[:line_numbers])
      else
        test_groups = test_cases.zip(test_cases.map(&:tests))
      end

      test_groups.each do |test_case, tests|
        fire_event :enter, test_case
        tests.each { |test| report(test) }
        fire_event :exit, test_case
      end
    rescue Interrupt
      $stderr.puts "Interrupted!"
    ensure
      fire_event :end
    end

    # Run a test and report if it passes, fails, or is pending. Takes the name
    # of the test as an argument.
    def report(test)
      fire_event(:test, Test.new(test))
      test.run(@report)
      fire_event(:pass, PassedTest.new(test))
    rescue Pending => e
      fire_event :pending, PendingTest.new(test, e)
    rescue AssertionFailed => e
      fire_event :failure, FailedTest.new(test, e)
      exit 1 if Protest.fail_early?
    rescue Exception => e
      raise if e.is_a?(Interrupt)
      fire_event :error, ErroredTest.new(test, e)
      exit 1 if Protest.fail_early?
    end

    protected

    def fire_event(event, *args)
      event_handler_method = :"on_#{event}"
      @report.send(event_handler_method, *args) if @report.respond_to?(event_handler_method)
    end

    private

    def nearest_test_groups(test_cases, line_numbers)
      test_groups        = []
      grouped_test_cases = test_cases.group_by(&:filename)

      grouped_test_cases.each do |filename, test_cases|
        if line_numbers.key?(filename)
          line_number = line_numbers[filename]
          runnables = test_cases + test_cases.flat_map(&:tests)
          runnables.sort_by!(&:line_number).reverse!

          runnable = runnables.find { |runnable| runnable.line_number <= line_number }
          next if runnable.nil?

          if runnable.is_a?(TestCase)
            test_groups << [runnable.class, [runnable]]
          elsif runnable < TestCase
            test_groups << [runnable, runnable.tests]
            test_cases.each do |test_case|
              test_groups << [test_case, test_case.tests] if test_case < runnable
            end
          end
        else
          test_groups.concat test_cases.zip(test_cases.map(&:tests))
        end
      end

      test_groups
    end
  end
end
