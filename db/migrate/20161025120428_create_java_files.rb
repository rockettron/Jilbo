class CreateJavaFiles < ActiveRecord::Migration
  def change
    create_table :java_files do |t|
      t.string :path_file
    	t.text :content
    	t.boolean :compile
    	t.integer :count_operators
    	t.float :cl
    	t.integer :deepness
      t.timestamps null: false	
    end
  end
end
