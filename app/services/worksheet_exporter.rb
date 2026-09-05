# Reconstructs plain text from an immutable template version and response answers.
class WorksheetExporter
  def self.export(source_text, answers = {})
    new(source_text, answers).export
  end

  def initialize(source_text, answers = {})
    @source_text = source_text.to_s
    @answers = (answers || {}).stringify_keys
  end

  def export
    lines = WorksheetParser.parse(@source_text)

    lines.map do |line|
      line.tokens.map { |token| render_token(token) }.join
    end.join("\n")
  end

  private

  def render_token(token)
    case token.type
    when :text
      token.value
    when :input
      @answers.fetch(token.field_key, "").to_s
    when :checkbox
      checked = ActiveModel::Type::Boolean.new.cast(@answers[token.field_key])
      checked ? "[x]" : "[ ]"
    else
      ""
    end
  end
end
