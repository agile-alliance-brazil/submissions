require 'csv'

class PreRegistrationLoader
  attr_accessor :pre_registrations
  
  def initialize(filepath)
    @pre_registrations = []
    @filename = filepath.split('/')[-1]
    raise Exception.new("File '#{@filename}' does not exist.") unless File.exist?(filepath)
    parsed_file = CSV::Reader.parse(File.open(filepath, 'r'))
    email_column = email_column(parsed_file.shift)
    parsed_file.each do |row|
      @pre_registrations << PreRegistration.new(:conference => Conference.current, :email => row[email_column], :used => false)
    end
  end
  
  def save
    @pre_registrations.each {|r| r.save}
  end
  
  private
  def email_column(header)
    email_header = header.select{|h| h.start_with? "E-mail"}.first
    email_column = header.index email_header
    if email_column.nil?
      raise Exception.new("File '#{@filename}' is not in the expected format.")
    else
      email_column
    end
  end
end

