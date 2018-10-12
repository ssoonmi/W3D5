require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    through_options = @assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      source_table = source_options.model_class.table_name
      through_table = through_options.model_class.table_name
      source_table_id = source_table + '.id'
      source_table_foreign_key = through_table + '.' + source_options.foreign_key.to_s
      self_table = self.class.table_name
      through_table_id = through_table + '.id'
      through_table_foreign_key = self_table + '.' + through_options.foreign_key.to_s

      result = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table}
          ON #{source_table_foreign_key} = #{source_table_id}
        JOIN
          #{self_table}
          ON #{through_table_id} = #{through_table_foreign_key}
        WHERE
          #{self_table}.id = #{self.id}
      SQL
      source_options.model_class.new(result.first)
    end
    # source_table, source_table, through_table, source_table_foreign_key, source_table_id,
    # self_table, through_table_id, through_table_foreign_key, self.id
    #
    # SELECT
    #   houses.*
    # FROM
    #   houses
    # JOIN
    #   humans
    #   ON humans.house_id = houses.id
    # JOIN
    #   cats
    #   ON humans.id = cats.owner_id
    # WHERE
    #   cats.id = ?
    #
    # source_table = source_options.model_class.table_name
    # through_table = through_options.model_class.table_name
    # source_table_id = source_table + '.id'
    # source_table_foreign_key = source_table + '.' + source_options.foreign_key.to_s
    # self_table = self.class.table_name
    # through_table_id = through_table + '.id'
    # through_table_foreign_key = self_table + '.' + through_options.foreign_key.to_s

  end
end
