class CreateThankYous < ActiveRecord::Migration[5.0]
  def change
    create_table :thank_yous do |t|

      t.timestamps
    end
  end
end
