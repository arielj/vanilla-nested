require "application_system_test_case"

class VanillaNestedTest < ApplicationSystemTestCase
  test "adds/removes fields" do
    visit users_path
    click_link 'New User'

    assert_selector '#new_user'

    assert_selector '.pet-fields', count: 1

    within '.pet-fields:nth-of-type(1)' do
      fill_in 'Name', with: 'Spike'
    end

    # adds 1 pet
    find('a.vanilla-nested-add', text: 'Add Pet').click

    assert_selector '.pet-fields', count: 2

    within '.pet-fields:nth-of-type(2)' do
      fill_in 'Name', with: 'Marnie'
    end

    # removes first pet
    within '.pet-fields:nth-of-type(1)' do
      find('a.vanilla-nested-remove', text: 'X').click
    end

    # first pet is hidden
    assert_selector '.pet-fields', count: 1, visible: :hidden do |wrapper|
      assert_equal '1', wrapper.find('[name$="[_destroy]"]', visible: :hidden).value
    end

    # second pet is visible
    assert_selector '.pet-fields', count: 1, visible: :visible do |wrapper|
      # verify it's the second one
      assert_equal 'Marnie', wrapper.first('input').value
    end
  end

  test "emits an event when the association limit is reached" do
    visit new_user_path

    assert_selector '#new_user'

    assert_selector '.pet-fields', count: 1

    find('a.vanilla-nested-add', text: 'Add Pet').click

    assert_selector '.pet-fields', count: 2

    assert_selector 'span', text: 'Limit reached', count: 0

    find('a.vanilla-nested-add', text: 'Add Pet').click

    assert_selector '.pet-fields', count: 3
    assert_selector 'span', text: 'Limit reached', count: 1
  end
end
