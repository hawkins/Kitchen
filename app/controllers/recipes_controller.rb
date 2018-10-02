class RecipesController < ApplicationController
  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      redirect_to @recipe
    else
      render 'new'
    end
  end

  private
  def recipe_params
    params.require(:recipe).merge!(user_id: current_user.id, created_at: Time.now, updated_at: Time.now).permit(:title, :content, :ingredients, :updated_at, :created_at, :user_id)
  end
end
