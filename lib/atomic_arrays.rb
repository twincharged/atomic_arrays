require "atomic_arrays/version"

module AtomicArrays

  def self.included(klass)
      klass.class_eval do
        extend AtomicClassMethods
      end
  end

  def atomic_append(field, value)
      raise "Cannot append multiple values." if value.is_a?(Array)
      value = prepare_array_vals(value)
      return self.execute_array_query(field, value, "array_append")
  end

  def atomic_remove(field, value)
      raise "Cannot remove multiple values." if value.is_a?(Array)
      value = prepare_array_vals(value)
      return self.execute_array_query(field, value, "array_remove")
  end

  def atomic_cat(field, values)
      raise "Cannot cat strings or integers" if (values.is_a?(Integer) || values.is_a?(String))
      values = prepare_array_vals(values)
      return self.execute_array_query(field, "ARRAY[#{values}]", "array_cat")
  end

  def atomic_relate(field, related_class, limit=100)
      raise "Relates to a class, not a string or integer." if (related_class.is_a?(Integer) || related_class.is_a?(String))
      (table, field) = self.prepare_array_query(field)
      related_table = related_class.table_name.inspect
      return result = related_class.execute_and_wrap(%Q{SELECT #{related_table}.* FROM #{related_table} WHERE #{related_table}.id IN (SELECT unnest(#{table}.#{field}) FROM #{table} WHERE #{table}.id = #{self.id}) LIMIT #{limit}})
  end

  def execute_array_query(field, value, array_method)
      (table, field) = self.prepare_array_query(field)
      result = self.class.execute_and_wrap(%Q{UPDATE #{table} SET #{field} = #{array_method}(#{field}, #{value}) WHERE #{table}.id = #{self.id} RETURNING #{table}.*})
      return result[0]
  end

  def prepare_array_query(field)
      table = self.class.table_name.inspect
      field = field.to_s.inspect
      return [table, field]
  end

  def prepare_array_vals(value)
      prep_array = []
      [*value].map {|val| val = "\'#{val}\'" if val.class == String; prep_array.push(val)} 
      return prep_array.join(", ")
  end

  module AtomicClassMethods
    def execute_and_wrap(sql, binds=[])
      result_set = self.connection.select_all(self.sanitize_sql(sql), "#{self.name} Load", binds)
      column_types = {}
      column_types = result_set.column_types if result_set.respond_to?(:column_types)
      return result_set.map { |record| self.instantiate(record, column_types) }
    end
  end

end