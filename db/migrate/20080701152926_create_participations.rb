class CreateParticipations < ActiveRecord::Migration
  def self.up
    create_table :participations do |t|
      t.integer :user_id, :article_id
      t.string  :role, :permission, :note
      t.timestamps
    end
    add_index :participations, [:article_id, :user_id] 
    add_index :participations, :user_id
  end

  def self.down
    drop_table :participations
  end
end