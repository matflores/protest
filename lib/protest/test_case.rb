module Protest
  # Define a top level test context where to define tests. This works exactly
  # the same as subclassing TestCase explicitly.
  #
  #     Protest.context "A user" do
  #       ...
  #     end
  #
  # is just syntax sugar to write:
  #
  #     class TestUser < Protest::TestCase
  #       self.description = "A user"
  #       ...
  #     end
  def self.context(description, &block)
    TestCase.context(description, &block)
  end

  class << self
    alias_method :describe,   :context
    alias_method :story,      :context
  end

  # A TestCase defines a suite of related tests. You can further categorize
  # your tests by declaring nested contexts inside the class. See
  # TestCase.context.
  class TestCase
    # Run all tests in this context. Takes a Runner instance in order to
    # provide output.
    def self.run(runner)
      tests.each {|test| runner.report(test) }
    end

    # Tests added to this context.
    def self.tests
      @tests ||= []
    end

    # Add a test to be run in this context. This method is aliased as +it+,
    # +should+ and +scenario+ for your comfort.
    def self.test(name, &block)
      tests << new(name, caller.at(0), &block)
    end

    # Add a setup block to be run before each test in this context. This method
    # is aliased as +before+ for your comfort.
    def self.setup(&block)
      define_method :setup do
        super()
        instance_eval(&block)
      end
    end

    # Add a teardown block to be run after each test in this context. This
    # method is aliased as +after+ for your comfort.
    def self.teardown(&block)
      define_method :teardown do
        instance_eval(&block)
        super()
      end
    end

    # Define a new test context nested under the current one. All +setup+ and
    # +teardown+ blocks defined on the current context will be inherited by the
    # new context. This method is aliased as +describe+ and +story+ for your 
    # comfort.
    def self.context(description, &block)
      subclass = Class.new(self)
      subclass.class_eval(&block) if block
      subclass.description = description
      const_set(sanitize_description(description), subclass)
    end

    class << self
      # Fancy name for your test case, reports can use this to give nice,
      # descriptive output when running your tests.
      attr_accessor :description

      alias_method :describe,   :context
      alias_method :story,      :context

      alias_method :before,     :setup
      alias_method :after,      :teardown

      alias_method :it,         :test
      alias_method :should,     :test
      alias_method :scenario,   :test
    end

    # Initialize a new instance of a single test. This test can be run in
    # isolation by calling TestCase#run.
    def initialize(name, location, &block)
      @test = block
      @location = location
      @name = name
    end

    # Run a test in isolation. Any +setup+ and +teardown+ blocks defined for
    # this test case will be run as expected.
    #
    # You need to provide a Runner instance to handle errors/pending tests/etc.
    #
    # If the test's block is nil, then the test will be marked as pending and
    # nothing will be run.
    def run(report)
      @report = report
      pending if test.nil?

      begin
        setup
        instance_eval(&test)
      ensure
        teardown
        @report = nil
      end
    end

    # Ensure a condition is met. This will raise AssertionFailed if the
    # condition isn't met. You can override the default failure message
    # by passing it as an argument.
    def assert(condition, message="Expected condition to be satisfied")
      @report.on_assertion
      raise AssertionFailed, message unless condition
    end

    # Passes if expected == actual. You can override the default
    # failure message by passing it as an argument.
    def assert_equal(expected, actual, message=nil)
      assert expected == actual, message || "#{expected.inspect} expected but was #{actual.inspect}"
    end

    # Passes if the code block raises the specified exception. If no
    # exception is specified, passes if any exception is raised,
    # otherwise it fails. You can override the default failure message
    # by passing it as an argument.
    def assert_raise(exception_class=Exception, message=nil)
      begin
        yield
      rescue exception_class => e
      ensure
        assert e, message || "Expected #{exception_class.name} to be raised"
      end
    end

    # Make the test be ignored as pending. You can override the default message
    # that will be sent to the report by passing it as an argument.
    def pending(message="Not Yet Implemented")
      raise Pending, message, [@location, *caller].uniq
    end

    # Name of the test
    def name
      @name
    end

    private

    def setup #:nodoc:
    end

    def teardown #:nodoc:
    end

    def test
      @test
    end

    def self.sanitize_description(description)
      "Test#{description.gsub(/\W+/, ' ').strip.gsub(/(^| )(\w)/) { $2.upcase }}".to_sym
    end
    private_class_method :sanitize_description

    def self.description #:nodoc:
      parent = ancestors[1..-1].detect {|a| a < Protest::TestCase }
      "#{parent.description rescue nil} #{@description}".strip
    end

    def self.inherited(child)
      Protest.add_test_case(child)
    end
  end
end
