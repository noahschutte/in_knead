class CreateRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :requests do |t|
      t.references :creator, null: false, index: true
      t.integer :pizzas, null: false
      t.string :vendor, null: false
      t.string :video, null: false
      t.integer :donor_id
      t.integer :received, default: 0

      t.timestamps null: false
    end
  end
end
