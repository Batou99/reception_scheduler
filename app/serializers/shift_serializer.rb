class ShiftSerializer < ActiveModel::Serializer
  attributes :id, :start, :finish, :username

  def username
    object.user.username
  end
end
