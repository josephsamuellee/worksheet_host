class Worksheet < ApplicationRecord
  has_many :worksheet_template_versions, dependent: :destroy
  has_many :worksheet_responses, through: :worksheet_template_versions

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :source_filename, presence: true, uniqueness: true

  def latest_template_version
    worksheet_template_versions.order(created_at: :desc, id: :desc).first
  end

  def draft_responses
    worksheet_responses.where(status: "draft").order(updated_at: :desc)
  end

  def completed_responses
    worksheet_responses.where(status: "completed").order(updated_at: :desc)
  end
end
