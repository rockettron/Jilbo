class AddColumnsToJavaFiles < ActiveRecord::Migration
  def change
    add_column :java_files, :spens, :integer
    add_column :java_files, :role, :string
    add_column :java_files, :chep_metric, :float
  end
end
