module SearchMagic
  module FullTextSearch
    module ClassMethods
      def self.extended(receiver)
        receiver.send :class_attribute, :searchable_fields, :instance_writer => false
        receiver.send :searchable_fields=, {}
        receiver.send :field, :_searchable_values, :type => Array, :default => []
        receiver.send :before_save, :update_searchable_values
      end
      
      def searchable_field(field_name)
        send(:searchable_fields)[field_name] = true
      end
    end
  
    module InstanceMethods
      private
      
      def update_searchable_values
        send :_searchable_values=, self.searchable_fields.keys.map {|field_name| "#{field_name}:#{send(field_name)}"}
      end    
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end