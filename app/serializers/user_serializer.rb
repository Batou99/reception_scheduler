class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :admin, :created_at, :updated_at, :last_login
end
