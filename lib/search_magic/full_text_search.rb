module SearchMagic
  module FullTextSearch
    module ClassMethods
      def searchable_fields(*field_names)
        field :_searchable_values
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