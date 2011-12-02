# SearchMagic

SearchMagic provides full-text search capabilities to [mongoid](http://github.com/mongoid/mongoid) documents, 
embedded documents, and referenced documents with a clean, consistent, and easy to use syntax. Documents specify
which data they want to expose as searchable; users can then search for these documents in either a broad or
in a targeted manner.

## Installation

SearchMagic is built on top of mongoid; in all likelihood, it will only work with versions greater than or equal
to *2.0.0*. The project can be installed as a gem on a target system:

```
gem install search_magic
```

For environments where bundler is being used, it can be installed by adding the following to your Gemfile and
running `bundle`.

```
gem 'search_magic'
```

Please check the [rubygems project](http://rubygems.org/gems/search_magic) for the current version.

## Getting Started

### Making a document searchable

Got a document you want to add full text search capabilities to? Great! A few simple steps are all that are needed
to get you up and running.

1. Include the **SearchMagic** module into your document!
2. Tell SearchMagic about the data within your document you want to be searchable.
3. ????
4. Profit!

Let's say we have a document for storing addresses in the database. The model might look a little something like
the following: 

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

This boring little document is currently not searchable. However, with a splash of magic, we can make this document
yield up its secrets to anyone who cares search for them.

First up: include the **SearchMagic** module:

```ruby
class Address
  include Mongoid::Document
  include SearchMagic
  #...
end
```

This will extend the document with a small suite of utility methods and capabilities, which will be covered later on.
For now, the important thing to note is that merely adding in the module will not actually make anything searchable. 
Full text search is an opt-in process, which means that you have complete control over which data you expose to prying
eyes.

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

We'll meet search_on a bit latter; just know for now that it is the method you call to register fields with the gem. In
the previous example, we made each of the four fields of the document searchable. The great news is that the exact same
process is used for virtual properties and associations.

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

Sure, marking up your data to make it searchable through SearchMagic is simply *fascinating*, but how do we go about
actually searching the documents? Through one of the utility methods SearchMagic bundles in: search_for.

```ruby
Address.search_for("Los Angeles CA")
```

The preceding example is search at its most simplistic: trawling over the addresses, returning any which happen to have
the values "Los", "Angeles", and "CA" somewhere within their searchable fields. Simplistic? Why, yes! SearchMagic also
allows any search term within the query pattern to target any specific searchable field on that document. For example,
what if we wanted to ensure that the text, "CA", only matched values coming from the :state field? Simple!

```ruby
Address.search_for("state:CA")
```

That is, any term within the query pattern can specify a **selector** to specify which field you want to limit that term
to. You can mix and match simple and complex terms within a single query: SearchMagic thrives on that sort of thing.

```ruby
Address.search_for("Los Angeles state:CA")
```

It is also possible to have multiple terms target the same field (as long as that makes semantic sense). 
The result set returned by SearchMagic will contain all documents which have every term within it, be it simple or complex.

```ruby
Address.search_for("city:Los city:Angeles state:CA")
# Or, equivalently...
Address.search_for("city:'Los Angeles' state:CA")
```

As the previous example also shows, SearchMagic supports a shorthand notation for combining multiple terms together which
are targeted to a specific field. Note that nothing is guaranteed about the contiguity of the terms when searched like this;
the shorthand simply makes it a bit easier to find documents which have all the terms listed.

Finally, it should be noted that all searches performed by SearchMagic are case-insensitive. Any of the previous examples
could just as easily have been written with any mixture of cases, either for the selectors or for the values.

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

Arrange currently can take up to two parameters; the first specifies which searchable field you want to order the result
set by, while the second specifies the direction of the ordering. (This defaults to ascending.)

Mongoid already come with a mechanism for [ordering documents](http://mongoid.org/docs/querying/criteria.html#order_by),
so why does SearchMagic provide its own variant? Well, **arrange** is actually built on top of order_by. What it brings to
the table is the ability to sort documents based off of any of the searchable fields a document can see --- including those
coming from virtual attributes and associations.

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

This could be useful for ensuring that some text value you are dealing with is actually a searchable. For example, if you
wanted to support sortable columns for a searchable document in a controller within a Rails app, you could use the 
keys from the searchables hash to ensure you are not passing anything wonky to **arrange**. 

The second method is mentioned mostly to bring to attention the potential cost of SearchMagic: to ensure that searching
is speedy and straight-forward, all data marked as searchable is replicated in a marked-up format within the searchable
document. **search_for** constructs its criteria by referencing this particular array. If that type of data replication
is undesirable, SearchMagic might not be the best choice for full text search. Please note that searchable_values is
automatically maintained by the owning document: whenever the document is saved, a callback is invoked which updates the
values. So, under normal usage circumstances, you should not be touching this array, and manually updating it is right out.

Similar caveats exist for **arrangeable_values**. Its main purpose is to enable **arrange** to perform sorting in a
speedy, straight-forward fashion. 

## Global Configuration

For the most part, configuration options are local to the documents and fields they are defined within. However, there
are a few global options which are used across models, which can be altered through global configuration. These options
(okay, for right now, "option", as there is only one) can be accessed through SearchMagic's **config** hash:

```ruby
SearchMagic.config # for global options!
```

Unless otherwise specified, for a Rails environment, it is suggested that these options be set in an initializer.

### :selector_value_separator

SearchMagic stores data in **searchable_values** --- and eventually searches for data from the same location --- by
marking up values with the field from which they originated. While slightly more complicated, this mark-up is
essentially defined as:

```ruby
"#{field_path}#{separator}#{value}"
```

The default separator is a colon, ":", as is rather obvious from the examples shown elsewhere in this document.
This can be changed through the **selector_value_separator** configuration option to whatever makes sense for your
use case:

```ruby
SearchMagic.config.selector_value_separator = '/'
address = Address.search_for("state/ca").first
address.searchable_values # [..., "city/los", "city/angeles", "state/ca", ...]
```

Note that **search_for** will immediately use the new separator value after a change is made to the configuration. However,
no results may be returned, as pre-existing documents will still be using the previously defined separator. To force
an update to your models, just re-save each one, and the **searchable_values** should be updated.

Setting **selector_value_separator** to **nil** results in the same behavior as setting it to ':'.

## A little more depth...

### search_on

As described earlier in the document, fields are marked as searchable through use of the **search_on** class method, which
takes one required parameter and a set of options. The required parameter specifies a method on the document which returns
a value to be searched on. Mostly. The options allow for certain aspects of the library's default behavior to be overridden
according to taste. The first parameter is also used by SearchMagic as the field name by which values in **searchable_values**
are marked-up and searched by.

Options currently supported by search_on are:

1. **as**: specifies a text value to override the default field name behavior; this allows a field to masquerade as something
  else when its slumming about your interface:
  
  ```ruby
  search_on :postal_code, :as => :zip_code
  ```
2. **keep_punctuation**:
3. **skip_prefix**:
4. **only**:
5. **except**:

#### search trees
##### cyclic searches
### search_for
#### natural language date processing via chronic
### arrange
## Problems? Comments?

Feel free to add an [issue on GitHub](search_magic/issues) or fork the project and send a pull request. 
I’m always looking for new ways of bending hardware to my will, so suggestions are welcome.


### :search_on

Fields that are made searchable by ***:search_on*** have their values cached
in an embedded array within each document. This array,
***:searchable_values***, should contain entries of the
form `field_name:instance_value`. The selector, `field_name`, represents a
filter which can be used when searching to narrow the search space; it
can be manually renamed by passing the **:as** option to ***:search_on***:

```ruby
search_on :post_code, :as => :zip_code 
```

The example in the previous section showcased using ***:search_on*** on basic
**Mongoid::Document** fields. It can, however, be used on both embedded and
referenced documents, as seen in the next example.

```ruby
class Person
 include Mongoid::Document
 include SearchMagic
 field :name
 embeds_one :address

 search_on :name
 search_on :address
end

Person.search_for("address_state:ca") # Find all people with an address in california
```

When an association is searched on, all of its searchable fields are
automatically made searchable in the first document. In the previous
example, this means that the four fields of **Address**,
`[:street, :city, :state, :post_code]` are now searchable from within
**Person**. As such, each association will end up adding entries into
the ***:searchable_values*** array. The searchable fields which are
introduced from an association can be restricted by use of the **:only**
and **:except** options, which may either take an array or an individual
field name:

```ruby
search_on :address, :only => [:street, :state]
search_on :address, :except => :post_code
```

By default, an association’s fields will be prefixed by name of the
association. Therefore, the previous example would add entries to
***:searchable_values*** with the selectors
`[:address_street, :address_city, :address_state, :address_post_code]`.
The **:as** option alters the prefix:

```ruby
search_on :address, :as => :location # results in :location_street, :location_city, ...
```

Another option, ***:skip_prefix***, can be used to simplify this prefixing process: turning
on this option will cause all searchables coming from the association to lack that association's
prefix, as in the following example.

```ruby
search_on :address, :skip_prefix => true # results in :street, :city, ...
```

:skip_prefix and :as cannot be used concurrently: :skip_prefix will
always take precedence. Note that :skip_prefix should only be used on associations and not on
regular fields.

Values added to ***:searchable_values*** automatically are split on
whitespace and have their punctuation removed. For most cases, searches
performed on models are not going to need punctuation support. However,
if it is desired to keep the punctuation present on a particular field,
that can easily be done through the **:keep_punctuation** option:

```ruby
class Asset
  include Mongoid::Document
  include SearchMagic
  field :tags, :type => Array

  search_on :tags, :keep_punctuation => true
end
```

Now all entries within ***:searchable_values*** for **:tags** will retain
meaningful punctuation. The previous example is interesting for another
reason: embedded arrays are handled specially. Specifically, the
selector for an embedded array will be singularized. In the case of the
previous example, this would result in a selector of “tag”.

```ruby
asset = Asset.create(tags: %w{foo b.a.r b'az})
asset.searchable_values # ["tag:foo", "tag:b.a.r", "tag:b'az"]

Asset.search_for("tag:b.a.r") # notice that the selector for searching is singularized
```

Two documents may search on each other’s fields; doing so will cause
each document to only search upon those fields stemming from itself
once. Given the following example, **Foo** would be able to search on
`[:name, :bar_value]`, while **Bar** would be able to search on
`[:value, :foo_name]`.

```ruby
class Foo
  include Mongoid::Document
  include SearchMagic
  field :name
  references_many :bars
  search_on :name
  search_on :bars
end

class Bar
  include Mongoid::Document
  include SearchMagic
  field :value
  referenced_in :foo
  search_on :value
  search_on :foo
end

Foo.searchables.keys # [:name, :bar_value]
Bar.searchables.keys # [:value, :foo_name]

Foo.search_for("name:foo bar_value:20")
Bar.search_for("value:20 foo_name:foo")
```

Finally, it should be noted that nesting of searchable documents is
possible. If a given document searches on an association with another
document which, in and of itself, searches on a third document, the
first automatically has access to the third document’s searchable
fields.

```ruby
class Part
  include Mongoid::Document
  include Mongoid::Timestamps
  include SearchMagic
  field :serial
  references_in :part_number

  search_on :serial
  search_on :part_number, :skip_prefix => true
end

class PartNumber
  include Mongoid::Document
  include SearchMagic
  field :value
  references_many :parts
  referenced_in :part_category

  search_on :number
  search_on :part_category, :as => :category
end

class PartCategory
  include Mongoid::Document
  include SearchMagic
  field :name
  references_many :part_numbers

  search_on :name
end

Part.searchables.keys         # [:serial, :number, :category_name]
PartNumber.searchables.keys   # [:number, :category_name]
PartCategory.searchables.keys # [:name] 
```

**PartNumber** will be able to search on both ***:number*** and
***:category_name***. **Part**, on the other hand, will absorb all of the
searchable fields of PartNumber, including its associations. So, it can
be searched on ***:serial***, ***:number***, and ***:category_name***.

### :search_for

Searching a model with SearchMagic is simple: each model gains a class
method called ***:search_for*** which accepts one parameter, the search
pattern. This method is a [mongoid scope](http://mongoid.org/docs/querying/scopes.html); 
it will always return a [criteria](http://mongoid.org/docs/querying/criteria.html) object
after executing. As such, it plays nicely with other scopes on your models.

SearchMagic expects the incoming *pattern* to be a string containing
whitespace delimited phrases. Each phrase can either be a single word,
or a *selector:value* pair. Multiple phrases will narrow the search
field: each additional phrase places an additional requirement on a
matching document. Single word phrases are matched across all entries in
a model’s ***:searchable_values*** array. The pairs, on the other hand,
restrict the search for *value* against only those entries which match
*selector*. In either case, *word* or *value* may contain fragments of
whole entries stored within ***:searchable_values***.

Using the models defined in the previous section, the following searches
are all perfectly valid:

```ruby
Part.search_for("table")                # full text search on "table"
Part.search_for("category_name:table")  # restricts the search for "table" to "category_name"
Part.search_for("bike serial:b1234")    # full text search on "bike", with an extra requirement that the serial be "b1234"
```

As ***:search_for*** is a scope, it can be called on any previous scope
within the call chain:

```ruby
Part.where(:created_at.gt => 1.day.ago.time).search_for("table")
```

***:search_for*** can be called multiple times within the same scope
chain. Doing so will append each successive pattern to the previous
searches. Effectively, this is the same as performing a single
***:search_for*** with whitespace delimited terms in the pattern. To
make such expressions slightly more readable, ***:search_for*** is
aliased as ***:and_for***:

```ruby
Part.search_for("bike").and_for("serial:b1234") # is functionally equivalent to...
Part.search_for("bike serial:b1234")
```

### :arrange

SearchMagic also provides a utility scope for arranging the model by the
searchables defined within it. This method, ***:arrange***, has one
required parameter specifying the searchable to sort on and one optional
parameter specifying the sort direction. (If the second parameter is
omitted, it will default to ascending.)

```ruby
Part.arrange(:serial)               # arrange parts by their serial
Part.arrange(:serial, :asc)         # same as last example
Part.arrange(:category_name, :desc) # arrange the parts in descending order by :category_name
```

As mentioned, ***:arrange*** is a scope, so it can be chained with other
scopes on a given model:

```ruby
Part.search_for("category_name:table").arrange(:serial, :asc)
```
