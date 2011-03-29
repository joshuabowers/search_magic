module SearchMagic
  module FullTextSearch
    module ClassMethods
      def self.extended(receiver)
        receiver.send :class_attribute, :searchable_fields, :instance_writer => false
        receiver.send :searchable_fields=, {}
        receiver.send :field, :searchable_values, :type => Array, :default => []
        receiver.send :field, :arrangeable_values, :type => Hash, :default => {}
        receiver.send :before_save, :update_searchable_values
        receiver.send :before_save, :update_arrangeable_values
        receiver.send :after_save, :update_associated_documents
      end
      
      def search_on(field_name, options = {})
        searchable_fields[field_name] = options
      end
      
      def searchables
        @searchables ||= create_searchables
      end
      
      def inverse_searchables
        @inverse_searchables ||= relations.values.
          select {|metadata| metadata.class_name.constantize.searchable_fields.keys.include?(metadata.inverse_setter.chomp("=").to_sym)}.
          map(&:name)
      end
      
      def search(pattern)
        rval = /("[^"]+"|\S+)/
        rsearch = /(?:(#{searchables.keys.join('|')}):#{rval})|#{rval}/i
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
      
      def arrange(arrangeable, direction = :asc)
        arrangeable.blank? || !searchables.keys.include?(arrangeable.to_sym) ? criteria : order_by([["arrangeable_values.#{arrangeable}", direction]])
      end
      
      private 
      
      def create_searchables
        fields = searchable_fields.map do |field_name, options|
          if association = reflect_on_association(field_name)
            options[:as] ||= nil
            only = [options[:only]].flatten.compact
            except = [:_D_E_A_D_B_3_3_F_, options[:except]].flatten.compact
            associated = association.class_name.constantize.searchables
            wanted = associated.keys.grep(/^(?!.*?(#{except.join("|")})).*/).grep(/^#{only.join("|")}/)
            associated.select {|key, value| wanted.include?(key)}.map do |name, metadata|
              Metadata.new(:type => self, :through => lambda do |obj|
                value = obj.send(field_name)
                value.is_a?(Array) ? value.map {|item| metadata.through.call(item)} : metadata.through.call(value)
              end, :prefix => field_name.to_s.singularize.to_sym, :field_name => name, :relation_metadata => association, :options => metadata.options.merge(options))
            end
          else
            Metadata.new(:type => self, :through => lambda {|obj| obj.send(field_name) }, :field_name => field_name.to_s.pluralize.singularize.to_sym, :options => options)
          end
        end.flatten
        
        Hash[*fields.map {|metadata| [metadata.name, metadata]}.flatten]
      end
    end
  
    module InstanceMethods      
      private
      
      def update_searchable_values
        self.searchable_values = self.class.searchables.values.map {|metadata| metadata.searchable_value_for(self)}.flatten
      end
      
      def update_arrangeable_values
        self.arrangeable_values = Hash[*self.class.searchables.map {|key, metadata|
          [key, metadata.arrangeable_value_for(self)]
          }.flatten(1)]
      end
      
      def update_associated_documents
        self.class.inverse_searchables.each do |relation_name|
          relation = send(relation_name)
          (relation.is_a?(Array) ? relation : [relation]).each(&:save!)
        end
      end
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end