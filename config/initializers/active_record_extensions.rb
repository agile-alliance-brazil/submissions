# encoding: UTF-8
class ActiveRecord::Base
  include Trimmer
  include AutoCompleteUsername
end
