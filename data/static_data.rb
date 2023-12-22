# frozen_string_literal: true

require 'json'

# class with some constants and static data
class StaticData
  LIBS_ARRAY = %w[libDjVuFile.so libdoctrenderer.so libHtmlFile2.so libHtmlRenderer.so
                  libicudata.so.58 libicuuc.so.58 libPdfReader.so libUnicodeConverter.so
                  libXpsFile.so libPdfWriter.so libXpsFile.so libkernel.so libgraphics.so].freeze

  PROJECT_BIN_PATH = "#{Dir.pwd}/bin".freeze
  FONTS_PATH = "#{Dir.pwd}/assets/fonts".freeze
  CONVERSION_STRAIGHT = {
    docx: %i[doct odt rtf],
    xlsx: %i[xlst],
    pptx: %i[pptt]
  }.freeze

  CONVERSION_FROM_XML = {
    docx: %i[txt],
    xlsx: %i[csv]
  }.freeze

  TMP_DIR = "#{Dir.pwd}/tmp".freeze
  NEW_FILES_DIR = "#{Dir.pwd}/assets/files/new".freeze
  BROKEN_FILES_DIR = "#{Dir.pwd}/assets/files/broken".freeze

  EXCEPTION_FILES = JSON.load_file("#{Dir.pwd}/data/exception_file.json")

  PROJECT_NAME = 'X2t testing'
  PALLADIUM_SERVER = 'palladium.teamlab.info'
  POSITIVE_STATUSES = %w[passed passed_2].freeze

  def self.get_palladium_token
    return ENV.fetch('PALLADIUM_TOKEN') if ENV.key?('PALLADIUM_TOKEN')

    File.read("#{Dir.home}/.palladium/token")
  end
end
