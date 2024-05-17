class AddTextColorToUserColors < ActiveRecord::Migration[ActiveRecord::VERSION::MAJOR.to_s + '.' + ActiveRecord::VERSION::MINOR.to_s]
  def up
    add_column :user_colors, :text_color_code, :string
  end
  def down
    drop_column :user_colors, :text_color_code
  end
end
