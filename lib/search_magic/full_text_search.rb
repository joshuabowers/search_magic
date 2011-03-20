module SearchMagic
  module FullTextSearch
    module ClassMethods
      def self.extended(receiver)
        receiver.send :class_attribute, :searchable_fields, :instance_writer => false
        receiver.send :searchable_fields=, {}
        receiver.send :field, :searchable_values, :type => Array, :default => []
        receiver.send :before_save, :update_searchable_values
      end
      
      def search_on(field_name, options = {})
        metadata = reflect_on_association(field_name)
        send(:searchable_fields)[field_name] = Metadata.new(:field_name => field_name, :field => fields[field_name.to_s], :association => metadata, :options => options)
      end
      
      def searchables
        @searchables ||= searchable_fields.values.map {|metadata| metadata.searchable_names(nil).map(&:first)}.flatten
      end
      
      def search(pattern)
        rval = /("[^"]+"|\S+)/
        rsearch = /(?:(#{searchables.join('|')}):#{rval})|#{rval}/i
        unless pattern.blank?
          terms = pattern.scan(rsearch).map(&:compact).map do |term|
            term.last.scan(/\b(\S+)\b/).flatten.map do |word|
              /#{term.length > 1 ? Regexp.escape(term.first) : '[^:]+'}:.*#{Regexp.escape(word)}/i
            end
          end.flatten
          all_in(:searchable_values => terms)
        else
          criteria
        end
      end
    end
  
    module InstanceMethods
      private
      
      def update_searchable_values
        send :searchable_values=, self.searchable_fields.values.map {|metadata| metadata.searchable_value(self)}.flatten
      end
    end
    
    class Metadata
      attr_accessor :field_name, :field, :association, :options

      def initialize(attributes = {})
        attributes.each do |key, value|
          send(:"#{key}=", value)
        end
        options[:only] = [options[:only]].flatten.compact
        options[:except] = [options[:except]].flatten.compact
      end
      
      def searchable_value(model)
        searchable_names(model).map {|searchable_name, value, sub_name| value_for(searchable_name, value, sub_name)}
      end
      
      def searchable_names(model)
        name = options[:as] || self.field_name
        value = model.present? ? model.send(self.field_name) : nil
        fields = self.association.class_name.constantize.searchable_fields.keys if self.association
        fields = (fields - options[:except]) & (options[:only].blank? ? fields : options[:only]) if fields
        case self.association.try(:macro)
        when nil
          [[self.field.type == Array ? name.to_s.singularize.to_sym : name, value, nil]]
        when :embedded_in, :embeds_one, :referenced_in, :references_one
          fields.map {|sub_name| [:"#{name}_#{sub_name}", value, sub_name]}
        else
          fields.map {|sub_name| [:"#{name.to_s.singularize}_#{sub_name.to_s.pluralize}", value, sub_name]}
        end
      end
      
      def value_for(searchable_name, value, field_name)
        v = field_name.present? && value.present? ? value.send(field_name) : value
        v = v.is_a?(Array) ? v.join(" ") : v.to_s
        v = v.gsub(/[[:punct:]]/, '') unless options[:keep_punctuation]
        v.downcase.split.map {|word| [searchable_name, word].join(":")}
      end
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end