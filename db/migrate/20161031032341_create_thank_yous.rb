class CreateThankYous < ActiveRecord::Migration[5.0]
  def change
    create_table :thank_yous do |t|
      t.references :creator, null: false, index: true
      t.string :first_name, null: false
      t.string :video, null: false

      t.timestamps
    end
  end
end
