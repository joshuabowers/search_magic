module SearchMagic
  module FullTextSearch
    module ClassMethods
      def self.extended(receiver)
        receiver.send :class_attribute, :searchable_fields, :instance_writer => false
        receiver.send :searchable_fields=, {}
        receiver.send :field, :_searchable_values
        receiver.send :before_save, :update_searchable_values
      end
      
      def searchable_field(field_name)
        send(:searchable_fields)[field_name] = true
      end
      
      private
      
      def update_searchable_values
      end
    end
  
    module InstanceMethods
    
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end