class CreateHalsteds < ActiveRecord::Migration
  def change
    create_table :halsteds do |t|
    	t.string :path_file
    	t.text :content
    	t.text :operators
    	t.text :operands 
    	t.integer :uniq_operators
    	t.integer :uniq_operands
    	t.integer :count_operators
    	t.integer :count_operands
    end
  end
end
