# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def prepend_http(url)
    return url if url.blank?
    !!( url !~ /\A(?:http:\/\/)/i ) ? "http://#{url}" : url
  end
  
  def link_to_menu_item(tag, name, url)
    content_tag(tag, :class => (current_page?(url) ? "selected" : "")) do
      link_to name, url
    end
  end
  
  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end
  
  def sortable_column(text, column)
    text + sort_link(column, 'up') + sort_link(column, 'down')
  end

  def sort_link(column, direction, options = {})
    condition = options[:unless] if options.has_key?(:unless)
    text = t('generic.sort_by', :direction => t("generic.sort_#{direction}"), :column => column.to_s.capitalize)
    image = image_tag("#{direction}.gif", :alt => text, :class_name => "sort #{direction}")
    link_to_unless condition, image, request.parameters.merge({:column => column, :direction => direction})
  end  
end
