class User < ApplicationRecord
  has_secure_password

  validates_length_of       :password, allow_nil: true, allow_blank: false, minimum: 8, maximum: 48
  validates_confirmation_of :password, allow_nil: true, allow_blank: false

  before_validation do
    self.email    = email.to_s.downcase
    self.username = username.to_s.downcase
  end

  def can_modify_user?(user_id)
    admin || id.to_s == user_id.to_s
  end
end
