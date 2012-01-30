module SearchMagic
  class StackFrame
    attr_accessor :origin_type, :target_type, :association, :path
    
    def self.from_type(target_type)
      self.new(nil, nil).tap {|s| s.target_type = target_type}
    end
    
    def initialize(origin_type, association, path = [])
      self.origin_type = origin_type
      self.target_type = association.class_name.constantize if association
      self.association = association
      self.path = path
    end
    
    def wants_field?(field_name)
      !field_excluded?(field_name) && field_included?(field_name)
    end
    
    def token
      @token ||= [self.origin_type, self.association.try(:name), self.target_type]
    end
    
    def inverse_token
      @inverse_token ||= [self.target_type, self.association.try(:inverse), self.origin_type]
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