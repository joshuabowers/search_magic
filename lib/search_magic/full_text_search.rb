module SearchMagic
  module FullTextSearch
    module ClassMethods
      def self.extended(receiver)
        receiver.send :before_save, :update_searchable_values
      end
      
      def searchable_fields(*field_names)
        class_attribute :_searchable_fields, :instance_writer => false
        send(:_searchable_fields=, Hash[*field_names.map {|field_name| [field_name, true]}.flatten])
        field :_searchable_values
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