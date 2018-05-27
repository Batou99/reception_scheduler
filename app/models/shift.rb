# NOTE: For API simplicity a shift has to begin and end on the same day
# If it spans more than a day it's considered 2 shifts
class Shift < ApplicationRecord
  belongs_to :user

  validate :no_more_than_40_hours_a_week
  validate :no_more_than_8_hours_per_shift
  validate :no_overlapping_shifts
  validate :house_is_open
  validate :start_end_order

  private

  # VALIDATIONS #####################################################################
  def start_end_order
    if finish <= start
      errors.add(:base, "a shift has to finish after it starts")
    end
  end

  def house_is_open
    errors.add(:start,  "house is closed at that time") if is_closed_at?(start)
    errors.add(:finish, "house is closed at that time") if is_closed_at?(finish)
  end

  def no_more_than_8_hours_per_shift
    if (finish - start)/3600 > 8
      errors.add(:base, "shift is too long, you cannot work more than 8 hours per shift")
    end
  end

  def no_overlapping_shifts
    if Shift.where("start < ? AND finish > ?", finish, start).count > 0
      errors.add(:base, "there can not be overlapping shifts")
    end
  end

  def no_more_than_40_hours_a_week
    msg = "you cannot work more than 40 hours a week"
    if overlapping_weeks?
      start_week_duration = (start.end_of_week - start)/3600
      finish_week_duration = (finish.beginning_of_week - finish)/3600

      errors.add(:base, msg) if user.number_of_hours(start) + start_week_duration > 40
      errors.add(:base, msg) if user.number_of_hours(finish) + finish_week_duration > 40
    else
      duration = (finish - start)/3600
      errors.add(:base, msg) if user.number_of_hours(start) + duration > 40
    end
  end
  ###################################################################################

  def overlapping_weeks?
    date_to_week_number(start) != date_to_week_number(finish)
  end

  def is_closed_at?(datetime)
    datetime.strftime( "%H%M%S" ) > "030000" && datetime.strftime( "%H%M%S%N" ) < "070000"
  end

  def date_to_week_number(datetime)
    datetime.strftime("%W").to_i
  end

end
