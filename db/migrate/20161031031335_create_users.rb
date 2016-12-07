class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :fb_userID, limit: 8, null:false
      t.string :signup_email
      t.string :current_email
      t.integer :rating, default: 0

      t.timestamps null: false
    end
  end
end
