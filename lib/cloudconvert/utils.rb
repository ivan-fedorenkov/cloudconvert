module Cloudconvert
  module Utils

    def self.work_with_possible_archive(converted_file, expected_format)
      if File.extname(converted_file) == ".zip"
        Zip::File.open(converted_file) do |zipfile|
          # Remove all unrelated files (files that are not in expected format)
          entries = zipfile.entries.delete_if { |e| not e.name.end_with?(expected_format) }
          entries.each do |part|
            extracted_part_file = Tempfile.new("extracted_part_file")
            part.extract(extracted_part_file)
            yield extracted_part_file
          end
        end
      else
        yield converted_file
      end
    end

  end
end