class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
      name_s = name.to_s
      define_method(name) { instance_variable_get("@#{name_s}") }
      name_s_eq = name_s + '='
      define_method(name_s_eq.to_sym) do |var|
        instance_variable_set("@#{name_s}", var)
      end
    end
  end
end
