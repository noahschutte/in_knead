class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :fb_userID, limit: 8
      t.string :first_name, null: false
      t.string :signup_email, null: false
      t.string :current_email, null: false
      t.integer :rating, default: 0

      t.timestamps null: false
    end
  end
end
