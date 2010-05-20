class CreateAppliances < ActiveRecord::Migration
  def self.up
    create_table :appliances do |t|
      t.string :name, :limit => 100, :null => false
      t.string :status, :limit => 20, :null => false
      t.string :summary, :limit => 500, :null => false
      t.string :config, :limit => 10000, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :appliances
  end
end
