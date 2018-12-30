# frozen_string_literal: true

class RecipesController < ApplicationController
  before_action :authenticate_user!, except: %i[show index search search_api search_tags_api]

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
    @recipes = search_tags_api if params.include? :tag
  end

  def search_api
    limit = params[:limit] || 10
    page = params[:page] || 1
    offset = ((page - 1) * limit) || 0
    term = params[:term] || nil
    if term
      Recipe.where('lower(title) LIKE ? '\
                   'OR lower(content) LIKE ? '\
                   'OR lower(ingredients) LIKE ? '\
                   'OR lower(tags) LIKE ?',
                   "%#{term.downcase}%",
                   "%#{term.downcase}%",
                   "%#{term.downcase}%",
                   "%#{term.downcase}%")
            .limit(limit)
            .offset(offset)
    end
  end

  def search_tags_api
    limit = params[:limit] || 10
    page = params[:page] || 1
    offset = ((page - 1) * limit) || 0
    term = params[:tag] || nil
    if term
      Recipe.where('lower(tags) LIKE ? ', "%#{term.downcase}%")
            .limit(limit)
            .offset(offset)
    end
  end

  private

  def recipe_params
    created_at = if !@recipe.nil?
                   puts 'existing recipe'
                   @recipe.created_at
                 else
                   puts 'new recipe'
                   Time.now
                 end

    params.require(:recipe)
      .merge!(user_id: current_user.id,
              created_at: created_at,
              updated_at: Time.now)
      .permit(:title,
              :content,
              :ingredients,
              :updated_at,
              :created_at,
              :user_id,
              :tags,
              :source)
  end
end
