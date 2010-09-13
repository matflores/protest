require "test_helper"

Protest.describe("Assertions") do
  describe "assert" do
    it "should pass if the condition is true" do
      assert true
    end
    
    it "should fail if the condition is false" do
      assert_raise(Protest::AssertionFailed) { assert false }
    end
  end

  describe "assert_equal" do
    it "should pass if both arguments are equal" do
      assert_equal 1, 1
    end
    
    it "should fail if both arguments are different" do
      assert_raise(Protest::AssertionFailed) { assert_equal 1, 0 }
    end
  end

  describe "assert_raise" do
    describe "without specifying an exception class" do
      it "should pass if the code block raises an exception of any kind" do
        assert_raise { raise "Boom!" }
      end

      it "should fail if the code block does not raise any exceptions" do
        assert_raise(Protest::AssertionFailed) { assert_raise { } }
      end
    end
    
    describe "using a specific exception" do
      it "should pass if the code block raises that exception" do
        assert_raise(ArgumentError) { raise ArgumentError }
      end

      it "should fail if the code block does not raise any exceptions" do
        assert_raise(Protest::AssertionFailed) { assert_raise { } }
      end

      it "should fail if the code block raises an exception different than the one it was specified" do
        assert_raise(Protest::AssertionFailed) { assert_raise(ArgumentError) { raise LoadError } }
      end
    end
  end
end
