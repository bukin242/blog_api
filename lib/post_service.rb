class PostService

  def initialize params
    @params = params
    @instance = nil
    @errors = []
  end

  def create_post_by_user user_id
    attributes = @params.slice(:title, :description, :ip)
    new_post = Post.new(attributes.merge!(user_id: user_id))
    @instance = PostValidator.new(new_post)
  end

  def create_post
    login = @params.delete(:login)
    if login.blank?
      @errors << 'Login %s' % I18n.t('errors.messages.blank')
      return nil
    end

    user = User.find_or_create_by(login: login)

    create_post_by_user user.id
  end

  def post
    @instance
  end

  def valid?
    if not post
      return false
    elsif not post.valid?
      @errors += post.errors.full_messages
    end

    @errors.blank?
  end

  def errors
    @errors
  end

  def save
    if valid?
      post.save!(validate: false)
    end
  end

  def attributes
    post.attributes.slice('title', 'description') || {}
  end

  def self.ips_different_authors
    users_login = User.all.pluck(:id, :login).to_h

    authors = UserPostIp.where('array_length(users_ids, 1) > 1').map do |post_ip|
      logins = post_ip.users_ids.map!{ |user_id| users_login[user_id] }
      {ip: post_ip.ip, users_login: logins}
    end
  end

end
