class CreateDefinitions < ActiveRecord::Migration
  def self.up
    create_table :definitions do |t|
      t.string :description, :limit => 1000, :null => false
      t.string :status, :limit => 50, :null => false
      t.string :file, :limit => 100, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :definitions
  end
end
