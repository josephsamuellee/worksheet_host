# Periodically scans the intake directory for new or changed worksheet TXT files.
# A simple sleep loop is used (no Redis/Sidekiq/filesystem watcher).
class WorksheetIntakeScanner
  class << self
    def start!
      return if @started

      @started = true
      interval = Rails.application.config.x.worksheet_host.intake_scan_interval
      interval = 45 if interval.nil? || interval <= 0

      Thread.new do
        Thread.current.name = "worksheet-intake-scanner"
        loop do
          begin
            WorksheetImporter.scan!
          rescue StandardError => e
            Rails.logger.error("[WorksheetIntakeScanner] #{e.class}: #{e.message}")
          end
          sleep interval
        end
      end
    end

    def reset_for_tests!
      @started = false
    end
  end
end
