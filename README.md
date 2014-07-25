# AtomicArrays

AtomicArrays is a lightweight gem that aims to assist ActiveRecord with PostgreSQL array operations by offering a couple simple methods to update arrays in the database and the instance that it is called on. These methods are atomic in nature because they update the arrays in the database without relying on the current object's instantiated arrays.

## Installation

Add this line to your application's Gemfile:

    gem 'atomic_arrays'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install atomic_arrays

## Usage
This gem is very simple to use. After installing the gem, include it in your ActiveRecord-descended class. Example:
```ruby
class User < ActiveRecord::Base
  include AtomicArrays
end
```
Make sure that you have specified the array field in your migrations. Example:
```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, force: true do |t|
      t.string  :name
      t.text    :hobbies,      array: true,  default: []   # This is an array of strings
      t.integer :comment_ids,  array: true,  default: []   # This is an array of ints
    end
  end
end
```

This will give you a couple of instance methods used in updating and getting arrays. The first argument of each method is the targeted array attribute/column and the second is the value/values.

### atomic_append(arraycolumn, value)
atomic_append will take a single value to append it on to the end of the specified PG array. Example:
```ruby
user = User.find(1)
# => <#User id: 1, hobbies: ["Basketball", "Racing"]>
user.atomic_append(:hobbies, "Eating")
# => <#User id: 1, hobbies: ["Basketball", "Racing", "Eating"]>  # "Eating" was appended to the array in the db.
```

### atomic_remove(arraycolumn, value)
atomic_remove will remove a single value from the specified PG array. It should be noted that the PG array "remove" function removes ALL occurences of that value, therefore this method does as well. Example:
```ruby
user = User.find(2)
# => <#User id: 2, friend_ids: [12, 34, 89]>
user.atomic_remove(:friend_ids, 12)
# => <#User id: 2, friend_ids: [34, 89]>  # 12 was removed from the array in the db.
```

### atomic_cat(arraycolumn, valuearray)
atomic_cat will concatenate an array of values with the specified PG array. Example:
```ruby
user = User.find(2)
# => <#User id: 2, friend_ids: [34, 89]>
user.atomic_cat(:friend_ids, [34, 30, 56, 90])
# => <#User id: 2, friend_ids: [34, 89, 34, 30, 56, 90]>  # All four values were concatenated with the array in the db.
```

### atomic_relate(arraycolumn, relatedclass, limit=100)
This method is a little odd and unorthodox with a relational db. It assists with querying a denormalized db. Let's say your `users` table has an array column called `blog_ids` and you also have a `blogs` table with each row having an id, like normal. Every time a `User` creates a blog, you could append that blog id to your user's `blog_ids` column. When relating your user to his/her blogs (`one->many`), rather than scanning the `blogs`.`user_id` column for your user's id, you could potentially just use this method to grab all of his/her blogs in a single query, without scanning a table. Example:
```ruby
user = User.find(2)
# => <#User id: 2, blog_ids: [4, 16, 74]>
user.atomic_relate(:blog_ids, Blog)
# => [
#     <#Blog id: 4, body: "This is my blog!">,
#     <#Blog id: 16, body: "This is my other blog!">,
#     <#Blog id: 74, body: "This is my third blog!">
#    ]
```
This method is extremely performant, especially with large tables, because it uses a subquery to grab all of the user's `blog_ids` then immediately `unnests` the ids `IN` the primary ids of the `blogs` table. The subquery that this method employs has nearly zero overhead on performance. The power of this method really shows itself with (`many->many`) relationships. For instance, let's say each `Blog` has many authors and each `User` authors many blogs. Instead of having a `blog_users` join table, you can potentially just store all of the blogs' `user_ids` in one of its columns and the users' `blog_ids` on one of their columns. Then you could relate them by using `atomic_relate`.

While denormalizing using arrays may sound like an excellent performance prospect, there are a couple downsides. For instance, with the aformentioned (`many->many`) relationship, you will not be able to store any other attributes normally associated with a join table, such as an `edited_at` timestamp. Another downside is that arrays are much harder to query, even with a GIN index. Also, it should also be noted that PostgreSQL still has very few features involving arrays, including foreign ids. Arrays should NOT be seen as a direct replacement for (`x->many`) tables/keys, but rather a very performant solution if your database NEEDS to be denormalized.


## Expound on this gem's assistance with atomicity.
So be it! All methods in this gem share the same first argument. When you pass the array column name as the first argument, such as `user.atomic_append(:sports, "Golf")`, it doesn't call the instance's attribute with that name, but rather ignores it, updates the array in the database, then updates the instance's array with the returned columns. What does this mean?

Here's an example of nonatomic arrays. Pretend the code on the left and right are happening at the same time:
```ruby
user = User.find(1)                          |   user = User.find(1)
# => <#User id: 2, blog_ids: [4, 16]>        |   # => <#User id: 2, blog_ids: [4, 16]>
user.blog_ids += [20]                        |   ...  
# => <#User id: 2, blog_ids: [4, 16, 20]>    |   ...
...                                          |   user.name += ["John"]
user.save                                    |   # => <#User id: 2, names: ["John"], blog_ids: [4, 16]>
# => <#User id: 2, blog_ids: [4, 16, 20]>    |   user.save
...                                          |   # => <#User id: 2, names: ["John"], blog_ids: [4, 16]>
```
The same user was being updated on both the left and right, and because the instance on the right side was saved last, it over-wrote the left side's added `blog_id` with its originally instantiated array.

Here's how this gem would work in the same situation.
```ruby
user = User.find(1)                          |   user = User.find(1)
# => <#User id: 2, blog_ids: [4, 16]>        |   # => <#User id: 2, blog_ids: [4, 16]>
user.atomic_append(:blog_ids 20)             |   ...
# => <#User id: 2, blog_ids: [4, 16, 20]>    |   ...
...                                          |   user.atomic_append(:name, "John")
...                                          |   # => <#User id: 2, names: ["John"], blog_ids: [4, 16, 20]>
```
The user will now have both of the updated arrays because this gem's methods append the value to the raw data array in the db first, then return the rows and re-hydrate the instance.

## Other

Apologies for any syntax highlighting or grammar issues above.

There is also a class method that this gem uses internally called `execute_and_wrap`. It was heavily influenced by `find_by_sql` in ActiveRecord, so thank you to the Rails guys.

This gem is focused on being both lightweight and performance-oriented. The entire gem is only about fifty lines of actual code. I tried to make the API as simple and predictable as possible. It was tested against Ruby-2.1.0. If you are looking to use the JRuby-AR adapter, this gem is very easy to replicate and modify to fit with the JRuby-AR adapter. I tried it with an earlier iteration of this gem and had no problems adapting it, but I have not tested this version of the gem with JRuby.


If you find any issues or have any suggestions to improve this gem, open an issue!



## Contributing

1. Fork it ( https://github.com/twincharged/atomic_arrays/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
