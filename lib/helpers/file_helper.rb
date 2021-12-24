# frozen_string_literal: true

class FileHelper
  class << self
    # Return name of file from full path
    # @param [true, false] keep_extension keep extension in result?
    # @return [Sting] name of file, with extension or not
    def get_filename(file_path, keep_extension = true)
      name = Pathname.new(file_path).basename
      name = File.basename(name, File.extname(name)) unless keep_extension
      name.to_s
    end

    def file_exists(file_path)
      warn '[DEPRECATION] Use file_exist? instead'
      File.exist?(file_path)
    end

    # Check if file exists by his path
    # @param [String] file_path path to file
    # @return [true. false]
    def file_exist?(file_path)
      File.exist?(file_path)
    end

    def delete_directory(path)
      FileUtils.rm_rf(path) if Dir.exist?(path)
    end

    def create_folder(path)
      FileUtils.mkdir_p(path) unless File.directory?(path)
    rescue Errno::EEXIST
      true
    end

    def init_download_directory
      directory = '/tmp/webdriver_downloads/' + StringHelper.generate_random_string
      delete_directory(directory)
      create_folder(directory)
      directory
    end

    def wait_file_to_download(path, timeout = 300)
      timer = 0
      LoggerHelper.print_to_log("Start waiting to download file: #{path}")
      until File.exist?(path) && !File.exist?(path + '.part')
        LoggerHelper.print_to_log("Waiting for #{timer} seconds from #{timeout}")
        sleep 1
        timer += 1
        raise "Timeout #{timeout} for downloading file #{path} is exceed" if timer > timeout
      end
      sleep 1
      timer <= timeout
    end

    def read_file_to_string(file_name)
      result_string = ''
      raise 'File not found: ' + file_name.to_s unless File.exist?(file_name)

      File.open(file_name, 'r') do |infile|
        while (line = infile.gets)
          result_string += line
        end
      end
      result_string
    end

    def read_array_from_file(file_name)
      result_array = []
      return [] unless File.exist?(file_name)

      File.open(file_name, 'r') do |infile|
        while (line = infile.gets)
          result_array << line.sub("\n", '')
        end
      end
      result_array
    end

    def get_file_name_without_extension(file)
      File.basename(file).chomp(File.extname(file))
    end

    def get_mime(file)
      mime = `file --mime -b "#{file}"`.delete("\n")
      mime
    end

    def get_mime_by_extension(mime_type)
      file = "#{ENV['HOME']}/RubymineProjects/TeamLab/Framework/Data/MimeTypes.txt"
      hash_types = {}
      CSV.foreach(file, encoding: 'UTF-8', col_sep: '|') do |row|
        hash_types[row[0].to_sym] = row[1]
      end
      mime = hash_types[mime_type.to_sym]
      mime
    end

    def extract_to_folder(path_to_archive,
                          path_to_extract = path_to_archive.chomp(File.basename(path_to_archive)))
      raise 'File not found: ' + path_to_archive.to_s unless wait_file_to_download(path_to_archive)

      path_to_extract += '/' unless path_to_extract[-1] == '/'
      path_to_file = path_to_extract + File.basename(path_to_archive)
      # unless File.exist?(path_to_file)
      #  FileUtils.cp path_to_archive, path_to_extract
      # end
      Zip::File.open(path_to_file) do |zip_file|
        zip_file.each do |file|
          file_path = File.join(path_to_extract, file.name)
          a = File.dirname(file_path)
          create_folder(a)
          zip_file.extract(file, file_path)
        end
      end
    end

    def output_string_to_file(string, file_name)
      File.open(file_name, 'a+') do |f1|
        f1.write(string)
      end
    end

    def copy_file(file_path, destination)
      FileUtils.mkdir_p(destination) unless File.directory?(destination)
      FileUtils.copy(file_path, destination)
    end

    def get_file_content_by_link(link)
      file = open(link)
      file.read
    end

    def directory_hash(path)
      files = []
      Dir.foreach(path).sort.each do |entry|
        next if ['.', '..'].include?(entry)

        full_path = File.join(path, entry)
        if File.directory?(full_path)
          files += directory_hash(full_path)
        else
          files << File.join(path, entry)
        end
      end
      files.keep_if do |current|
        current.end_with?('_spec.rb')
      end
      files
    end

    def list_file_in_directory(directory)
      paths = []
      Find.find(directory) do |path|
        next if FileTest.directory?(path)

        paths << path
      end
      paths
    rescue Errno::ENOENT
      []
    end

    # Create file with content
    # @param file_path [String] path to created file
    # @param [String] content content of file
    # @return [String] path to created file
    def create_file_with_content(file_path: '/tmp/temp_file.ext', content: '')
      File.write(file_path, content)
      LoggerHelper.print_to_log("Created file: #{file_path} with content: #{content}")
      file_path
    end

    # Create empty file with size
    # @param file_path [String] path to created file
    # @param size [String] file size, may use binary indexes lik '256M', '15G'
    # @return [String] path to created file
    def create_file_with_size(file_path: '/tmp/temp_file.ext', size: '1G')
      `fallocate -l #{size} #{file_path}`
      file_path
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

    # Get line count in file
    # @param file_name [String] name of file
    # @return [Fixnum] count of lines in file
    def file_line_count(file_name)
      line_count = `wc -l < #{file_name}`.to_i
      LoggerHelper.print_to_log("Count of lines in '#{file_name}' is #{line_count}")
      line_count
    end

    # Get line count in file
    # @param file_name [String] name of file
    # @param line_number [Fixnum] line of file to get
    # @return [String] line of file by number
    def read_specific_line(file_name, line_number)
      line = `sed '#{line_number + 1}!d' #{file_name}`
      line.chop! if line.last == "\n"
      LoggerHelper.print_to_log("Lines in '#{file_name}' by number is '#{line}'")
      line
    end
  end
end
