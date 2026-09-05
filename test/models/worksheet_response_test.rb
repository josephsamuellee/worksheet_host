require "test_helper"

class WorksheetResponseTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @worksheet = Worksheet.create!(slug: "demo", name: "Demo", source_filename: "demo.txt")
    @version = @worksheet.worksheet_template_versions.create!(
      content_hash: "abc",
      source_text: "Name: ______\n[ ] Active\n"
    )
    @response = WorksheetResponse.create!(
      worksheet_template_version: @version,
      status: "draft",
      answers: {}
    )
  end

  test "merge persists string and checkbox answers" do
    @response.merge_answer_updates!(
      { "field_1" => "Joseph", "field_2" => true },
      last_edited_field_key: "field_2"
    )

    @response.reload
    assert_equal "Joseph", @response.answer_for("field_1")
    assert_equal true, @response.answer_for("field_2")
    assert_equal "field_2", @response.last_edited_field_key
    assert_not_nil @response.last_edited_at
  end

  test "last edited only updates when value actually changes" do
    @response.merge_answer_updates!({ "field_1" => "A" }, last_edited_field_key: "field_1")
    edited_at = @response.last_edited_at

    travel 1.minute do
      @response.merge_answer_updates!({ "field_1" => "A" }, last_edited_field_key: "field_1")
    end

    assert_equal edited_at.to_i, @response.reload.last_edited_at.to_i
    assert_equal "field_1", @response.last_edited_field_key
  end

  test "mark complete without validation" do
    @response.mark_completed!
    assert @response.reload.completed?
  end
end
