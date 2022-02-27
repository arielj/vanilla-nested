require "application_system_test_case"

class UndoTest < ApplicationSystemTestCase
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

      # test `hidden` style handling
      assert_selector '[style="color: blue; display: none;"]', count: 1, visible: false
      assert_selector '[style="color: blue; display: inline-block;"]', count: 0, visible: false
      assert_selector '[style="display: none;"]', visible: false

      # click undo to stop the removal
      find('.vanilla-nested-undo', text: 'Undo').click()
      assert_selector '.vanilla-nested-undo', text: 'Undo', count: 0

      # test `after-undo` style handling
      assert_selector '[style="color: blue; display: none;"]', count: 0
      assert_selector '[style="color: blue; display: inline-block;"]', count: 1
      assert_selector '[style="display: none;"]', count: 0

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
