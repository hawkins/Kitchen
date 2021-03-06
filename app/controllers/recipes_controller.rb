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
    tags = @recipe.tags.split(',')
    tags.map!(&:strip)
    tags.uniq!
    @recipe.tags = tags.join(',')

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
    redirect_to action: 'search'
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
    term = URI.decode term
    if term
      Recipe.where('lower(tags) LIKE ? ', "%#{term.downcase}%")
            .limit(limit)
            .offset(offset)
    end
  end

  def generate_tag_css(tag)
    bg_colors = generate_tag_color tag
    background_color = format('#%02X%02X%02X', bg_colors[0], bg_colors[1], bg_colors[2])

    fg_colors = generate_tag_text_color bg_colors
    color = format('#%02X%02X%02X', fg_colors[0], fg_colors[1], fg_colors[2])

    "color: #{color};\nbackground-color: #{background_color};"
  end
  helper_method :generate_tag_css

  private

  def recipe_params
    created_at = if !@recipe.nil?
                   @recipe.created_at
                 else
                   Time.now
                 end

    params.require(:recipe)
          .merge!(user_id: current_user.id,
                  created_at: created_at,
                  updated_at: Time.now)
          .permit(:title,
                  :content,
                  :ingredients,
                  :notes,
                  :updated_at,
                  :created_at,
                  :user_id,
                  :tags,
                  :source)
  end

  def get_specific_tag_color(tag)
    case tag.downcase
    when 'christmas'
      [154, 205, 50]
    when 'easy'
      [50, 205, 50]
    when 'medium'
      [255, 165, 0]
    when 'hard'
      [255, 0, 0]
    end
  end

  def color_high(random)
    (random.rand * 64) + 192
  end

  def color_middle(random)
    (random.rand * 64) + 128
  end

  def color_low(random)
    random.rand * 64
  end

  def color_high_low(random)
    high_bit = (random.rand + 0.5).to_i
    random.rand * 64 + (128 * high_bit)
  end

  def color_random(random)
    random.rand * 256
  end

  def generate_tag_color(tag)
    # Short-circuit custom tag names
    specific = get_specific_tag_color tag
    return specific unless specific.nil?

    # Randomly generate a color using a custom high-low selection strategy
    seed = tag.bytes.map(&:to_i).reduce(0, :+)
    r = Random.new(seed)
    a = (r.rand * 64).to_i * 4
    b = (r.rand * 64).to_i * 4

    # TODO: DRY
    if a >= 192 && b >= 192
      # high high
      c = color_low(r)
    elsif (a >= 192 && b >= 64 && b < 192) || (a >= 64 && a < 192 && b >= 192)
      # high medium
      c = color_random(r)
    elsif (a >= 192 && b < 64) || (a < 64 && b >= 192)
      # high low
      c = color_high_low(r)
    elsif a >= 64 && a < 192 && b >= 64 && b < 192
      # middle middle
      c = color_high_low(r)
    elsif (a >= 64 && a < 192 && b < 64) || (a < 64 && b >= 64 && b < 192)
      # middle low
      c = color_random(r)
    else
      # low low
      c = color_high(r)
    end

    # Decide order

    d = r.rand * 3
    colors = [a, b, c]
    colors.shuffle!(random: r)

    colors
  end

  def generate_tag_text_color(colors)
    # See http://www.w3.org/TR/AERT#color-contrast
    o = ((((colors[0] * 299) + (colors[1] * 587) + (colors[2] * 114)) / 1000) + 0.5).to_i
    if o > 125
      [0, 0, 0]
    else
      [255, 255, 255]
    end
  end
end
