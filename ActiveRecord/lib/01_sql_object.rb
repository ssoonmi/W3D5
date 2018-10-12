require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    if @columns.nil?
      columns = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
         #{table_name}
      SQL
      @columns = columns.first.map { |key| key.to_sym}
    end
    @columns
  end

  def self.finalize!
    columns.each do |column|
      column_var = "@#{column.to_s}".to_sym
      define_method(column) do
        attributes[column]
      end

      column_s_eq = column.to_s + '='
      define_method(column_s_eq) do |arg|
        attributes[column] = arg
      end
    end

  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.to_s.downcase + 's'
  end

  def self.all
    # ...
    all_rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
       #{table_name}
    SQL
    all_rows.map do |row|
      self.new(row)
    end
  end

  def self.parse_all(results)
    # ...
    parsed = []
    results.each do |result|
      parsed << self.new(result)
    end
    parsed
  end

  def self.find(id)
    # ...
    result =  DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
       #{table_name}
      WHERE
        id = #{id}
    SQL
    return nil if result.empty?
    self.new(result.first)
  end

  def initialize(params = {})
    # ...
    params.keys.each do |column|
      column_s = column.to_s + '='
      begin
        self.send(column_s, params[column])
      rescue
        raise "unknown attribute 'favorite_band'"
      end
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    attributes.values
  end

  def insert
    # ...
    values = attribute_values.map do |el|
      el = "'" + el + "'" if el.is_a?(String)
      el = el.to_s if el.is_a?(Fixnum)
      el
    end

    values = '(' + values.join(', ') + ')'
    columns = self.class.columns[1..-1].map(&:to_s).join(', ')
    DBConnection.execute(<<-SQL)
      INSERT INTO
        #{self.class.table_name}(#{columns})
      VALUES
        #{values}
    SQL
    @attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    # ...
    values = attribute_values.map do |el|
      el = "'" + el + "'" if el.is_a?(String)
      el = el.to_s if el.is_a?(Fixnum)
      el
    end

    attribute_keys = attributes.keys

    setting = ''
    values.each_with_index do |el, idx|
      setting += attribute_keys[idx].to_s + ' = ' + el
      setting += ', ' unless idx == values.length - 1
    end

    DBConnection.execute(<<-SQL, id: self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{setting}
      WHERE
        id = :id
    SQL
  end

  def save
    # ...
    if @attributes.nil? || @attributes[:id].nil?
      insert
    else
      update
    end
  end
end
