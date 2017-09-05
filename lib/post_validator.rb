class PostValidator < SimpleDelegator
  include ActiveModel::Validations

  validates_presence_of :title, :description
end
