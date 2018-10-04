class VisitorsController < ApplicationController
  def index
    @recipes = Recipe.last(5)
  end
end
