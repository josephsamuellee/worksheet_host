class WorksheetResponsesController < ApplicationController
  before_action :set_worksheet, only: [ :create ]
  before_action :set_worksheet_response, only: [ :show, :update, :complete ]

  def create
    version = @worksheet.latest_template_version
    unless version
      redirect_to root_path, alert: "No template version available for this worksheet."
      return
    end

    worksheet_response = WorksheetResponse.create!(
      worksheet_template_version: version,
      status: "draft",
      answers: {}
    )

    redirect_to worksheet_response_path(worksheet_response)
  end

  def show
    @worksheet = @worksheet_response.worksheet
    @version = @worksheet_response.worksheet_template_version
    @lines = @version.parsed_lines
  end

  def update
    raw_answers = params[:answers]
    answers =
      case raw_answers
      when ActionController::Parameters then raw_answers.permit!.to_h
      when Hash then raw_answers
      else {}
      end
    last_key = params[:last_edited_field_key].presence

    @worksheet_response.merge_answer_updates!(answers, last_edited_field_key: last_key)

    respond_to do |format|
      format.json do
        render json: {
          ok: true,
          status: @worksheet_response.status,
          last_edited_field_key: @worksheet_response.last_edited_field_key,
          last_edited_at: @worksheet_response.last_edited_at,
          updated_at: @worksheet_response.updated_at
        }
      end
      format.html { redirect_to worksheet_response_path(@worksheet_response) }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.json { render json: { ok: false, error: e.message }, status: :unprocessable_entity }
      format.html { redirect_to worksheet_response_path(@worksheet_response), alert: e.message }
    end
  end

  def complete
    @worksheet_response.mark_completed!
    redirect_to worksheet_response_path(@worksheet_response), notice: "Marked complete."
  end

  private

  def set_worksheet
    @worksheet = Worksheet.find(params[:worksheet_id])
  end

  def set_worksheet_response
    @worksheet_response = WorksheetResponse.find(params[:id])
  end
end
