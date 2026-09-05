require "test_helper"

class WorksheetExporterTest < ActiveSupport::TestCase
  test "exports strings and checkboxes" do
    source = <<~TXT
      CAR CHECK

      Date: __________

      [ ] Tires checked
      [ ] Oil checked
      [ ] Lights checked

      Mileage: __________

      Comments: ______________________________
    TXT

    answers = {
      "field_1" => "Sep 5",
      "field_2" => true,
      "field_3" => true,
      "field_4" => true,
      "field_5" => "48231"
    }

    exported = WorksheetExporter.export(source, answers)

    assert_includes exported, "Date: Sep 5"
    assert_includes exported, "[x] Tires checked"
    assert_includes exported, "[x] Oil checked"
    assert_includes exported, "[x] Lights checked"
    assert_includes exported, "Mileage: 48231"
    assert_includes exported, "Comments:"
    assert_includes exported, "CAR CHECK"
  end

  test "unchecked checkbox stays empty brackets" do
    exported = WorksheetExporter.export("[ ] Foo", { "field_1" => false })
    assert_equal "[ ] Foo", exported
  end

  test "multiple fields per line and unicode" do
    source = "姓名：______ [ ] 完成"
    exported = WorksheetExporter.export(source, { "field_1" => "王小明", "field_2" => true })
    assert_equal "姓名：王小明 [x] 完成", exported
  end

  test "preserves blank lines" do
    source = "A: __\n\nB: __"
    exported = WorksheetExporter.export(source, { "field_1" => "1", "field_2" => "2" })
    assert_equal "A: 1\n\nB: 2", exported
  end
end
