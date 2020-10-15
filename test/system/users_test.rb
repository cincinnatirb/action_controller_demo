require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "visiting the index" do
    visit users_url
    assert_selector "h1", text: "Users"
  end

  test "creating a User" do
    visit users_url
    click_on "New User"

    fill_in "Account expiration", with: @user.account_expiration
    fill_in "Bicycles", with: @user.bicycles
    fill_in "Bio", with: @user.bio
    fill_in "Birth date", with: @user.birth_date
    check "Earthling" if @user.earthling
    fill_in "First name", with: @user.first_name
    fill_in "Gpa", with: @user.gpa
    fill_in "Last name", with: @user.last_name
    fill_in "Username", with: @user.username
    click_on "Create User"

    assert_text "User was successfully created"
    click_on "Back"
  end

  test "updating a User" do
    visit users_url
    click_on "Edit", match: :first

    fill_in "Account expiration", with: @user.account_expiration
    fill_in "Bicycles", with: @user.bicycles
    fill_in "Bio", with: @user.bio
    fill_in "Birth date", with: @user.birth_date
    check "Earthling" if @user.earthling
    fill_in "First name", with: @user.first_name
    fill_in "Gpa", with: @user.gpa
    fill_in "Last name", with: @user.last_name
    fill_in "Username", with: @user.username
    click_on "Update User"

    assert_text "User was successfully updated"
    click_on "Back"
  end

  test "destroying a User" do
    visit users_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "User was successfully destroyed"
  end
end
