class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.references :definition
      t.string :description
      t.string :status
      t.string :image_format
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
