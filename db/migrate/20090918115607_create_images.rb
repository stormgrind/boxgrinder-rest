class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.references :definition, :null => false
      t.string :description,  :limit => 1000, :null => false
      t.string :status, :limit => 20, :null => false
      t.string :image_format, :limit => 20, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
