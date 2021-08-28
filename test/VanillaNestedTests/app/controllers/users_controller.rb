class UsersController < ApplicationController
  def new
    @user = User.new
    @user.pets.build
  end

  def new_with_custom_link_tag
    @user = User.new
    @user.pets.build
  end
end