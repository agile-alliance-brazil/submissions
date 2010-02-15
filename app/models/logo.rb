class Logo < ActiveRecord::Base
  def to_filename(opts = {})
    filename = ["logo#{self[:id]}"]
    append_size(filename, opts)
    append_colour(filename, opts)
    "#{filename.join('_')}.#{self[:format]}"
  end
  
  private
  def append_size(filename, opts)
    size = opts[:size] || :big
    filename << (size == :big ? "500" : "200")
  end
  
  def append_colour(filename, opts)
    coloured = opts.has_key?(:color) ? opts[:color] : true
    filename << "bw" unless coloured
  end
end