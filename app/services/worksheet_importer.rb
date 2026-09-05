require "digest"
require "fileutils"

# Discovers .txt worksheets in the intake directory and creates immutable
# template versions when content hashes are new.
class WorksheetImporter
  SAFE_FILENAME = /\A[A-Za-z0-9][A-Za-z0-9._-]*\.txt\z/

  def self.scan!
    new.scan!
  end

  def scan!
    WorksheetHostPaths.ensure_directories!
    Dir.children(WorksheetHostPaths.intake_dir).sort.filter_map do |entry|
      next unless entry.match?(SAFE_FILENAME)

      path = WorksheetHostPaths.intake_dir.join(entry)
      next unless path.file?

      import_file(path)
    end
  end

  def import_file(path)
    basename = File.basename(path.to_s)
    raise ArgumentError, "unsafe filename" unless basename.match?(SAFE_FILENAME)

    source_text = File.read(path, encoding: "UTF-8")
    content_hash = Digest::SHA256.hexdigest(source_text)
    slug = File.basename(basename, ".txt").parameterize(separator: "_")
    slug = "worksheet" if slug.blank?
    name = File.basename(basename, ".txt").tr("_-", " ").squeeze(" ").strip.titleize

    worksheet = Worksheet.find_or_initialize_by(source_filename: basename)
    worksheet.slug = slug if worksheet.new_record?
    worksheet.name = name
    worksheet.source_filename = basename
    worksheet.save!

    existing = worksheet.worksheet_template_versions.find_by(content_hash: content_hash)
    return existing if existing

    version = worksheet.worksheet_template_versions.create!(
      content_hash: content_hash,
      source_text: source_text
    )

    snapshot_dir = WorksheetHostPaths.templates_dir.join(worksheet.slug)
    FileUtils.mkdir_p(snapshot_dir)
    File.write(snapshot_dir.join("#{content_hash}.txt"), source_text)

    version
  end
end
