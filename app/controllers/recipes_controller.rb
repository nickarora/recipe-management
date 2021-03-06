class RecipesController < ApplicationController
  before_action :set_recipe, only: [:edit, :update, :show, :like]
  before_action :require_user, except: [:show, :index]
  before_action :require_same_user, only: [:edit, :update]

  def index
    if params[:search] && params[:chef]
      @recipes = Recipe.find_by_chef(params[:search], params[:chef]).paginate(page: params[:page], per_page: 3)
    elsif params[:search]
      @recipes = Recipe.find_by_keyword(params[:search]).paginate(page: params[:page], per_page: 3)
    else
      @recipes = Recipe.paginate(page: params[:page], per_page: 3)
    end
  end

  def show
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.chef = current_user

    if @recipe.save
      flash[:success] = "Your recipe was created successfully"
      redirect_to recipes_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      flash[:success] = "Your recipe was updated successfully"
      redirect_to recipe_path(@recipe)
    else
      render :edit
    end
  end

  def like
    like = Like.create(like: params[:like], chef: current_user, recipe: @recipe)

    if like.valid?
      flash[:success] = "Your selection was successful"
    else
      flash[:danger] = "You can only like/dislike a recipe once"
    end

    redirect_to :back
  end

  def search
    @chefs = Chef.all
  end

  private

    def recipe_params
      params.require(:recipe).permit(:name, :summary, :description, :picture)
    end

    def require_same_user
      if current_user != @recipe.chef
        flash[:danger] = logged_in? ? "You can only edit your own recipes" : "You must be logged in to edit your recipes"
        redirect_to root_path
      end
    end

    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

end