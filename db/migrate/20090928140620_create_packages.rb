class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.references :image
      t.string :description
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :packages
  end
end
