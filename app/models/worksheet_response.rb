class WorksheetResponse < ApplicationRecord
  STATUSES = %w[draft completed].freeze

  belongs_to :worksheet_template_version
  has_one :worksheet, through: :worksheet_template_version

  validates :status, inclusion: { in: STATUSES }

  before_validation :normalize_answers

  def draft?
    status == "draft"
  end

  def completed?
    status == "completed"
  end

  def answer_for(field_key)
    (answers || {})[field_key.to_s]
  end

  # Merges partial answer updates. Updates last_edited_* only when a value
  # actually changes (not on focus/tap alone).
  def merge_answer_updates!(incoming_answers, last_edited_field_key: nil)
    incoming = (incoming_answers || {}).stringify_keys
    previous = (answers || {}).stringify_keys.dup
    merged = previous.dup
    actually_changed_keys = []

    incoming.each do |key, value|
      normalized = normalize_answer_value(value)
      next if merged[key] == normalized

      merged[key] = normalized
      actually_changed_keys << key
    end

    self.answers = merged

    if last_edited_field_key.present?
      key = last_edited_field_key.to_s
      if actually_changed_keys.include?(key)
        self.last_edited_field_key = key
        self.last_edited_at = Time.current
      end
    elsif actually_changed_keys.any?
      self.last_edited_field_key = actually_changed_keys.last
      self.last_edited_at = Time.current
    end

    save!
  end

  def mark_completed!
    update!(status: "completed")
  end

  private

  def normalize_answers
    self.answers = (answers || {}).stringify_keys
  end

  def normalize_answer_value(value)
    case value
    when true then true
    when false then false
    when "true", "1", "on" then true
    when "false", "0" then false
    when nil then ""
    else
      value.to_s
    end
  end
end
