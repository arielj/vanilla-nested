require "application_system_test_case"

class VanillaNestedTest < ApplicationSystemTestCase
  test "adds/removes fields" do
    visit users_path
    click_link 'New User'

    assert_selector '#new_user'

    # one field, not added by vanilla-nested
    assert_selector '.pet-fields:not(.added-by-vanilla-nested)', count: 1

    within '.pet-fields:nth-of-type(1)' do
      fill_in 'Name', with: 'Spike'
    end

    # adds 1 pet
    find('a.vanilla-nested-add', text: 'Add Pet').click

    assert_selector '.pet-fields', count: 2
    # one added and one not added by vanilla-nested
    assert_selector '.pet-fields:not(.added-by-vanilla-nested)', count: 1
    assert_selector '.pet-fields.added-by-vanilla-nested', count: 1

    within '.pet-fields:nth-of-type(2)' do
      fill_in 'Name', with: 'Marnie'
    end

    # removes first pet
    within '.pet-fields:nth-of-type(1)' do
      find('a.vanilla-nested-remove', text: 'X').click
    end

    # first pet is hidden
    assert_selector '.pet-fields', count: 1, visible: :hidden do |wrapper|
      assert_equal 1, wrapper.all('*', visible: :hidden).length
      destroy = wrapper.all('*', visible: :hidden).first
      assert_match /\[_destroy\]\z/, destroy.native.attribute('name')
      assert_equal '1', destroy.value
    end

    # second pet is visible
    assert_selector '.pet-fields', count: 1, visible: :visible do |wrapper|
      # verify it's the second one
      assert_equal 'Marnie', wrapper.first('input').value
    end

    within '.pet-fields:nth-of-type(2)' do
      find('a.vanilla-nested-remove', text: 'X').click
    end

    # second pet is not there anymore
    assert_selector '.pet-fields', count: 1, visible: :hidden
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

  test "accepts custom tags for link_to_add/remove_nested" do
    visit new_with_custom_link_tag_users_path

    assert_selector '#new_user'

    assert_selector '.pet-fields', count: 1

    within '.pet-fields:nth-of-type(1)' do
      fill_in 'Name', with: 'Spike'
    end

    # wrapper is a SPAN tag
    find('span.vanilla-nested-add', text: 'Add Pet').click

    assert_selector '.pet-fields', count: 2

    within '.pet-fields:nth-of-type(2)' do
      fill_in 'Name', with: 'Marnie'
    end

    # wrapper is a DIV tag
    within '.pet-fields:nth-of-type(1)' do
      find('div.vanilla-nested-remove', text: 'X').click
    end
  end

  test "can undo" do
    visit new_with_undo_users_path

    assert_selector '#new_user'

    assert_selector '.pet-fields', count: 1

    within '.pet-fields:nth-of-type(1)' do
      fill_in 'Name', with: 'Spike'
    end

    find('.vanilla-nested-add', text: 'Add Pet').click

    assert_selector '.pet-fields', count: 2

    # test with fields added dynamically
    within '.pet-fields:nth-of-type(2)' do
      assert_selector '.vanilla-nested-undo', text: 'Undo', count: 0
      find('.vanilla-nested-remove', text: 'X').click

      # added the Undo button
      assert_selector '.vanilla-nested-undo', text: 'Undo', count: 1

      # click undo to stop the removal
      find('.vanilla-nested-undo', text: 'Undo').click()
      assert_selector '.vanilla-nested-undo', text: 'Undo', count: 0

      # click to remove for real
      find('.vanilla-nested-remove', text: 'X').click
    end

    sleep(0.5) # undo timeout is configured as 400ms

    assert_selector '.pet-fields', count: 1
    assert_selector '.pet-fields', visible: :hidden, count: 0
    
    # test with fields rendered server side
    within '.pet-fields:nth-of-type(1)' do
      assert_selector '.vanilla-nested-undo', text: 'Undo', count: 0
      find('.vanilla-nested-remove', text: 'X').click

      # added the Undo button
      assert_selector '.vanilla-nested-undo', text: 'Undo', count: 1

      # click undo to stop the removal
      find('.vanilla-nested-undo', text: 'Undo').click()
      assert_selector '.vanilla-nested-undo', text: 'Undo', count: 0

      # click to remove for real
      find('.vanilla-nested-remove', text: 'X').click
    end

    sleep(0.5) # undo timeout is configured as 400ms

    assert_selector '.pet-fields', count: 0
    assert_selector '.pet-fields', visible: :hidden, count: 1
  end
end
