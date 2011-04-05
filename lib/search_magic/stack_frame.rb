module SearchMagic
  class StackFrame
    attr_accessor :type, :path
    
    def initialize(type, path = [])
      self.type = type
      self.path = path
    end
    
    def wants_field?(field_name)
      !field_excluded?(field_name) && field_included?(field_name)
    end
    
    private
    
    def field_included?(field_name)
      options[:only].blank? || options[:only].include?(field_name)
    end
    
    def field_excluded?(field_name)
      options[:except].present? && options[:except].include?(field_name)
    end
    
    def options
      @options ||= (path.last.try(:options) || {})
    end    
  end
end