class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.references :image, :null => false
      t.string :description, :limit => 1000, :null => false
      t.string :status, :null => false
      t.string :package_format, :limit => 50, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :packages
  end
end
