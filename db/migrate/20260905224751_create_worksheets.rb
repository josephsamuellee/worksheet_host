class CreateWorksheets < ActiveRecord::Migration[7.2]
  def change
    create_table :worksheets do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.string :source_filename, null: false

      t.timestamps
    end

    add_index :worksheets, :slug, unique: true
    add_index :worksheets, :source_filename, unique: true
  end
end
