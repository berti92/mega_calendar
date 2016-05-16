class CreateCalendarEvents < ActiveRecord::Migration
  def up
    create_table :calendar_events do |t|
      t.datetime :start
      t.datetime :end
      t.integer :user_id
      t.string :title
    end
  end
  def down
    drop_table(:calendar_events)
  end
end
