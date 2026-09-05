class CreateWorksheetTemplateVersions < ActiveRecord::Migration[7.2]
  def change
    create_table :worksheet_template_versions do |t|
      t.references :worksheet, null: false, foreign_key: true
      t.string :content_hash, null: false
      t.text :source_text, null: false

      t.timestamps
    end

    add_index :worksheet_template_versions, [ :worksheet_id, :content_hash ],
              unique: true, name: "index_template_versions_on_worksheet_and_hash"
  end
end
