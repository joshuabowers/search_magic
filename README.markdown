# SearchMagic

SearchMagic provides full-text search capabilities to
[mongoid](http://github.com/mongoid/mongoid) documents, embedded
documents, and referenced documents with a clean, consistent, and easy
to use syntax. Searching can be performed on either word fragments, such
as **foo**, or can use a selector-syntax, **foo:bar**, to target which
fields of the document the search is to be restricted to.

## Installation

SearchMagic is built on top of mongoid; in all likelihood, it will only
work with versions greater than or equal to *2.0.0*. The project can be
installed as a gem on a target system:

```
gem install search_magic
```

For environments where bundler is being used, it can be installed by
adding the following to your Gemfile and running `bundle`.

```
gem 'search_magic'
```

## Getting Started

### Adding FullTextSearch capabilities

Adding FullTextSearch is as simple as including the appropriate module
into a mongoid document and defining which fields are to be searchable.
In the following example, the **SearchMagic::FullTextSearch** module is
included and each field of the model is made searchable.

```ruby
class Address\
 include Mongoid::Document\
 include SearchMagic\
 field :street\
 field :city\
 field :state\
 field :post*code\
 embedded*in :person

search*on :street\
 search*on :city\
 search*on :state\
 search*on :post\_code\
end
```

At this point, **Address** can be searched by calling its
*\*:search*for\*\_ method:

```ruby
Address.search_for("state:ca")
```

It is also possible to sort models on fields which have been marked as
searchable through the ***:arrange*** method:

```ruby
Address.arrange(:state, :asc)
```

### :search\_on

Fields that are made searchable by :search*on have their values cached
in an embedded array within each document. This array,
**:searchable*values**, should contain entries of the
form**field*name:value**. The selector, \*field*name**, represents a
filter which can be used when searching to narrow the search space; it
can be manually renamed by passing the**:as\* option to :search\_on:

```ruby
search_on :post_code, :as => :zip_code 
```

The example in the previous section showcased using :search\_on on basic
**Mongoid::Document** fields. It can, however, be used on fields within
a document which denote an association.

```ruby
class Person\
 include Mongoid::Document\
 include SearchMagic\
 field :name\
 embeds\_one :address

 search*on :name\
 search*on :address\
end
```

When an association is searched on, all of its searchable fields are
automatically made searchable in the first document. In the previous
example, this means that the four fields of **Address**,
`[:street, :city, :state, :post_code]` are now searchable from within
**Person**. As such, each association will end up adding entries into
the **:searchable\_values** array. The searchable fields which are
introduced from an association can be restricted by use of the **:only**
and **:except** options, which may either take an array or an individual
field name:

    search_on :address, :only => [:street, :state]
    search_on :address, :except => :post_code

By default, an association’s fields will be prefixed by name of the
association. Therefore, the previous example would add entries to
**:searchable\_values** with the selectors
`[:address_street, :address_city, :address_state, :address_post_code]`.
The **:as** option alters the prefix:

    search_on :address, :as => :location # results in :location_street, :location_city, ...

It is also possible to prevent the prefix from being added to each
absorbed searchable field through use of the **:skip\_prefix** option:

    search_on :address, :skip_prefix => true # results in :street, :city, ...

:skip*prefix and :as cannot be used concurrently: :skip*prefix will
always take precedence.

Values added to **:searchable\_values** automatically are split on
whitespace and have their punctuation removed. For most cases, searches
performed on models are not going to need punctuation support. However,
if it is desired to keep the punctuation present on a particular field,
that can easily be done through the **:keep\_punctuation** option:

bc.. class Asset\
 include Mongoid::Document\
 include SearchMagic\
 field :tags, :type =\> Array

search*on :tags, :keep*punctuation =\> true\
end

Now all entries within **:searchable\_values** for **:tags** will retain
meaningful punctuation. The previous example is interesting for another
reason: embedded arrays are handled specially. Specifically, the
selector for an embedded array will be singularized. In the case of the
previous example, this would result in a selector of “tag”.

Two documents may search on each other’s fields; doing so will cause
each document to only search upon those fields stemming from itself
once. Given the following example, *Foo* would be able to search on
`[:name, :bar_value]`, while *Bar* would be able to search on
`[:value, :foo_name]`.

bc.. class Foo\
 include Mongoid::Document\
 include SearchMagic\
 field :name\
 references*many :bars\
 search*on :name\
 search\_on :bars\
end

class Bar\
 include Mongoid::Document\
 include SearchMagic\
 field :value\
 referenced*in :foo\
 search*on :value\
 search\_on :foo\
end

Finally, it should be noted that nesting of searchable documents is
possible. If a given document searches on an association with another
document which, in and of itself, searches on a third document, the
first automatically has access to the third document’s searchable
fields.

bc.. class Part\
 include Mongoid::Document\
 include Mongoid::Timestamps\
 include SearchMagic\
 field :serial\
 references*in :part*number

search*on :serial\
 search*on :part*number, :skip*prefix =\> true\
end

class PartNumber\
 include Mongoid::Document\
 include SearchMagic\
 field :value\
 references*many :parts\
 referenced*in :part\_category

search*on :number\
 search*on :part\_category, :as =\> :category\
end

class PartCategory\
 include Mongoid::Document\
 include SearchMagic\
 field :name\
 references*many :part*numbers

search\_on :name\
end

**PartNumber** will be able to search on both *:number* and
*:category*name*. **Part**, on the other hand, will absorb all of the
searchable fields of PartNumber, including its associations. So, it can
be searched on*:serial*,*:number*, and*:category*name*.

### :search\_for

Searching a model with SearchMagic is simple: each model gains a class
method called *\*:search*for\*\_ which accepts one parameter, the search
pattern. This method is a [mongoid
scope](http://mongoid.org/docs/querying/); it will always return a
criteria object after executing. As such, it plays nicely with other
scopes on your models.

SearchMagic expects the incoming *pattern* to be a string containing
whitespace delimited phrases. Each phrase can either be a single word,
or a *selector:value* pair. Multiple phrases will narrow the search
field: each additional phrase places an additional requirement on a
matching document. Single word phrases are matched across all entries in
a model’s *:searchable*values\_ array. The pairs, on the other hand,
restrict the search for *value* against only those entries which match
*selector*. In either case, *word* or *value* may contain fragments of
whole entries stored within *:searchable*values\_.

Using the models defined in the previous section, the following searches
are all perfectly valid:

    Part.search_for("table") # full text search on "table"
    Part.search_for("category_name:table") # restricts the search for "table" to "category_name"
    Part.search_for("bike serial:b1234") # full text search on "bike", with an extra requirement that the serial be "b1234"

As *\*:search*for\*\_ is a scope, it can be called on any previous scope
within the call chain:

    Part.where(:created_at.gt => 1.day.ago.time).search_for("table")

*\*:search*for\*\_ can be called multiple times within the same scope
chain. Doing so will append each successive pattern to the previous
searches. Effectively, this is the same as performing a single
***:search*for**\_ with whitespace delimited terms in the pattern. To
make such expressions slightly more readable, *\*:search*for*** is
aliased as *\*:and*for***:

    Part.search_for("bike").and_for("serial:b1234")

### :arrange

SearchMagic also provides a utility scope for arranging the model by the
searchables defined within it. This method, ***:arrange***, has one
required parameter specifying the searchable to sort on and one optional
parameter specifying the sort direction. (If the second parameter is
omitted, it will default to ascending.)

    Part.arrange(:serial)
    Part.arrange(:serial, :asc) # same as last example
    Part.arrange(:category_name, :desc) # arrange the parts in descending order by :category_name

As mentioned, ***:arrange*** is a scope, so it can be chained with other
scopes on a given model:

    Part.search_for("category_name:table").arrange(:serial, :asc)

## Problems? Comments?

Feel free to add an [issue on GitHub](search_magic/issues) or fork the
project and send a pull request. I’m always looking for new ways of
bending hardware to my will, so suggestions are welcome.
