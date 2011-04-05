module SearchMagic
  module FullTextSearch
    extend ActiveSupport::Concern
    
    included do
      class_attribute :searchable_fields, :instance_writer => false
      self.searchable_fields = {}
      field :searchable_values, :type => Array, :default => []
      field :arrangeable_values, :type => Hash, :default => {}
      before_save :update_searchable_values
      before_save :update_arrangeable_values
      after_save :update_associated_documents
    end
    
    module ClassMethods
      def search_on(field_name, options = {})
        searchable_fields[field_name] = options
      end
      
      def searchables
        @searchables ||= create_searchables
      end
      
      def inverse_searchables
        @inverse_searchables ||= relations.values.
          map {|metadata| [metadata, metadata.class_name.constantize] }.
          select {|metadata, klass| klass < SearchMagic::FullTextSearch && klass.searchable_fields.keys.include?(metadata.inverse_setter.chomp("=").to_sym)}.
          map(&:first).map(&:name)
      end
      
      def search_for(pattern)
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
      alias :and_for :search_for
      
      def arrange(arrangeable, direction = :asc)
        arrangeable.blank? || !searchables.keys.include?(arrangeable.to_sym) ? criteria : order_by([["arrangeable_values.#{arrangeable}", direction]])
      end
      
      private 
      
      def create_searchables
        stack, visited, fields = [[self, []]], {}, []
        until stack.empty?
          current = stack.shift
          unless visited.has_key?(current.first)
            visited[current.first] = true
            current_options = current.second.try(:last).try(:second)
            if current_options.present?
              current_options[:except] = Array.wrap(current_options[:except]).compact
              current_options[:only] = Array.wrap(current_options[:only]).compact
            end
            current.first.searchable_fields.each do |field_name, options|
              next if current_options[:except].try(:include?, field_name) || (current_options[:only].present? && !current_options[:only].try(:include?, field_name)) unless current_options.nil?
              path = current.second.clone + [[field_name, options]]
              if association = current.first.reflect_on_association(field_name)
                stack << [association.class_name.constantize, path]
              else
                fields << Metadata.new(:origin_type => current.first, :through => path, :options => options)
              end
            end
          end
        end
        
        fields.index_by(&:name)
      end
    end
  
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
end