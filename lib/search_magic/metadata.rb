module SearchMagic
  class Metadata
    attr_accessor :origin_type, :through, :options
    
    def initialize(attributes = {})
      attributes.each do |key, value|
        send(:"#{key}=", value)
      end
    end
  
    def name
      @name ||= through.map(&:term).compact.join("_").to_sym
    end
  
    def value_for(obj, keep_punctuation)
      v = get_value(obj)
      v = v.is_a?(Array) ? v.join(" ") : v.to_s
      v = v.gsub(/[[:punct:]]/, ' ') unless keep_punctuation
      v
    end
    
    def arrangeable_value_for(obj)
      get_value(obj)
    end
  
    def searchable_value_for(obj)
      value_for(obj, options[:keep_punctuation]).downcase.split.map {|word| [name, word].join(":")}
    end
    
    private
    
    def get_value(obj)
      self.through.map(&:field_name).inject(obj) {|memo, method| memo.is_a?(Array) ? memo.map{|o| o.send(method)} : memo.send(method)}
    end
  end
end