class WorksheetsController < ApplicationController
  def index
    WorksheetImporter.scan!
    @worksheets = Worksheet.includes(:worksheet_template_versions).order(:name)
  end
end
