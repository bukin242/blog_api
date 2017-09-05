require 'rails_helper'
RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

RSpec.describe UserPostIp, type: :model do

  before(:each) do
    # потому что use_transactional_fixtures = false
    described_class.destroy_all
  end

  describe 'IP пользователей которые размещали посты логгируются' do
    let(:user1) { create :user }
    let(:user2) { create :user }
    let(:user3) { create :user }

    it 'триггер add_user_post() добавляет пользователя в поле users_ids' do
      create :post, user_id: user1.id, ip: '111.111.111.111'
      create :post, user_id: user1.id, ip: '111.111.111.111'

      expect(described_class.first.users_ids).to eq [user1.id]

      create :post, user_id: user2.id, ip: '111.111.111.111'
      create :post, user_id: user3.id, ip: '222.222.222.222'
      expect(described_class.first.users_ids).to eq [user1.id, user2.id]
    end

    it 'триггер del_user_post() удаляет пользователя' do
      post1 = create :post, user_id: user1.id, ip: '111.111.111.111'
      post2 = create :post, user_id: user1.id, ip: '111.111.111.111'
      post1.destroy

      # т.к у пользователя есть еще посты с этим же IP он не удалится из лога
      expect(described_class.first.users_ids).to eq [user1.id]

      post2.destroy
      expect(described_class.first.users_ids).to eq []
    end
  end
end
