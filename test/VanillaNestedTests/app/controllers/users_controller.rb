class UsersController < ApplicationController
  def new
    @user = User.new
    @user.pets.build
  end
end