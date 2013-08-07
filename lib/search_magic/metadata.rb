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
    
    def search_regex_fragment
      self.hashable? ? "#{name}#{separator}[^#{separator}\\s]+" : name.to_s
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
      
    def arrangeable_value_for(obj)
      post_process(get_value(obj))
    end
  
    def searchable_value_for(obj)
      value_for(get_value(obj)).downcase.split.map {|word| [name.blank? ? nil : name, word].compact.join(separator)}
    end
    
    private
    
    def value_for(obj)
      v = obj
      v = v.map {|key, value| value_for(value).split.map {|word| "#{key}#{separator}#{word}"} }.flatten if obj.is_a?(Hash)
      v = v.is_a?(Array) ? v.join(" ") : v.to_s
      options[:keep_punctuation] || obj.is_a?(Hash) ? v : v.to_s.gsub(/[[:punct:]]/, ' ')
    end
        
    def separator
      SearchMagic.config.selector_value_separator || ':'
    end
    
    def get_value(obj)
      self.through.map(&:field_name).inject(obj) {|memo, method| memo.present? ? (memo.is_a?(Array) ? memo.map{|o| o.send(method)}.flatten : memo.send(method)) : nil}
    end
    
    def post_process(value)
      case(value.class)
      when Array
        value.map {|obj| convert_date_to_time(obj)}
      when Hash
        Hash[*value.map {|key, value| [key, convert_date_to_time(value)]}]
      else
        convert_date_to_time(value)
      end
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