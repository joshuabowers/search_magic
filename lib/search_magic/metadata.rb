module SearchMagic
  class Metadata
    attr_accessor :type, :through, :options
    
    def initialize(attributes = {})
      attributes.each do |key, value|
        send(:"#{key}=", value)
      end
    end
  
    def name
      @name ||= through.map(&:term).compact.join("_").to_sym
    end
    
    def comparable?
      @comparable ||= self.type.public_instance_methods.include? :<
    end
    
    def datable?
      @datable ||= [Date, DateTime, Time].include? self.type
    end
    
    def unnameable?
      @unnameable ||= self.name == :""
    end
    
    def hashable?
      @hashable ||= self.type <= Hash
    end
  
    def value_for(obj, keep_punctuation)
      v = get_value(obj)
      v = v.is_a?(Array) ? v.join(" ") : v.to_s
      v = v.gsub(/[[:punct:]]/, ' ') unless keep_punctuation
      v
    end
    
    def arrangeable_value_for(obj)
      post_process(get_value(obj))
    end
  
    def searchable_value_for(obj)
      value_for(obj, options[:keep_punctuation]).downcase.split.map {|word| [name.blank? ? nil : name, word].compact.join(SearchMagic.config.selector_value_separator || ':')}
    end
    
    private
    
    def get_value(obj)
      self.through.map(&:field_name).inject(obj) {|memo, method| memo.present? ? (memo.is_a?(Array) ? memo.map{|o| o.send(method)} : memo.send(method)) : nil}
    end
    
    def post_process(value)
      value.is_a?(Array) ? value.map {|obj| convert_date_to_time(obj)} : convert_date_to_time(value)
    end
    
    def convert_date_to_time(value)
      case value.class.name
      when "Date"
        value.to_time
      when "DateTime"
        value.utc.to_time.localtime
      else
        value
      end
    end
  end
end