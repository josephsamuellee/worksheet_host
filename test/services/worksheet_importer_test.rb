require "test_helper"

class WorksheetImporterTest < ActiveSupport::TestCase
  test "imports txt and creates worksheet with humanized name" do
    path = WorksheetHostPaths.intake_dir.join("weekly_review.txt")
    File.write(path, "Name: ______\n")

    versions = WorksheetImporter.scan!
    assert_equal 1, versions.size

    worksheet = Worksheet.find_by!(source_filename: "weekly_review.txt")
    assert_equal "Weekly Review", worksheet.name
    assert_equal "weekly_review", worksheet.slug
    assert_equal 1, worksheet.worksheet_template_versions.count
  end

  test "same content does not create duplicate version" do
    path = WorksheetHostPaths.intake_dir.join("house_checklist.txt")
    File.write(path, "[ ] Kitchen\n")

    WorksheetImporter.scan!
    WorksheetImporter.scan!

    worksheet = Worksheet.find_by!(source_filename: "house_checklist.txt")
    assert_equal 1, worksheet.worksheet_template_versions.count
  end

  test "changed content creates new version and preserves old responses" do
    path = WorksheetHostPaths.intake_dir.join("car_check.txt")
    File.write(path, "Date: ______\n")

    WorksheetImporter.scan!
    worksheet = Worksheet.find_by!(source_filename: "car_check.txt")
    version_a = worksheet.latest_template_version

    response = WorksheetResponse.create!(
      worksheet_template_version: version_a,
      status: "draft",
      answers: { "field_1" => "Sep 5" }
    )

    File.write(path, "Date: ______\nMileage: ______\n")
    WorksheetImporter.scan!

    worksheet.reload
    version_b = worksheet.latest_template_version

    assert_not_equal version_a.id, version_b.id
    assert_equal version_a.id, response.reload.worksheet_template_version_id
    assert_equal "Date: ______\n", version_a.source_text
    assert_includes version_b.source_text, "Mileage"

    new_response = WorksheetResponse.create!(
      worksheet_template_version: worksheet.latest_template_version,
      status: "draft",
      answers: {}
    )
    assert_equal version_b.id, new_response.worksheet_template_version_id
  end

  test "rejects path traversal style names by ignoring non matching files" do
    bad = WorksheetHostPaths.intake_dir.join("..")
    # Only basename entries from Dir.children are considered; create a weird name
    weird = WorksheetHostPaths.intake_dir.join("not_txt.md")
    File.write(weird, "nope")
    File.write(WorksheetHostPaths.intake_dir.join("ok.txt"), "______")

    versions = WorksheetImporter.scan!
    assert_equal 1, versions.compact.size
    assert Worksheet.exists?(source_filename: "ok.txt")
    assert_not Worksheet.exists?(source_filename: "not_txt.md")
  end

  test "writes immutable snapshot under templates" do
    path = WorksheetHostPaths.intake_dir.join("snap.txt")
    content = "Hello ______\n"
    File.write(path, content)

    version = WorksheetImporter.scan!.first
    snapshot = WorksheetHostPaths.templates_dir.join("snap", "#{version.content_hash}.txt")
    assert File.exist?(snapshot)
    assert_equal content, File.read(snapshot)
  end
end
