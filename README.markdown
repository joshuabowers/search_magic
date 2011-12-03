# SearchMagic

SearchMagic provides full-text search capabilities to [mongoid](http://github.com/mongoid/mongoid) documents, embedded documents, and referenced documents with a clean, consistent, and easy to use syntax. Documents specify which data they want to expose as searchable; users can then search for these documents in either a broad or in a targeted manner.

## Installation

SearchMagic is built on top of mongoid; in all likelihood, it will only work with versions greater than or equal to *2.0.0*. The project can be installed as a gem on a target system:

```
gem install search_magic
```

For environments where bundler is being used, it can be installed by adding the following to your Gemfile and running `bundle`.

```
gem 'search_magic'
```

Please check the [rubygems project](http://rubygems.org/gems/search_magic) for the current version.

## Getting Started

### Making a document searchable

Got a document you want to add full text search capabilities to? Great! A few simple steps are all that are needed to get you up and running.

1. Include the **SearchMagic** module into your document!
2. Tell SearchMagic about the data within your document you want to be searchable.
3. ????
4. Profit!

Let's say we have a document for storing addresses in the database. The model might look a little something like the following: 

```ruby
class Address
  include Mongoid::Document
  field :street
  field :city
  field :state
  field :postal_code
  embedded_in :addressable, polymorphic: true
end
```

This boring little document is currently not searchable. However, with a splash of magic, we can make this document yield up its secrets to anyone who cares search for them.

First up: include the **SearchMagic** module:

```ruby
class Address
  include Mongoid::Document
  include SearchMagic
  #...
end
```

This will extend the document with a small suite of utility methods and capabilities, which will be covered later on. For now, the important thing to note is that merely adding in the module will not actually make anything searchable. Full text search is an opt-in process, which means that you have complete control over which data you expose to prying eyes.

So how do we ask the gem to work its magic? By asking it to search_on particular fields within the document!

```ruby
class Address
  #...
  search_on :street
  search_on :city
  search_on :state
  search_on :postal_code
end
```

We'll meet search_on a bit latter; just know for now that it is the method you call to register fields with the gem. In the previous example, we made each of the four fields of the document searchable. The great news is that the exact same process is used for virtual properties and associations.

```ruby
class Address
  #...
  def random_letter
    ('a'..'z').sample
  end
  
  search_on :addressable
  search_on :random_letter
end
```

As long as it is invokable as an instance method on the document, SearchMagic can make it searchable.

### Example searches on a searchable document

Sure, marking up your data to make it searchable through SearchMagic is simply *fascinating*, but how do we go about actually searching the documents? Through one of the utility methods SearchMagic bundles in: search_for.

```ruby
Address.search_for("Los Angeles CA")
```

The preceding example is search at its most simplistic: trawling over the addresses, returning any which happen to have the values "Los", "Angeles", and "CA" somewhere within their searchable fields. Simplistic? Why, yes! SearchMagic also allows any search term within the query pattern to target any specific searchable field on that document. For example, what if we wanted to ensure that the text, "CA", only matched values coming from the :state field? Simple!

```ruby
Address.search_for("state:CA")
```

That is, any term within the query pattern can specify a **selector** to specify which field you want to limit that term to. You can mix and match simple and complex terms within a single query: SearchMagic thrives on that sort of thing.

```ruby
Address.search_for("Los Angeles state:CA")
```

It is also possible to have multiple terms target the same field (as long as that makes semantic sense). The result set returned by SearchMagic will contain all documents which have every term within it, be it simple or complex.

```ruby
Address.search_for("city:Los city:Angeles state:CA")
# Or, equivalently...
Address.search_for("city:'Los Angeles' state:CA")
```

As the previous example also shows, SearchMagic supports a shorthand notation for combining multiple terms together which are targeted to a specific field. Note that nothing is guaranteed about the contiguity of the terms when searched like this; the shorthand simply makes it a bit easier to find documents which have all the terms listed.

Finally, it should be noted that all searches performed by SearchMagic are case-insensitive. Any of the previous examples could just as easily have been written with any mixture of cases, either for the selectors or for the values.

```ruby
Address.search_for("city:'Los Angeles' state:CA")
# Is the same as:
Address.search_for("city:'los angeles' state:ca")
```

To sum, if you want to search for data across a document, use the *search_for* method! That's what it is there for!

### Arranging data

Want to arrange your documents after you have searched for them? Look no further than the provided **arrange** method!

```ruby
Address.search_for("state:ca").arrange(:city)
```

Arrange currently can take up to two parameters; the first specifies which searchable field you want to order the result set by, while the second specifies the direction of the ordering. (This defaults to ascending.)

Mongoid already comes with a mechanism for [ordering documents](http://mongoid.org/docs/querying/criteria.html#order_by), so why does SearchMagic provide its own variant? Well, **arrange** is actually built on top of order_by. What it brings to the table is the ability to sort documents based off of any of the searchable fields a document can see --- including those coming from virtual attributes and associations.

We'll revisit this topic in more detail after looking at how associations work.

### Querying docs about their searchables

SearchMagic provides some utility methods which can be used to find out information about a document's searchable fields:

1. **searchables**: a class method containing a hash of metadata pertaining to all searchable fields;
2. **searchable_values**: an instance method containing an array of all values the document can be found by.
3. **arrangeable_values**: an instance method containing a hash of all values the document can be sorted by.

For the suggested standard usage of the gem, the first method might only be interesting for the keys of the hash it stores:

```ruby
Address.searchables.keys # => [:street, :city, :state, :postal_code]
```

This could be useful for ensuring that some text value you are dealing with is actually a searchable. For example, if you wanted to support sortable columns for a searchable document in a controller within a Rails app, you could use the keys from the searchables hash to ensure you are not passing anything wonky to **arrange**. 

The second method is mentioned mostly to bring to attention the potential cost of SearchMagic: to ensure that searching is speedy and straight-forward, all data marked as searchable is replicated in a marked-up format within the searchable document. **search_for** constructs its criteria by referencing this particular array. If that type of data replication is undesirable, SearchMagic might not be the best choice for full text search. Please note that searchable_values is automatically maintained by the owning document: whenever the document is saved, a callback is invoked which updates the values. So, under normal usage circumstances, you should not be touching this array, and manually updating it is right out.

Similar caveats exist for **arrangeable_values**. Its main purpose is to enable **arrange** to perform sorting in a speedy, straight-forward fashion. 

## Global Configuration

For the most part, configuration options are local to the documents and fields they are defined within. However, there are a few global options which are used across models, which can be altered through global configuration. These options (okay, for right now, "option", as there is only one) can be accessed through SearchMagic's **config** hash:

```ruby
SearchMagic.config # for global options!
```

Unless otherwise specified, for a Rails environment, it is suggested that these options be set in an initializer.

### :selector_value_separator

SearchMagic stores data in **searchable_values** --- and eventually searches for data from the same location --- by marking up values with the field from which they originated. While slightly more complicated, this mark-up is essentially defined as:

```ruby
"#{field_path}#{separator}#{value}"
```

The default separator is a colon, ":", as is rather obvious from the examples shown elsewhere in this document. This can be changed through the **selector_value_separator** configuration option to whatever makes sense for your use case:

```ruby
SearchMagic.config.selector_value_separator = '/'
address = Address.search_for("state/ca").first
address.searchable_values # [..., "city/los", "city/angeles", "state/ca", ...]
```

Note that **search_for** will immediately use the new separator value after a change is made to the configuration. However,  no results may be returned, as pre-existing documents will still be using the previously defined separator. To force an update to your models, just re-save each one, and the **searchable_values** should be updated.

Setting **selector_value_separator** to **nil** results in the same behavior as setting it to ':'.

## A little more depth...

### Search Graph

Many of the examples provided to this point have been rather boring, focusing as they have on a single document; yet, there have been a few allusions to being able to use SearchMagic to perform full text searches across associations between documents. How about we finally get around to expanding upon that concept, and showcase some simple (though, hopefully, useful!) examples.

SearchMagic builds a hash of all searchable fields for a document; this is done the first time that the **searchables** method is called. (Don't worry about having to manually call it; saving documents automatically does this as does searching.) The gem constructs an in memory representation of a subset of the document graph that exists for the document it is currently processing; this subset, called the *search graph*, is synonymous with the searchables array. It represents the list of fields that are reachable from the current document, along with a trail of breadcrumbs SearchMagic needs to follow to access those fields. Generally, that is not *terribly* important to be aware of. It is important to be aware that this process of building the searchables treats associations in a special way: when specifying that you want to search on an association, all of the associated document's searchables are automatically added to the first document. Let's illustrate this with an example, yeah?

```ruby
class Game
  include Mongoid::Document
  include SearchMagic
  field :title, :type => String
  field :price, :type => Float
  field :high_score, :type => Integer
  field :released_on, :type => Date
  references_and_referenced_in_many :players
  referenced_in :developer
  
  search_on :title
  search_on :price
  search_on :high_score
  search_on :developer
end

class Developer
  include Mongoid::Document
  include SearchMagic
  field :name
  field :net_worth
  field :opened_on, :type => Date
  references_many :games
  
  search_on :name
  search_on :opened_on
end
```

Here we have two documents which are in a referential relationship with one another. As can be seen from the first document, Game is requesting that it have the ability to search for instances of its documents by their title, their price, their high score, and their developer. But wait, **developer** is an association! So, what does that mean for Game? By what is it really searchable? Let's take a look at its searchables to find out:

```ruby
Game.searchables.keys # [:title, :price, :high_score, :developer_name, :developer_opened_on]
```

See how the searchables from Developer were automatically added to Game? Only those fields which are within Developer's search graph will be subsumed into Game. Notice how there is a field and an association within Document which are not being searched on? Those are not added to Game's searchables.

Take another look at Game's searchables. Notice the way that fields coming from an association are handled? They are receive a prefix equivalent to the name of the association. This allows SearchMagic to build rather complex search graphs without having to necessarily worry about weird aliasing issues. The values coming from these fields will be stored within each Game instance's **searchable_values** with this prefixed name, and **search_for** will likewise be expecting the use of the prefixed names.

```ruby
game = Game.search_for("developer_name:bethesda title:skyrim").first
game.searchable_values # [..., "developer_name:bethesda", "title:skyrim", ...]
```

One level of searching is pretty neat. But what if you want to search deeply across your document graph? Let's extend this section's example be adding another document:

```ruby
class Player
  include Mongoid::Document
  include SearchMagic::FullTextSearch
  field :name
  references_and_referenced_in_many :games
  
  search_on :name
  search_on :games
end
```

Here, we have Player documents which can search on games. Player's searchables would look like the following:

```ruby
Player.searchables.keys # [:name, :game_title, :game_price, :game_high_score, :game_developer_name, :game_developer_opened_on]
```

There are three important things to note about this:

1. Player subsumed all of Game's searchables, including everything coming from Developer.
2. All of the searchables coming from **games** are prefixed with the singular form of the association name.
3. This includes even those searchables which are, themselves, representative of an association.

SearchMagic should be able to handle as complex of a document graph as you care to throw at it. (*SearchMagic and its developer are not liable for computer's exploding while attempting to process crazy large document graphs.*) While the running example is fairly linear, you are not limited to simple paths like this: you can have search graphs which are as broad and deep as you like. Which leads us to the next topic.

#### Cyclic Searches

What happens when we have two documents which, either directly or indirectly, end up searching on each other? Let's modify one of the documents from the last section and see what happens:

```ruby
class Developer
  include Mongoid::Document
  include SearchMagic
  field :name
  field :net_worth
  field :opened_on, :type => Date
  references_many :games
  
  search_on :name
  search_on :opened_on
  search_on :games
end
```

Alright, so Developer now searches on games. We have formed a direct cyclic search: Game and Developer search on each other. What do their searchables look like?

```ruby
Game.searchables.keys       # [:title, :price, :high_score, :developer_name, :developer_opened_on]
Developer.searchables.keys  # [:name, :opened_on, :game_title, :game_price, :game_high_score]
```

As you can see, Game remains the same, while Developer gains a few extra searchable fields. The process which determines the search graph for a document is smart enough to keep track of previously visited documents within the graph; when such a cycle is detected, the revisited document is effectively ignored. This means that a given document will always only contribute its fields once to the searchables of another document. 

### arrange

Now that we've explored the search graph, its time to revisit arranging data. Any values coming from a document's searchables are replicated in a hash within that document: its **arrangeable_values**. Will slightly costly, when it comes to replicating data across a document hierarchy, it provides a very clever trick: it allows a document to be sorted by any of its searchables, regardless of where they come from. It matters not whether the searchable is a field on the defining document or on an association. It matters not whether a field is coming from a referenced or an embedded document. All are welcome, and all are handled exactly the same.

Using the running examples from the last sections, let's explore some example usage:

```ruby
Game.arrange(:title)            # Sort games based off of their title
Game.arrange(:developer_name)   # Sort games based off the name of their developer
Developer.arrange(:name)        # Sort developers based off of their name
Developer.arrange(:game_title)  # Sort developers based off the names of their games
```

This method is a [mongoid scope](http://mongoid.org/docs/querying/scopes.html); it will always return a [criteria](http://mongoid.org/docs/querying/criteria.html) object after executing. As such, it plays nicely with other scopes on your models.

### search_on

As described earlier in the document, fields are marked as searchable through use of the **search_on** class method, which takes one required parameter and a set of options. The required parameter specifies a method on the document which returns a value to be searched on. Mostly. The options allow for certain aspects of the library's default behavior to be overridden according to taste. The first parameter is also used by SearchMagic as the field name by which values in **searchable_values** are marked-up and searched by.

Options currently supported by search_on are:

1. **as**: specifies a text value to override the default field name behavior; this allows a field to masquerade as something else when its slumming about your interface:
  
    ```ruby
    search_on :postal_code, :as => :zip_code
    ```
  
    In the preceding example, the field specified by **postal_code** will be represented as **zip_code** within **searchable_values**.
2. **keep_punctuation**: by default, all punctuation for a field is automatically replaced with whitespace when values are stored in **searchable_values**; this can be turned off for a particular field by turning on **keep_punctuation**.

    ```ruby
    search_on :postal_code, :keep_punctuation => false  # e.g. ["postal_code:12345", "postal_code:6789"]
    search_on :postal_code, :keep_punctuation => true   # e.g. ["postal_code:12345-6789"]
    ```
3. **skip_prefix**: as described previously, fields bubbling up the search graph are prefixed with extra information. This prefix is the name of the association as seen by the class defining the search. So, for example:

    ```ruby
    class Foo
      #...
      field :name
      embeds_many :bars
      
      search_on :name
      search_on :bars
    end
    
    class Bar
      #...
      field :name
      
      search_on :name
    end
    
    Foo.searchables.keys # [..., :name, :bar_name, ...]
    ```
    
    Which is to say, that **Foo** has a searchable on one of its local fields, and a searchable on a field coming from **Bar**. This second searchable is automatically prefixed with "bar_". This prefix, for only this level of the search graph, can be skipped through use of **skip_prefix**. If the above exampled were modified like so:
    
    ```ruby
    search_on :bars, :skip_prefix => true
    ```
    
    Then anything coming through **bars** will not have any prefix. (This particular example is bad; don't do it! It would result in two searchables with the field name of "name", which defeats the awesome of SearchMagic.) Note that **skip_prefix** takes precedence over **as**; the two cannot be used together in any meaningful sense. Also, this option is really only intended for use on associations; regular fields should not have prefixes skipped.
4. **only** / **except**: when building its search graph, SearchMagic will automatically include any searchable fields from an associated document into the current document. The fields that are included can be controlled through the **only** and **except** options. Only specifies that only the specified fields are gobbled up; except specifies that everything but the specified fields are included. These two parameters can be used concurrently, although that would be somewhat strange. They both can take either a single field name or an array of field names.

    ```ruby
    search_on :bars, :only => :name
    search_on :bars, :except => [:name, ...]
    ```

### search_for

Searching a model with SearchMagic is simple: each model gains a class method called ***search_for*** which accepts one parameter, the search pattern. Like **arrange**, this method is a mongoid scope, and will always return a criteria object.

SearchMagic expects the incoming *pattern* to be a string containing whitespace delimited phrases. Each phrase can either be a single word, or a *selector:value* pair. Multiple phrases will narrow the search field: each additional phrase places an additional requirement on a matching document. Single word phrases are matched across all entries in a model’s ***searchable_values*** array. The pairs, on the other hand, restrict the search for *value* against only those entries which match *selector*. In either case, *word* or *value* may contain fragments of whole entries stored within ***searchable_values***.

***search_for*** can be called multiple times within the same scope chain. Doing so will append each successive pattern to the previous searches. Effectively, this is the same as performing a single ***search_for*** with whitespace delimited terms in the pattern. To make such expressions slightly more readable, ***search_for*** is aliased as ***and_for***:

```ruby
Game.search_for("developer_name:bethesda").and_for("title:skyrim") # is functionally equivalent to...
Game.search_for("developer_name:bethesda title:skyrim")
```

#### Natural language date processing via chronic

SearchMagic handles fields which represent temporal data in a special way: anything which is datable can be searched for based off of a (relatively) natural language syntax, provided by [chronic](https://github.com/mojombo/chronic). If ***search_for*** determines that the searchable field being searched for is datable, it will pass *value* to chronic to get a date/time representation. This representation is then converted to text and used for the comparison against ***searchable_values***.

```ruby
Developer.search_for("opened_on:'1 year ago'")
Developer.search_for("opened_on:'January 1986'")
```

Note, in order for the natural language processing to be invoked properly, the *value* part of a search must be wrapped in quotes; multiple occurrences of a datable searchable will be processed separately, rather than as a unit.

## Problems? Comments?

Feel free to add an [issue on GitHub](search_magic/issues) or fork the project and send a pull request. 
I’m always looking for new ways of bending hardware to my will, so suggestions are welcome.
