# encoding: UTF-8
class PreRegistrationLoader
  attr_accessor :pre_registrations

  def initialize(filepath)
    @filename = filepath.split('/')[-1]
    raise Exception.new("File '#{@filename}' does not exist.") unless File.exist?(filepath)
    @pre_registrations = load_file(filepath)
  end

  def save
    @pre_registrations.each {|r| r.save}
  end

  private
  def load_file(filepath)
    parsed_file = CSV.read(filepath)
    email_column = email_column(parsed_file[0])
    pre_registrations = []
    parsed_file[1..-1].each do |row|
      pre_registrations << PreRegistration.new(:conference => Conference.current, :email => row[email_column], :used => false)
    end
    pre_registrations
  end


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

