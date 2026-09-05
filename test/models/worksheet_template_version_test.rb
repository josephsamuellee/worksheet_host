require "test_helper"

class WorksheetTemplateVersionTest < ActiveSupport::TestCase
  test "parsed_lines delegates to parser" do
    worksheet = Worksheet.create!(slug: "b", name: "B", source_filename: "b.txt")
    version = worksheet.worksheet_template_versions.create!(
      content_hash: "h",
      source_text: "X: __"
    )

    assert_equal :input, version.parsed_lines.first.tokens.last.type
  end
end
