class CreateUserFilters < ActiveRecord::Migration
  def up
    create_table :user_filters do |t|
      t.integer :user_id
      t.string :filter_name
      t.binary :filter_code
    end
  end
  def down
    drop_table(:user_filters)
  end
end
