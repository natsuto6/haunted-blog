# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :authenticate_owner!, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    update_params = blog_params
    update_params = update_params.merge(params.require(:blog).permit(:random_eyecatch)) if current_user.premium?

    if @blog.update(update_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])

    raise ActiveRecord::RecordNotFound if @blog.secret && @blog.user != current_user
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret)
  end

  def authenticate_owner!
    raise ActiveRecord::RecordNotFound unless @blog.user == current_user
  end
end
