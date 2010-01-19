class AutocompleteFormBuilder < Formtastic::SemanticFormBuilder
  def autocomplete_input(method, options)
    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, :autocomplete).merge(html_options)

    self.label(method, options_for_label(options)) <<
    template.text_field_with_auto_complete(sanitized_object_name, method, html_options, strip_formtastic_options(options))
  end
end