class CreateAnons < ActiveRecord::Migration[5.0]
  def change
    create_table :anons do |t|

      t.timestamps
    end
  end
end
