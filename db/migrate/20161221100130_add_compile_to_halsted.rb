class AddCompileToHalsted < ActiveRecord::Migration
  def change
    add_column :halsteds, :compile, :boolean
  end
end
