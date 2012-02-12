# encoding: UTF-8
module TokenGenerator
  # Make a class method available to define space-trimming behavior.
  def self.included base
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def generate_token(column)
      loop do
        token = SecureRandom.hex(5)
        break token unless find(:first, :conditions => { column => token })
      end
    end
  end
  
  private
  def generate_uri_token
    self.uri_token ||= self.class.generate_token(:uri_token)
  end
end
