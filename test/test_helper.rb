ENV["RAILS_ENV"] ||= "test"
ENV["WORKSHEET_DISABLE_INTAKE_SCANNER"] = "1"
ENV["WORKSHEET_HOST_DATA_ROOT"] ||= File.expand_path("../tmp/worksheet_host_data_test", __dir__)

require_relative "../config/environment"
require "rails/test_help"
require "fileutils"

module ActiveSupport
  class TestCase
    parallelize(workers: 1)

    setup do
      FileUtils.rm_rf(WorksheetHostPaths.data_root)
      WorksheetHostPaths.ensure_directories!
    end

    teardown do
      FileUtils.rm_rf(WorksheetHostPaths.data_root)
    end
  end
end
