# AtomicArrays

AtomicArrays aims to assist ActiveRecord with updating Postgres arrays by offering a couple simple methods to change arrays in both the database and the instance it is called on. These methods are atomic in nature because they update the arrays in the database without relying on the current object's instantiated arrays.

## Installation

Add this line to your application's Gemfile:

    gem 'atomic_arrays'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install atomic_arrays

## Usage
This gem is very simple to use. After installing the gem, include it in your ActiveRecord-descended class. Example:
    class User < ActiveRecord::Base
      include AtomicArrays
    end

Make sure that you have specified the array field in your migrations. Example:
```class CreateUsers < ActiveRecord::Migration
      def change
        create_table :users, force: true do |t|
          t.string  :name
          t.text    :hobbies, array: true, default: []      # This is an array of strings
          t.integer :comment_ids, array: true, default: []  # This is an array of ints
        end
      end
    end```

This will give you a couple of instance methods used in updating and getting arrays.

### atomic_append




    
    
    

## Contributing

1. Fork it ( https://github.com/[my-github-username]/atomic_arrays/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
