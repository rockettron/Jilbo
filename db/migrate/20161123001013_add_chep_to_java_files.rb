class AddChepToJavaFiles < ActiveRecord::Migration
  def change
    add_column :java_files, :chep, :boolean, default: false
  end
end
