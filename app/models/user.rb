class User < ApplicationRecord
  has_secure_password

  has_many :shifts

  validates_length_of       :password, allow_nil: true, allow_blank: false, minimum: 8, maximum: 48
  validates_confirmation_of :password, allow_nil: true, allow_blank: false
  validates_presence_of     :email,    unique: true
  validates_presence_of     :username, unique: true

  before_validation do
    self.email    = email.to_s.downcase
    self.username = username.to_s.downcase
  end

  def can_modify_user?(user_id)
    admin || id.to_s == user_id.to_s
  end

  def number_of_hours(datetime)
    week_start = datetime.beginning_of_week
    week_end   = datetime.end_of_week

    shifts.where("start <= ? AND finish >= ?", week_end, week_start).sum do |shift|
      # Intersect the shift with the week boundaries
      in_week_start  = [week_start, shift.start].max
      in_week_finish = [week_end,   shift.finish].min

      (in_week_finish - in_week_start)/3600
    end.round(2)
  end
end
