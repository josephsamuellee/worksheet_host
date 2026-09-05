class ExportsController < ApplicationController
  def show
    worksheet_response = WorksheetResponse.find(params[:worksheet_response_id])
    version = worksheet_response.worksheet_template_version
    text = WorksheetExporter.export(version.source_text, worksheet_response.answers)

    WorksheetHostPaths.ensure_directories!
    export_name = "#{worksheet_response.worksheet.slug}_response_#{worksheet_response.id}.txt"
    export_path = WorksheetHostPaths.exports_dir.join(export_name)
    File.write(export_path, text)

    send_data text,
              filename: export_name,
              type: "text/plain; charset=utf-8",
              disposition: "attachment"
  end
end
