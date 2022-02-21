require "application_system_test_case"

class HtmlTagTest < ApplicationSystemTestCase
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

  test "accepts attributes for the custom tags for link_to_add/remove_nested" do
    visit new_with_attributes_on_link_tag_users_path

    # 'add' wrapper has a title attribute
    # it also preserves data and classes attributes
    # tag_attributes: {title: "Add Pet", data: {some_data: 'is preserved'}
    find('.vanilla-nested-add[title="Add Pet"][data-some-data="is preserved"]', text: '+').click

    # wrapper has a tabindex
    # tag: 'button', tag_attributes: {tabindex: "10"}
    within '.pet-fields:nth-of-type(1)' do
      find('button.vanilla-nested-remove[tabindex="10"]', text: 'X').click
    end
  end
end
