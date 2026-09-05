module WorksheetHostPaths
  module_function

  def data_root
    root = ENV["WORKSHEET_HOST_DATA_ROOT"].presence
    root ||= if Rails.env.production?
      "/mnt/raid1/data/worksheet_host"
    else
      Rails.root.join("tmp/worksheet_host_data").to_s
    end
    Pathname.new(root)
  end

  def intake_dir
    data_root.join("intake")
  end

  def templates_dir
    data_root.join("templates")
  end

  def exports_dir
    data_root.join("exports")
  end

  def db_dir
    data_root.join("db")
  end

  def ensure_directories!
    [ intake_dir, templates_dir, exports_dir, db_dir ].each do |dir|
      FileUtils.mkdir_p(dir)
    end
  end
end

Rails.application.config.x.worksheet_host = ActiveSupport::OrderedOptions.new
Rails.application.config.x.worksheet_host.intake_scan_interval = ENV.fetch("WORKSHEET_INTAKE_SCAN_INTERVAL", "45").to_i

Rails.application.config.after_initialize do
  WorksheetHostPaths.ensure_directories! unless Rails.env.test?

  unless Rails.env.test? || ENV["WORKSHEET_DISABLE_INTAKE_SCANNER"] == "1"
    WorksheetIntakeScanner.start!
  end
end
