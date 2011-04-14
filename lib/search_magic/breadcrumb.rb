module SearchMagic
  class Breadcrumb
    attr_accessor :field_name, :options
    
    def initialize(field_name, options)
      self.field_name = field_name
      self.options = options
      self.options[:except] = Array.wrap(self.options[:except]).compact
      self.options[:only] = Array.wrap(self.options[:only]).compact
    end
    
    def term
      @term ||= options[:skip_prefix].presence ? nil : (options[:as] || field_name.to_s.pluralize.singularize).to_sym
    end
    
    def clone
      Breadcrumb.new(field_name, options)
    end
  end
end