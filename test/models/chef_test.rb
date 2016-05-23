require 'test_helper'

class ChefTest < ActiveSupport::TestCase

  def setup
    @chef = Chef.new(chefname: "john", email: "john@example.com" )
  end

  test "chef should be valid" do
    assert @chef.valid?
  end

  test "chef name should be present" do
    @chef.chefname = ""
    assert_not @chef.valid?
  end

  test "chef name should not be too long" do
    @chef.chefname = "a" * 41
    assert_not @chef.valid?
  end

  test "chef name should not be too short" do
    @chef.chefname = "aa"
    assert_not @chef.valid?
  end

  test "email should be present" do
    @chef.email = ""
    assert_not @chef.valid?
  end

  test "email length should be within bounds" do
    @chef.email = "a" * 101 + "@example.com"
    assert_not @chef.valid?
  end

  test "email address should be unique" do
    alt_chef = @chef.dup
    alt_chef.email = @chef.email.upcase
    @chef.save
    assert_not alt_chef.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@eee.com R_DD-DS@eee.hello.org user@example.com first.last@eem.au laura+joe@monk.com]
    valid_addresses.each do |va|
      @chef.email = va
      assert @chef.valid?, "##{va.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_eee.org user.name@example. eee@ia_am_.com foo@eee+aar.com]
    invalid_addresses.each do |ia|
      @chef.email = ia
      assert_not @chef.valid?, "#{ia.inspect} should be invalid"
    end
  end

end
