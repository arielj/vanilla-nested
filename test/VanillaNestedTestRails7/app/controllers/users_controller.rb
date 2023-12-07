class UsersController < ApplicationController
  before_action :new_user

  def new
  end

  def new_with_custom_link_tag
  end

  def new_with_undo
  end

  def new_with_attributes_on_link_tag
  end

  def new_using_turbo
    render template: 'users/new', layout: "turbo"
  end

  def create
    User.create(user_params)
  end

  private
  def new_user
    @user = User.new
    @user.pets.build
  end

  def user_params
    params.require(:user).permit(pets_attributes: [:name, :color, {appointments_attributes: [:datetime]}])
  end
end