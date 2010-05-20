class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.references :appliance, :null => false
      t.references :node, :null => true
      t.references :parent, :null => true
      t.string :summary, :limit => 1000, :null => false
      t.string :status, :limit => 20, :null => false
      t.string :previous_status, :limit => 20, :null => true
      t.string :platform, :limit => 20, :null => true
      t.string :arch, :limit => 10, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
