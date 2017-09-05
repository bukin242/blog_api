class PublicApi::PostsController < ApplicationController

  def create
    post = PostService.new(post_params)
    post.create_post

    if post.save
      render json: post.attributes, status: :ok
    else
      render json: post.errors, status: :unprocessable_entity
    end
  end

  def rating_top
    posts = RatingService.new(params.permit(:top)).rating_top
    render json: posts
  end

  def rating_update
    rating = RatingService.new(rating_params)

    if rating.save
      render json: rating.attributes, status: :ok
    else
      render json: rating.errors, status: :unprocessable_entity
    end
  end

  def ips_different_authors
    authors = PostService.ips_different_authors
    render json: authors
  end

  private

  def post_params
    params.permit(:title, :description, :ip, :login)
  end

  def rating_params
    params.permit(:id, :rating_value)
  end
end
