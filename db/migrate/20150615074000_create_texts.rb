class CreateTexts < ActiveRecord::Migration
  def change
    create_table :texts do |t|
      t.string :entext

      t.timestamps null: false
    end
  end
end
