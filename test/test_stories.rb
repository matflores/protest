require "test_helper"
require "protest/stories"

Protest.story "As a user I want to create stories so I can test if they pass" do
  setup do
    @user = "valid user"
  end

  scenario "A valid user" do
    assert_equal "valid user", @user
  end
end

Protest.story "As a user I want helpers so that I can extract" do
  def some_helper
    1
  end

  scenario "A call to a helper" do
    report "I use some helper" do
      some_helper
    end
    assert_equal 1, some_helper
  end
end
