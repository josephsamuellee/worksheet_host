require "test_helper"

class WorksheetResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    File.write(WorksheetHostPaths.intake_dir.join("car_check.txt"), <<~TXT)
      CAR CHECK

      Date: __________

      [ ] Tires checked
      [ ] Oil checked
      [ ] Lights checked

      Mileage: __________

      Comments: ______________________________
    TXT
    WorksheetImporter.scan!
    @worksheet = Worksheet.find_by!(source_filename: "car_check.txt")
  end

  test "home discovers worksheets" do
    get root_path
    assert_response :success
    assert_select "h2", text: "Car Check"
  end

  test "start response edit autosave refresh jump complete export" do
    post worksheet_responses_path(@worksheet)
    assert_response :redirect
    worksheet_response = WorksheetResponse.order(:id).last
    follow_redirect!
    assert_response :success
    assert_select "input#field_1"
    assert_select "input#field_5"

    patch worksheet_response_path(worksheet_response),
          params: {
            answers: {
              field_1: "Sep 5",
              field_2: true,
              field_3: true,
              field_5: "48231"
            },
            last_edited_field_key: "field_5"
          },
          as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert body["ok"]
    assert_equal "field_5", body["last_edited_field_key"]

    worksheet_response.reload
    assert_equal "Sep 5", worksheet_response.answer_for("field_1")
    assert_equal true, worksheet_response.answer_for("field_2")
    assert_equal "48231", worksheet_response.answer_for("field_5")
    assert_equal "field_5", worksheet_response.last_edited_field_key

    get worksheet_response_path(worksheet_response)
    assert_response :success
    assert_select "input#field_1[value=?]", "Sep 5"
    assert_select "input#field_5[value=?]", "48231"
    assert_select "button", text: "Jump to last edit"
    assert_select "[data-jump-to-last-edit-field-key-value=?]", "field_5"

    patch worksheet_response_path(worksheet_response),
          params: { answers: { field_4: true }, last_edited_field_key: "field_4" },
          as: :json
    assert_equal "field_4", worksheet_response.reload.last_edited_field_key

    patch complete_worksheet_response_path(worksheet_response)
    assert_redirected_to worksheet_response_path(worksheet_response)
    assert worksheet_response.reload.completed?

    get worksheet_response_export_path(worksheet_response)
    assert_response :success
    assert_match %r{\Atext/plain}, response.media_type
    assert_includes response.body, "Date: Sep 5"
    assert_includes response.body, "[x] Tires checked"
    assert_includes response.body, "[x] Oil checked"
    assert_includes response.body, "[x] Lights checked"
    assert_includes response.body, "Mileage: 48231"
    assert_includes response.body, "Comments:"
  end

  test "autosave to missing response is not successful" do
    patch worksheet_response_path(0),
          params: { answers: { field_1: "x" }, last_edited_field_key: "field_1" },
          as: :json
    assert_response :not_found
  end

  test "template change does not affect existing response export" do
    post worksheet_responses_path(@worksheet)
    worksheet_response = WorksheetResponse.order(:id).last

    patch worksheet_response_path(worksheet_response),
          params: { answers: { field_1: "Sep 5" }, last_edited_field_key: "field_1" },
          as: :json

    File.write(WorksheetHostPaths.intake_dir.join("car_check.txt"), "NEW TEMPLATE ONLY: ______\n")
    WorksheetImporter.scan!

    get worksheet_response_export_path(worksheet_response)
    assert_includes response.body, "CAR CHECK"
    assert_includes response.body, "Date: Sep 5"
    assert_not_includes response.body, "NEW TEMPLATE ONLY"
  end
end
