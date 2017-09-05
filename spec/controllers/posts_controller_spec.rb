require 'rails_helper'

RSpec.describe PublicApi::PostsController, type: :controller do
  RSpec::Matchers.define_negated_matcher :not_change, :change

  before(:each) do
    # потому что use_transactional_fixtures = false
    Post.destroy_all
  end

  def get_body response
    JSON.parse(response.body)
  end

  def add_rating post_id:, rating_value:
    put :rating_update,
      params: {'id' => post_id, 'rating_value' => rating_value},
      format: :json
  end

  let(:user) { create :user }

  let(:params) do
    {
      'title' => 'Hello',
      'description' => 'Text',
      'ip' => '123.123.123.123',
      'login' => user.login
    }
  end

  describe 'Api постов' do
    it 'создание поста' do

      expect {
        post :create,
        params: params,
        format: :json
      }.to change(Post, :count)
      expect(get_body(response)).to include({'title' => params['title'], 'description' => params['description']})
      expect(response).to have_http_status(:ok)

      # пользователь с таким именем уже существует
      expect {
        post :create,
        params: params.merge!({'description' => 'Text2'}),
        format: :json
      }.to change(Post, :count).and not_change(User, :count)

      # новый пользователь
      expect {
        post :create,
        params: params.merge!({'login' => 'seconduser'}),
        format: :json
      }.to change(Post, :count).and change(User, :count)
    end

    it 'при создании переданы не все параметры' do
      expect {
        post :create,
        params: params.merge({'login' => ''}),
        format: :json
      }.to_not change(Post, :count)
      expect(get_body(response)).to eq ['Login %s' % I18n.t('errors.messages.blank')]
      expect(response).to have_http_status(:unprocessable_entity)

      expect {
        post :create,
        params: params.merge({'title' => '', 'description' => ''}),
        format: :json
      }.to_not change(Post, :count)
      expect(get_body(response)).to include('Title %s' % I18n.t('errors.messages.blank'), 'Description %s' % I18n.t('errors.messages.blank'))
      expect(response).to have_http_status(:unprocessable_entity)

      expect {
        post :create,
        params: params.merge({'ip' => ''}),
        format: :json
      }.to change(Post, :count)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Api оценок' do

    it 'поставить оценку' do
      post = create :post, user_id: user.id

      # поста не существует
      expect {
        add_rating post_id: 999, rating_value: 4
      }.to_not change(PostRating, :count)
      expect(response).to have_http_status(:unprocessable_entity)

      # оценка корректна
      expect {
        add_rating post_id: post.id, rating_value: 4
        add_rating post_id: post.id, rating_value: 3
        add_rating post_id: post.id, rating_value: 1
      }.to change(PostRating, :count).by(3)
      expect(response).to have_http_status(:ok)
      expect(get_body(response)).to eq({'avg_rating' => '2.67'})

      # оценка за пределами допустимых значений
      expect {
        add_rating post_id: post.id, rating_value: 123
      }.to_not change(PostRating, :count)
      expect(response).to have_http_status(:unprocessable_entity)

      # оценка не является числом
      expect {
        add_rating post_id: post.id, rating_value: 'asd'
      }.to_not change(PostRating, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'рейтинг постов' do
      post1 = create :post, user_id: user.id
      add_rating post_id: post1.id, rating_value: 1
      add_rating post_id: post1.id, rating_value: 2

      post2 = create :post, user_id: user.id
      add_rating post_id: post2.id, rating_value: 4
      add_rating post_id: post2.id, rating_value: 3

      post3 = create :post, user_id: user.id

      # рейтинг в нужном порядке
      expect(get_body((get :rating_top))).to eq({'posts' => [[post2.title, post2.description], [post1.title, post1.description]]})
    end

    it 'с одного IP постили несколько разных пользователей' do
      # первый постил только c одного IP
      create :post, user_id: user.id, ip: '111.111.111.111'
      create :post, user_id: user.id, ip: '111.111.111.111'

      user2 = create :user
      create :post, user_id: user2.id, ip: '222.222.222.222'

      # первый и второй постили с разных IP-шников поэтому список пуст
      response = get_body(get :ips_different_authors)
      expect(response).to eq []

      # третий постил с IP-шника второго
      user3 = create :user
      create :post, user_id: user3.id, ip: '222.222.222.222'

      # четвертый без IP
      user4 = create :user
      create :post, user_id: user4.id, ip: ''

      response = get_body(get :ips_different_authors)
      expect(response[0]['users_login']).to eq [user2.login, user3.login]

      # пользователь 4 добавил пост с того же IP что и второй и третий
      create :post, user_id: user4.id, ip: '222.222.222.222'
      response = get_body(get :ips_different_authors)
      expect(response[0]['users_login']).to eq [user2.login, user3.login, user4.login]
    end
  end

end
