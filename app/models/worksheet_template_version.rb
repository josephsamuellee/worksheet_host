class WorksheetTemplateVersion < ApplicationRecord
  belongs_to :worksheet
  has_many :worksheet_responses, dependent: :restrict_with_exception

  validates :content_hash, presence: true
  validates :source_text, presence: true
  validates :content_hash, uniqueness: { scope: :worksheet_id }

  def parsed_lines
    WorksheetParser.parse(source_text)
  end
end
