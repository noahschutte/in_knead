class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :fb_userID, limit: 8, null:false
      t.string :signup_email, null: false
      t.string :current_email
      t.integer :rating, default: 0
      t.integer :reported_requests, array: true, default: []
      t.integer :reported_thank_yous, array: true, default: []
      t.integer :blocked, array: true, default: []

      t.timestamps null: false
    end
  end
end
