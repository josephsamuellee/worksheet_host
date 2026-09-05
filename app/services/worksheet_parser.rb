# Parses UTF-8 worksheet TXT into ordered lines of tokens.
#
# Special constructs:
#   - Two or more consecutive underscores => one :input field
#   - Exact "[ ]" => one :checkbox field
# Everything else is :text.
#
# Field keys are assigned in document order: field_1, field_2, ...
class WorksheetParser
  FIELD_PATTERN = /(__+|\[ \])/

  Line = Struct.new(:line_number, :tokens, keyword_init: true)
  Token = Struct.new(:type, :value, :field_key, keyword_init: true)

  def self.parse(source)
    new(source).parse
  end

  def initialize(source)
    @source = source.to_s
  end

  def parse
    field_index = 0
    lines = @source.split("\n", -1)

    lines.each_with_index.map do |content, index|
      tokens, field_index = tokenize_line(content, field_index)
      Line.new(line_number: index + 1, tokens: tokens)
    end
  end

  private

  def tokenize_line(content, field_index)
    tokens = []
    remainder = content

    while (match = remainder.match(FIELD_PATTERN))
      before = match.pre_match
      tokens << Token.new(type: :text, value: before) unless before.empty?

      field_index += 1
      field_key = "field_#{field_index}"

      if match[0].start_with?("_")
        tokens << Token.new(type: :input, field_key: field_key)
      else
        tokens << Token.new(type: :checkbox, field_key: field_key)
      end

      remainder = match.post_match
    end

    tokens << Token.new(type: :text, value: remainder) unless remainder.empty?
    [ tokens, field_index ]
  end
end
