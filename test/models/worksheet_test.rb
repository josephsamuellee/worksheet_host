require "test_helper"

class WorksheetTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "latest_template_version returns newest" do
    worksheet = Worksheet.create!(slug: "a", name: "A", source_filename: "a.txt")
    old = worksheet.worksheet_template_versions.create!(content_hash: "1", source_text: "old")
    travel 1.second do
      worksheet.worksheet_template_versions.create!(content_hash: "2", source_text: "new")
    end

    assert_equal "new", worksheet.latest_template_version.source_text
    assert_not_equal old.id, worksheet.latest_template_version.id
  end
end
