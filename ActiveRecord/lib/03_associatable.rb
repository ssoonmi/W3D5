require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    self.class_name.constantize
  end

  def table_name
    # ...
    self.class_name.downcase.underscore + 's'
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    defaults = [:foreign_key,
    :class_name,
    :primary_key]
    defaults_hsh = {}
    defaults.each do |default|
      if options[default].nil?
        case default
        when :foreign_key
          @foreign_key = "#{name.to_s.downcase.underscore}_id".to_sym
          defaults_hsh[default] = @foreign_key
        when :primary_key
          @primary_key = :id
          defaults_hsh[default] = @primary_key
        when :class_name
          @class_name = name.to_s.camelcase.capitalize
          defaults_hsh[default] = @class_name
        end
      else
        self.send("#{default.to_s}=", options[default])
        defaults_hsh[default] = options[default]
      end
    end
    @options = defaults_hsh
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    defaults = [:foreign_key,
    :class_name,
    :primary_key]
    defaults.each do |default|
      if options[default].nil?
        case default
        when :foreign_key
          @foreign_key = "#{self_class_name.downcase.underscore.to_s}_id".to_sym
        when :primary_key
          @primary_key = :id
        when :class_name
          @class_name = name.camelcase.capitalize.singularize
        end
      else
        self.send("#{default.to_s}=", options[default])
      end
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    b = BelongsToOptions.new(name, options)
    define_method(name) do
      b = BelongsToOptions.new(name, options)
      foreign_key = self.send(b.foreign_key)
      result = b.model_class.where(:id => foreign_key.to_s)
      result.first
    end
    @assoc_options ||= {name => b}
  end

  def has_many(name, options = {})
    # ...

    define_method(name) do
      b = HasManyOptions.new(name.to_s, self.class.to_s, options)
      foreign_key = b.foreign_key
      result = b.model_class.where(foreign_key => self.id)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
    # @assoc_options.keys.each do |class_name|
    #   define_method(class_name.to_s + '_option') {}
    # end
    # @assoc_options
    # @assoc_options[name] = BelongsToOptions.new(name, @attributes)
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
