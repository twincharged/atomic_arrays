require "atomic_arrays"
require "active_record"
require "rspec"
require "yaml"

ActiveRecord::Base.establish_connection(YAML.load_file(File.expand_path("../db/database.yml", __FILE__))["test"])

RSpec.configure do |config|
  config.color = true
  config.tty = true
end


class User < ActiveRecord::Base
  include AtomicArrays
end


class Comment < ActiveRecord::Base
  include AtomicArrays
end

# Seed

Comment.create({id: 1, user_id: 1, body: "from user 1!!!", tags: ["#fun"]})
Comment.create({id: 2, user_id: 2, body: "from user 2!!!", liker_ids: [4,5]})
Comment.create({id: 3, user_id: 3, body: "from user 2!!!", tags: ["#fun", "#coolpostbro"]})
Comment.create({id: 4, user_id: 3, body: "from user 3!!!", liker_ids: [2,3]})
Comment.create({id: 5, user_id: 5, body: "from user 4!!!", tags: ["#yay"], liker_ids: [1,2]})
Comment.create({id: 6, user_id: 5, body: "from user 5!!!", liker_ids: [1]})

User.create({id: 1, name: "John", age: 34, hobbies: ["skateboarding"], comment_ids: [1]})
User.create({id: 2, name: "James", age: 25, hobbies: ["eating", "basketball"], comment_ids: [2]})
User.create({id: 3, name: "Jane", age: 27, hobbies: ["hanging out"], comment_ids: [3, 4]})
User.create({id: 4, name: "Bill", age: 22, hobbies: ["Studying", "Online chatting"]})
User.create({id: 5, name: "Natasha", age: 41, hobbies: ["Nothing"], comment_ids: [5, 6]})
User.create({id: 6, name: "Courtney", age: 32})