module SearchMagic
  module FullTextSearch
    extend ActiveSupport::Concern
    
    included do
      # embeds_many :searchable_values
      class_attribute :searchable_fields, :instance_writer => false
      self.searchable_fields = {}
      field :searchable_values, :type => Array, :default => []
      field :arrangeable_values, :type => Hash, :default => {}
      embeds_many :svalues, class_name: "SearchableValue", as: :searchable
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
          select {|metadata, klass| klass < SearchMagic::FullTextSearch && klass.searchable_fields.keys.include?(metadata.inverse)}.
          map(&:first).map(&:name)
      end
      
      # To support range searches, this will need to become more complicated. Specifically, it will need to be able
      # to remove any term which contains a [:below, :before, :above, :after] selector, retreive the base selector and
      # the target valuee, and match the latter against the former within the :arrangeable_values array as part of
      # the returned criteria. How this then translates to :values_matching is currently unknown.
      def search_for(pattern)
        options, pattern = strip_option_terms_from(pattern)
        terms = terms_for(pattern)
        unless terms.blank?
          send( :"#{options[:mode] || default_search_mode}_in", :searchable_values => terms)
        else
          criteria
        end
      end
      alias :and_for :search_for
      
      def arrange(arrangeable, direction = :asc)
        arrangeable.blank? || !searchables.keys.include?(arrangeable.to_sym) ? criteria : order_by([["arrangeable_values.#{arrangeable}", direction]])
      end
      
      def strip_option_terms_from(pattern)
        unless pattern.blank?
          [Hash[*(pattern.scan(option_terms).flatten)].symbolize_keys, pattern.gsub(option_terms, '').strip]
        else
          [{}, pattern]
        end
      end
      
      # p = lambda {|*t| Course.all_in(:coalesced_searchable_values => 
      #   t.map {|w| /#{w =~ /:/ ? "(?<![\\w:])#{w.scan(/([^:]+:)(.*)/).join("[^\\s]*")}" : ":[^\s]+#{w}"}(?!:)/})}
      def terms_for(pattern)
        rval = /("[^"]+"|'[^']+'|\S+)/
        rnot_separator = "[^#{separator}]+"
        rsearch = /(?:(#{searchable_names})(?:#{separator}#{rval}|(#{presence_detector_escaped})))|#{rval}/i
        unless pattern.blank?
          terms = pattern.scan(rsearch).map(&:compact).map do |term|
            selector = term.length > 1 ? Regexp.escape(term.first) : rnot_separator
            metadata = searchables[term.first.match(/^[^:]+/)[0].to_sym] if term.length > 1
            parsed_date = Chronic.parse(term.last) if metadata && metadata.datable?
            prefix = "#{selector}#{separator}"
            prefix = "(#{prefix})?" if term.length == 1
            fragment = /^#{selector}#{separator}#{parsed_date}/i if parsed_date
            fragment = /^#{prefix}[^#{separator}\s]+/i if term.last == presence_detector
            fragment || term.last.scan(/\b(\S+)\b/).flatten.map do |word|
              /^#{prefix}.*#{Regexp.escape(word)}/i
            end
          end.flatten
        else
          []
        end
      end
      
      private
      
      def searchable_names
        @searchable_names ||= searchables.values.map {|metadata| metadata.search_regex_fragment}.join("|")
      end
      
      def option_terms
        @option_terms ||= Regexp.union( 
          *{
            :mode => [:all, :any]
          }.map {|key, value| /(#{key})#{separator}(#{value.join('|')})/i}
        )
      end
      
      def presence_detector_escaped
        @presence_detector_escaped ||= Regexp.escape(presence_detector)
      end
      
      def presence_detector
        @presence_detector ||= (SearchMagic.config.presence_detector || '?')
      end
      
      def separator
        @separator ||= Regexp.escape(SearchMagic.config.selector_value_separator || ':')
      end
      
      def default_search_mode
        Regexp.escape(([SearchMagic.config.default_search_mode.to_s] & %w{all any}).first || 'all')
      end
      
      def create_searchables
        stack, visited, fields = [StackFrame.from_type(self)], Set.new, []
        until stack.empty?
          current = stack.shift
          unless visited.include?(current.token)
            visited |= [current.token, current.inverse_token]
            current.target_type.searchable_fields.each do |field_name, options|
              next unless current.wants_field?(field_name)
              path = current.path.clone + [Breadcrumb.new(field_name, options)]
              if association = current.target_type.reflect_on_association(field_name)
                stack << StackFrame.new(current.target_type, association, path)
              else
                fields << Metadata.new(:type => current.target_type.fields[field_name.to_s].try(:type) || Object, :through => path, :options => options)
              end
            end
          end
        end
        
        fields.index_by(&:name)
      end
    end
    
    def values_matching(pattern)
      options, pattern = self.class.strip_option_terms_from(pattern)
      terms = self.class.terms_for(pattern)
      r = Regexp.union(*terms)
      searchable_values.grep(r)
    end
  
    private
    
    def update_searchable_values
      # self.class.searchables.values.each do |metadata|
      #   
      # end
      self.searchable_values = self.class.searchables.values.map {|metadata| metadata.searchable_value_for(self)}.flatten
      self.svalues = self.searchable_values.map {|sv| SearchableValue.new(word: sv)}
      
      # self.svalues = self.class.searchables.values.map {|metadata| }
    end
    
    def update_arrangeable_values
      self.arrangeable_values = Hash[*self.class.searchables.map {|key, metadata|
        [key, metadata.arrangeable_value_for(self)]
        }.flatten(1)]
    end
    
    def update_associated_documents
      self.class.inverse_searchables.each do |relation_name|
        relation = send(relation_name)
        Array.wrap(relation).each(&:save!)
      end
    end
  end
end