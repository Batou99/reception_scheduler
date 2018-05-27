class CreateShifts < ActiveRecord::Migration[5.1]
  def change
    create_table :shifts do |t|
      t.integer  :user_id
      t.datetime :start
      t.datetime :finish

      t.timestamps
    end

    add_index :shifts, :user_id
    add_index :shifts, :start
    add_index :shifts, :finish
  end
end
