require_relative "test_helper"

Protest.describe("A test case") do
  it "records the number of assertions run" do
    report = mock_test_case do
      test "I have 2 assertions" do
        assert true
        assert false
      end
    end

    assert_equal 2, report.assertions
  end

  it "passes if no assertion fails or an exception is raised" do
    report = mock_test_case do
      test "Passing test" do
        # not doing anything will mark the test as passed.
        # I'm not sure I like that a lot though.
      end
    end

    assert_equal 1, report.passes.size
    assert_equal 1, report.total_tests
  end

  it "is pending without a test block" do
    report = mock_test_case do
      test "I'm Pending"
    end

    assert_equal 1, report.pendings.size
    assert_equal 1, report.total_tests
  end

  it "is pending when calling the #pending method inside the test" do
    report = mock_test_case do
      test "I'm pending" do
        pending
        assert true
      end
    end

    assert_equal 1, report.pendings.size
    assert_equal 1, report.total_tests
    assert_equal 0, report.assertions
  end

  it "fails if an assertion is flunked" do
    report = mock_test_case do
      test "Failed assertions" do
        assert false
      end
    end

    assert_equal 1, report.failures.size
    assert_equal 1, report.failures_and_errors.size
    assert_equal 1, report.total_tests
  end

  it "errors if an unrescued exception is raised" do
    report = mock_test_case do
      test "Unrescued exception" do
        raise "I'm nasty"
      end
    end

    assert_equal 1, report.errors.size
    assert_equal 1, report.failures_and_errors.size
    assert_equal 1, report.total_tests
  end

  it "skips to the next test after an unrescued exception is raised" do
    report = mock_test_case do
      test "Unrescued exception" do
        raise "I'm nasty"
      end

      test "Passing test" do
        assert true
      end
    end

    assert_equal 1, report.errors.size
    assert_equal 1, report.failures_and_errors.size
    assert_equal 1, report.passes.size
    assert_equal 2, report.total_tests
  end

  it "runs setup blocks before the tests, and they share state with your test" do
    report = mock_test_case do
      setup do
        @foo = 1
      end

      test "state is shared between setup and tests" do
        assert @foo == 1
      end
    end

    assert_equal 1, report.passes.size
    assert_equal 1, report.total_tests
  end

  it "runs teardown blocks after the tests, and they share state with your test" do
    report = mock_test_case do
      teardown do
        assert @foo == 1
      end

      test "sets a variable for teardown" do
        @foo = 1
      end
    end

    assert_equal 1, report.passes.size
    assert_equal 1, report.total_tests
  end

  it "runs teardown blocks after the tests, even if the test code raised an exception" do
    report = mock_test_case do
      teardown do
        @report.print "teardown"
      end

      test "raise an exception" do
        raise "foo"
      end
    end

    assert report.stream.messages.include?("teardown")

    assert_equal 1, report.errors.size
    assert_equal 1, report.total_tests
  end

  it "doesn't share state between tests" do
    report = mock_test_case do
      test "first test" do
        assert @foo.nil?
        @foo = 1
      end

      test "second test" do
        assert @foo.nil?
        @foo = 1
      end
    end

    assert_equal 2, report.passes.size
    assert_equal 2, report.total_tests
  end

  context "setting the description of a nested context" do
    it "includes the description of the parent" do
      report = mock_test_case do
        context "A parent context" do
          context "has a child context" do
            test "success!" do
              assert true
            end
          end
        end
      end

      test_case = report.passes.first.test.class
      assert_equal "A parent context has a child context", test_case.description
    end

    it "includes the description of the parent, even if you inject modules into the ancestors chain" do
      report = mock_test_case do
        module M; end

        context "A parent context" do
          context "has a child context" do
            include M

            test "success!" do
              assert true
            end
          end
        end
      end

      test_case = report.passes.first.test.class
      assert_equal "A parent context has a child context", test_case.description
    end
  end

  it "inherits setup/teardown blocks from the outside context" do
    report = mock_test_case do
      context "A parent context" do
        setup do
          @foo = 1
        end

        context "has a child context" do
          test "success!" do
            assert @foo == 1
          end
        end
      end
    end

    assert_equal 1, report.passes.size
    assert_equal 1, report.total_tests
  end
end
