require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...

    where_line = ''
    keys = params.keys
    keys.each_with_index do |key, idx|
      where_line += "#{key.to_s} = :#{key.to_s}"
      where_line += ' AND ' unless idx == keys.length - 1
    end

    results = DBConnection.execute(<<-SQL, params)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    results.map {|result| self.new(result)}
  end
end



class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
