class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index, :search, :search_api]

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

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def update
    @recipe = Recipe.find(params[:id])

    if @recipe.user_id == current_user.id
      if @recipe.update(recipe_params)
        redirect_to @recipe
      else
        render 'edit'
      end
    end
  end

  def index
    @recipes = Recipe.all
  end

  def search
    @recipes = []
    @recipes = search_api if params.include? :term
  end

  def search_api
    limit = params[:limit] || 10
    page = params[:page] || 1
    offset = ((page - 1) * limit) || 0
    term = params[:term] || nil
    Recipe.where('title LIKE ? '\
                 'OR content LIKE ? '\
                 'OR ingredients LIKE ? ',
                 "%#{term}%",
                 "%#{term}%",
                 "%#{term}%")
                   .limit(limit)
                   .offset(offset) if term
  end

  private
  def recipe_params
    params.require(:recipe).merge!(user_id: current_user.id, created_at: Time.now, updated_at: Time.now).permit(:title, :content, :ingredients, :updated_at, :created_at, :user_id, :source)
  end
end
