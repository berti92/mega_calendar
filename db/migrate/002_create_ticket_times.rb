class CreateTicketTimes < ActiveRecord::Migration
  def up
    create_table :ticket_times do |t|
      t.time :time_begin
      t.time :time_end
      t.integer :issue_id
    end
  end
  def down
    drop_table(:ticket_times)
  end
end
