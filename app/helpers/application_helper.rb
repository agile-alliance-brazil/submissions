# encoding: UTF-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def prepend_http(url)
    return url if url.blank?
    !!( url !~ /\A(?:http:\/\/)/i ) ? "http://#{url}" : url
  end

  def render_avatar(user, options={})
    content_tag(:div, class: 'avatar') do
      avatar = link_to(image_tag(gravatar_url(user, options), alt: user.full_name), user_path(user))
      tip = content_tag(:div, class: 'tip') do
        I18n.t('tips.change_gravatar', email: CGI.escape(user.email)).html_safe
      end
      options[:display_tip] ? avatar + tip : avatar
    end
  end

  def link_to_menu_item(tag, name, url)
    content_tag(tag, class: (current_page?(url) ? "selected" : "")) do
      link_to name, url
    end
  end

  def autotab
    @current_tab ||= 0
    @current_tab += 1
  end

  def sortable_column(text, column, parameters=request.parameters)
    if parameters[:column] == column.to_s
      direction = parameters[:direction] == 'down' ? 'up' : 'down'
    else
      direction = 'down'
    end
    link_to text, parameters.merge(column: column, direction: direction, page: nil)
  end

  def textilize(text)
    ::RedCloth.new(text, [:filter_html, :sanitize_html]).to_html(:textile).html_safe
  end

  def translated_country(country_code)
    return '' if country_code.blank?
    I18n.translate('countries')[country_code.to_s.upcase.to_sym]
  end

  def translated_state(state_code)
    states = ActionView::Helpers::FormOptionsHelper::ESTADOS_BRASILEIROS.map { |name, code| [code, name] }
    state_map = Hash[states]
    state_map[state_code.to_s.upcase] || ''
  end

  def present_date(conference, date_map)
    content = raw "#{l(date_map.first.to_date)}: #{t("conference.dates.#{date_map.last}")}"
    content = content_tag('strong') {content} if date_map.first == conference.next_deadline(:all).try(:first)
    content
  end
end
