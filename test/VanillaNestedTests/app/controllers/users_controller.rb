class UsersController < ApplicationController
  before_action :new_user
  def new
  end

  def new_with_custom_link_tag
  end

  def new_with_undo
  end

  private
  def new_user
    @user = User.new
    @user.pets.build
  end
end