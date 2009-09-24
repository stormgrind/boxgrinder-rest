class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :description
      t.string :status
      t.string :action
      t.string :params
      t.integer :image_id
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end