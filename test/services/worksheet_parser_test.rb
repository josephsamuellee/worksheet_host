require "test_helper"

class WorksheetParserTest < ActiveSupport::TestCase
  test "underscores alone become one input" do
    lines = WorksheetParser.parse("__________")
    assert_equal 1, lines.size
    assert_equal [ :input ], lines.first.tokens.map(&:type)
    assert_equal "field_1", lines.first.tokens.first.field_key
  end

  test "static text plus input" do
    lines = WorksheetParser.parse("Name: __________")
    tokens = lines.first.tokens
    assert_equal [ :text, :input ], tokens.map(&:type)
    assert_equal "Name: ", tokens.first.value
    assert_equal "field_1", tokens.last.field_key
  end

  test "two inputs on one line" do
    lines = WorksheetParser.parse("__________ __________")
    tokens = lines.first.tokens
    assert_equal [ :input, :text, :input ], tokens.map(&:type)
    assert_equal "field_1", tokens[0].field_key
    assert_equal "field_2", tokens[2].field_key
  end

  test "two inputs surrounded by static text" do
    lines = WorksheetParser.parse("Name: __________ Date: __________")
    tokens = lines.first.tokens
    assert_equal [ :text, :input, :text, :input ], tokens.map(&:type)
    assert_equal "Name: ", tokens[0].value
    assert_equal " Date: ", tokens[2].value
  end

  test "single checkbox" do
    lines = WorksheetParser.parse("[ ]")
    assert_equal [ :checkbox ], lines.first.tokens.map(&:type)
    assert_equal "field_1", lines.first.tokens.first.field_key
  end

  test "two checkboxes" do
    lines = WorksheetParser.parse("[ ] Foo [ ] Bar")
    tokens = lines.first.tokens
    assert_equal [ :checkbox, :text, :checkbox, :text ], tokens.map(&:type)
    assert_equal " Foo ", tokens[1].value
    assert_equal " Bar", tokens[3].value
  end

  test "mixed input and checkbox" do
    lines = WorksheetParser.parse("Name: ______ [ ] Active")
    tokens = lines.first.tokens
    assert_equal [ :text, :input, :text, :checkbox, :text ], tokens.map(&:type)
    assert_equal "field_1", tokens[1].field_key
    assert_equal "field_2", tokens[3].field_key
  end

  test "blank lines and static-only lines" do
    source = "Title\n\nBody line\n"
    lines = WorksheetParser.parse(source)
    assert_equal 4, lines.size
    assert_equal [ :text ], lines[0].tokens.map(&:type)
    assert_empty lines[1].tokens
    assert_equal "Body line", lines[2].tokens.first.value
    assert_empty lines[3].tokens
  end

  test "punctuation and unicode including traditional chinese" do
    source = "姓名：______（必填）— OK?!"
    tokens = WorksheetParser.parse(source).first.tokens
    assert_equal [ :text, :input, :text ], tokens.map(&:type)
    assert_equal "姓名：", tokens[0].value
    assert_includes tokens[2].value, "必填"
    assert_includes tokens[2].value, "OK?!"
  end

  test "very long lines and consecutive fields" do
    long = "A" * 5000 + "______" + "B" * 5000 + "[ ]" + "______"
    tokens = WorksheetParser.parse(long).first.tokens
    assert_equal [ :text, :input, :text, :checkbox, :input ], tokens.map(&:type)
    assert_equal "field_1", tokens[1].field_key
    assert_equal "field_2", tokens[3].field_key
    assert_equal "field_3", tokens[4].field_key
  end

  test "large worksheet field ordering" do
    source = 100.times.map { |i| "Item #{i}: ______ [ ]" }.join("\n")
    lines = WorksheetParser.parse(source)
    assert_equal 100, lines.size
    keys = lines.flat_map { |l| l.tokens.select { |t| t.field_key }.map(&:field_key) }
    assert_equal 200, keys.size
    assert_equal "field_1", keys.first
    assert_equal "field_200", keys.last
  end

  test "underscore length has no semantic difference" do
    a = WorksheetParser.parse("__").first.tokens
    b = WorksheetParser.parse("_____").first.tokens
    c = WorksheetParser.parse("____________________________________").first.tokens
    assert_equal [ :input ], a.map(&:type)
    assert_equal [ :input ], b.map(&:type)
    assert_equal [ :input ], c.map(&:type)
  end

  test "single underscore is literal text" do
    tokens = WorksheetParser.parse("score_1").first.tokens
    assert_equal [ :text ], tokens.map(&:type)
    assert_equal "score_1", tokens.first.value
  end
end
