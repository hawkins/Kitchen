class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])

    @recipes = Recipe.where(:user_id => params[:id]).reverse
  end

end
