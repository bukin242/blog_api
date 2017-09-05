class RatingService

  RATING_RANGE = 1..5

  def initialize params
    @params = params
    @errors = []
    @instance = nil
    @avg_rating = nil
  end

  def rating_top
    limit = (@params[:top] ? @params[:top].to_i : 100)
    posts = Post.rating_top.limit(limit).pluck(:title, :description)
    (posts.present? ? {posts: posts} : {})
  end

  def rating_value
    @params[:rating_value].to_i
  end

  def valid?
    if not post
      @errors << 'Post not defined'
    elsif not RATING_RANGE.cover?(rating_value)
      @errors << 'Rating value corrupt'
    end

    @errors.blank?
  end

  def errors
    @errors
  end

  def post
    @instance ||= Post.where(id: @params[:id].to_i).first
  end

  def save
    if valid?
      @avg_rating = PostRating.transaction(isolation: :serializable) do
        PostRating.create post_id: post.id, rating_value: rating_value

        new_rating = PostRating.where(post_id: post.id).average(:rating_value).try(:round, 2)
        post.update_attribute :avg_rating, new_rating

        new_rating
      end
    end
  end

  def attributes
    (@avg_rating ? {avg_rating: @avg_rating} : {})
  end

end
