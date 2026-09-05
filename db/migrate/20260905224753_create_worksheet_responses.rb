class CreateWorksheetResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :worksheet_responses do |t|
      t.references :worksheet_template_version, null: false, foreign_key: true,
                   index: { name: "index_responses_on_template_version_id" }
      t.string :status, null: false, default: "draft"
      t.json :answers, null: false, default: {}
      t.string :last_edited_field_key
      t.datetime :last_edited_at

      t.timestamps
    end

    add_index :worksheet_responses, :status
  end
end
