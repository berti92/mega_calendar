class CreateHolidays < ActiveRecord::Migration
  def up
    create_table :holidays do |t|
      t.datetime :start
      t.datetime :end
      t.integer :user_id
      t.integer :reason, default: 1
    end
  end
  def down
    drop_table(:holidays)
  end
end
