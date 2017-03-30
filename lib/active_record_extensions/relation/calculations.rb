# frozen_string_literal: true

if ActiveRecord::VERSION::MAJOR == 4
  module ActiveRecord
    module Calculations
      def execute_grouped_calculation(operation, column_name, distinct) #:nodoc:
        group_attrs = group_values

        if group_attrs.first.respond_to?(:to_sym)
          association  = @klass._reflect_on_association(group_attrs.first)
          associated   = group_attrs.size == 1 && association && association.belongs_to? # only count belongs_to associations
          group_fields = Array(associated ? association.foreign_key : group_attrs)
        else
          group_fields = group_attrs
        end

        group_aliases = group_fields.map do |field|
          column_alias_for(field)
        end
        group_columns = group_aliases.zip(group_fields).map do |aliaz, field|
          [aliaz, field]
        end

        group = group_fields

        aggregate_alias = if operation == 'count' && column_name == :all
                            'count_all'
                          else
                            column_alias_for([operation, column_name].join(' '))
                          end

        select_values = [
          operation_over_aggregate_column(
            aggregate_column(column_name),
            operation,
            distinct
          ).as(aggregate_alias)
        ]
        select_values += select_values unless having_values.empty?

        fields = group_fields.zip(group_aliases).map do |field, aliaz|
          if field.respond_to?(:as)
            field.as(aliaz)
          else
            "#{field} AS #{aliaz}"
          end
        end
        select_values.concat(fields)
        values_to_select = having_values.map { |v| v.split(/[<=>]+/) }.flatten.select { |v| v.match(/([^\.\s\(]*)\.([^\.\s\)]*)/) }
        having_aliases = values_to_select.map do |v|
          having_match = v.match(/([^\.\s\(]*)\.([^\.\s\)]*)/)
          having_value = "#{having_match[1]}.#{having_match[2]}"
          "#{having_value} AS #{column_alias_for(having_value)}"
        end
        select_values.concat having_aliases

        relation = except(:group)
        relation.group_values  = group
        relation.select_values = select_values

        calculated_data = @klass.connection.select_all(relation, nil, relation.arel.bind_values + bind_values)

        if association
          key_ids     = calculated_data.collect { |row| row[group_aliases.first] }
          key_records = association.klass.base_class.find(key_ids)
          key_records = Hash[key_records.map { |r| [r.id, r] }]
        end

        Hash[calculated_data.map do |row|
          key = group_columns.map do |aliaz, col_name|
            column = calculated_data.column_types.fetch(aliaz) do
              type_for(col_name)
            end
            type_cast_calculated_value(row[aliaz], column)
          end
          key = key.first if key.size == 1
          key = key_records[key] if associated

          column_type = calculated_data.column_types.fetch(aggregate_alias) { type_for(column_name) }
          [key, type_cast_calculated_value(row[aggregate_alias], column_type, operation)]
        end]
      end
    end
  end
else
  Rails.logger.warn "WARNING: Extension #{__FILE__} may not apply. Please check the condition and remove if possible."
end
