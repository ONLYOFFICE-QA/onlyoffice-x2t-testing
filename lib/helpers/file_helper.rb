# frozen_string_literal: true

class FileHelper
  class << self
    # Check if file exists by his path
    # @param [String] file_path path to file
    # @return [true. false]
    def file_exist?(file_path)
      File.exist?(file_path)
    end

    def delete_directory(path)
      FileUtils.rm_rf(path, secure: true)
    end

    def copy_file(file_path, destination)
      FileUtils.mkdir_p(destination) unless File.directory?(destination)
      FileUtils.copy(file_path, destination)
    end

    def move_file(file_path, destination)
      FileUtils.mkdir_p(destination) unless File.directory?(destination)
      FileUtils.move(file_path, destination)
    end

    # Get file size in bytes
    # @param [String] file_name name of file
    # @return [Integer] size of file in bytes
    def file_size(file_name)
      size = File.size?(file_name)
      size = 0 if size.nil?
      LoggerHelper.print_to_log("Size of file '#{file_name}' is #{size}")
      size
    end
  end
end
