module SearchMagic
  class Metadata
    attr_accessor :type, :through, :prefix, :field_name, :relation_metadata, :options

    def initialize(attributes = {})
      attributes.each do |key, value|
        send(:"#{key}=", value)
      end
    end
  
    def name
      @name ||= [options[:skip_prefix].presence ? nil : (prefix.present? ? (options[:as] || prefix) : nil), 
                prefix.present? ? field_name : (options[:as] || field_name)].compact.join("_").to_sym
    end
  
    def value_for(obj, keep_punctuation)
      v = self.through.call(obj)
      v = v.is_a?(Array) ? v.join(" ") : v.to_s
      v = v.gsub(/[[:punct:]]/, ' ') unless keep_punctuation
      v
    end
    
    def arrangeable_value_for(obj)
      self.through.call(obj)
    end
  
    def searchable_value_for(obj)
      value_for(obj, options[:keep_punctuation]).downcase.split.map {|word| [name, word].join(":")}
    end
  end
end